$Session = @{
    Initialized  = $false
    ComparePath  = $null
    ConvertPath  = $null
    IdentifyPath = $null
}

$RequiredBinaries = @("compare", "convert", "identify")

New-Variable -Name Session -Value $Session -Scope Script -Force

<#
    .SYNOPSIS
    Downloads, unzips, and sets paths to portable ImageMagick binaries.

    .DESCRIPTION
    This cmdlet tries to do as little as possible. First, it checks to see if the zip file exists in the download location.
    If it doesn't, it will download the zip file. Next, it checks to see if the zip file has been unzipped. If it hasn't,
    it will unzip the downloaded zip file. Finally, it checks that the required binaries are present. If they aren't, it will
    issue error message(s).
#>
function Install-ImageMagick {
    [CmdletBinding()]
    [OutputType([string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", '', Justification = "https://github.com/PowerShell/PSScriptAnalyzer/issues/1163")]
    param(
        # Location to download ImageMagick. If not specified, the latest portable-Q16-x86 version parsed from https://download.imagemagick.org/ImageMagick/download/binaries.
        [uri] $DownloadUrl,

        # Top-level directory that should contain ImageMagick. Defaults to "$env:TEMP\imagemagick".
        [string] $DownloadPath = "$env:TEMP\imagemagick"
    )

    # Did we already download a version of ImageMagick?
    $haveIM = $RequiredBinaries |
        ForEach-Object { $haveBinaries = $True } { $haveBinaries = $haveBinaries -and (Test-Path "$DownloadPath\*\$_.exe") } { $haveBinaries }
    if (!$haveIM) {
        if (!$DownloadUrl) {
            $binariesUrl = "https://download.imagemagick.org/ImageMagick/download/binaries"
            $response = Invoke-WebRequest -UseBasicParsing -Uri $binariesUrl
            $version = $response.Links.href | Sort-Object -Descending | Where-Object { $_ -match "portable-Q16-x86.zip$" } | Select-Object -first 1
            $downloadUrl = [uri] "$binariesUrl/$version"
        } else {
            $downloadUrl = $DownloadUrl
        }

        $filename = $downloadUrl.Segments[-1]
        $zippedPath = "$DownloadPath\$filename"
        if (!(Test-Path $zippedPath)) {
            $null = New-Item -ItemType Directory -Force $DownloadPath
            Write-Verbose "Downloading ImageMagick from '$DownloadUrl'"
            $response = Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $zippedPath -PassThru
            if ($response.StatusCode -ne 200) {
                throw "Failed to download $DownloadUrl; $response.StatusDescription"
            }
            Write-Verbose "Downloaded ImageMagick to '$zippedPath'"
        }

        $zippedInfo = Get-Item $zippedPath
        $unzippedPath = "$($zippedInfo.DirectoryName)\$($zippedInfo.BaseName)"
        if (!(Test-Path $unzippedPath)) {
            Write-Verbose "Unzipping ImageMagick from '$zippedPath'"
            Expand-Archive $zippedPath -DestinationPath $unzippedPath -Force
            Write-Verbose "Unzipped ImageMagick to '$unzippedPath'"
        }
    }

    $RequiredBinaries | ForEach-Object {
        $toolPath = (Resolve-Path "$DownloadPath\*\$_.exe").Path | Select-Object -First 1
        $Session["$($_)Path"] = $toolPath
        if (!(Test-Path $toolPath)) {
            Write-Error "Required tool '$toolPath' does not exist!"
        }
    }

    $Session.Initialized = $true
}

<#
    .SYNOPSIS
    Returns a number representing the percentage difference between two images.

    .DESCRIPTION
    Uses ImageMagick's compare.exe to perform a RMSE difference between two images. This number is then multiplied by 100 to receive a percentage.
#>
function Compare-Images {
    [CmdletBinding()]
    [OutputType([double])]
    param(
        # Path to the first image to compare.
        [ValidateScript({ Test-ParameterPath -Path $_ })]
        [Parameter(Mandatory)]
        [string] $ImageAPath,

        # Path to the second image to compare.
        [ValidateScript({ Test-ParameterPath -Path $_ })]
        [Parameter(Mandatory)]
        [string] $ImageBPath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    # Notes:
    # 1. Compare.exe output goes to stderr for whatever reason, so redirect to stdout
    # 2. This must be invoked with cmd /c or a NativeCommandError exception will occur
    # 3. Use compare.exe because convert.exe <image1.png> <image2.png> -compose difference -composite -format '%[fx:mean*100]' info:
    #    yields different results depending on image order
    $output = & cmd /c """$($Session.ComparePath)"" ""$ImageAPath"" ""$ImageBPath"" -metric RMSE null: 2>&1"
    if ("$output" -match '[\d\.]+\s+\(([\d.]+)\)') {
        [double]$Matches[1] * 100
    } else {
        throw "Unexpected output from $($Session.ComparePath): '$output'"
    }
}

<#
    .SYNOPSIS
    Returns the width and height in pixels for the specified image.

    .DESCRIPTION
    Uses ImageMagick's identify.exe to determine an image's size or returns 0, 0 if the image doesn't exist.
#>
function Get-ImageSize {
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        # Path to an image.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $ImagePath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    if ($ImagePath) {
        $output = & $Session.IdentifyPath """$ImagePath"""
        if ($output -match '(\d+)x(\d+)') {
            $width, $height = $Matches[1], $Matches[2]
            Write-Verbose "Image '$ImagePath' is size ${width}x${height}"
            $width, $height
        } else {
            throw "Unable to parse output from $($Session.IdentifyPath): '$output'"
        }
    } else {
        Write-Verbose "Returning a size of 0, 0 for '$ImagePath'"
        0, 0
    }
}

<#
    .SYNOPSIS
    Returns an image with it's extents updated to a new width and height.

    .DESCRIPTION
    Uses ImageMagick's convert.exe -extent option to extend an existing image to the specified dimensions.
#>
function New-ResizedImage {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        # Path to an image.
        [ValidateScript({ Test-ParameterPath -Path $_ })]
        [Parameter(Mandatory)]
        [string] $ImagePath,

        # How wide to make the image in pixels.
        [Parameter(Mandatory)]
        [int] $Width,

        # How high to make the image in pixels.
        [Parameter(Mandatory)]
        [int] $Height,

        # Path to save the resized image. Defaults to the original $ImagePath with '_Resized' appended to the filename.
        [string] $OutputImagePath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    $definedOutputImagePath = if ($OutputImagePath) {
        $OutputImagePath
    } else {
        $image = Get-Item $ImagePath
        "$($image.DirectoryName)\$($image.BaseName)_Resized$($image.Extension)"
    }

    if ($PSCmdlet.ShouldProcess($definedOutputImagePath)) {
        & $Session.ConvertPath """$ImagePath""" -extent "${Width}x${Height}" """$definedOutputImagePath"""
    }

    Write-Verbose "Resized '$ImagePath' to ${Width}x${Height} and saved as '$definedOutputImagePath'"
    $definedOutputImagePath
}

<#
    .SYNOPSIS
    Creates a blank (background white) image of a specified size and returns its path.

    .DESCRIPTION
    Uses ImageMagick's convert.exe -size option to create a white image of the specified dimensions.
#>
function New-BlankImage {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        # How wide to make the image in pixels.
        [Parameter(Mandatory)]
        [int] $Width,

        # How high to make the image in pixels.
        [Parameter(Mandatory)]
        [int] $Height,

        # Path to save the image. Defaults to a temporary file if not specified.
        [string] $OutputImagePath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    $definedOutputImagePath = if ($OutputImagePath) { $OutputImagePath } else { Get-TempFilePath }

    if ($PSCmdlet.ShouldProcess(($definedOutputImagePath))) {
        & $Session.ConvertPath -size "${Width}x${Height}" xc: """$definedOutputImagePath"""
    }

    Write-Verbose "Created blank image '$definedOutputImagePath' of size ${Width}x${Height}"
    $definedOutputImagePath
}

<#
    .SYNOPSIS
    Creates a "diff" image showing differences between two images.

    .DESCRIPTION
    Uses ImageMagick's convert.exe with multiple commands to convert each before/after image to grayscale and compose both
    onto a single image where before appears red and after appears green.
#>
function New-DiffImage {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        # Path to a "before" image.
        [ValidateScript({ Test-ParameterPath -Path $_ })]
        [Parameter(Mandatory)]
        [string] $BeforeImagePath,

        # Path to an "after" image.
        [ValidateScript({ Test-ParameterPath -Path $_ })]
        [Parameter(Mandatory)]
        [string] $AfterImagePath,

        # Path to save the image. Defaults to a temporary file if not specified.
        [string] $OutputImagePath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    $definedOutputImagePath = if ($OutputImagePath) { $OutputImagePath } else { Get-TempFilePath }

    if ($PSCmdlet.ShouldProcess(($definedOutputImagePath))) {
        # Adapted from https://stackoverflow.com/a/33673440/116047
        $arguments = @(
            "( ""$AfterImagePath"" -colorspace gray )"
            "( ""$BeforeImagePath"" -colorspace gray )"
            "("
            "-clone 0-1"
            "-compose darken"
            "-composite"
            ")"
            "-channel RGB"
            "-combine ""$definedOutputImagePath"""
        )
        & $Session.ConvertPath $arguments
    }

    Write-Verbose "Created diff image: '$definedOutputImagePath'"
    $definedOutputImagePath
}

<#
    .SYNOPSIS
    Merges multiple images into one by appending each on top of the other in a new image.

    .DESCRIPTION
    Uses ImageMagick's convert.exe -append option to vertically stack the provided images.
#>
function Merge-Images {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        # Paths to images that should be merged into one.
        [ValidateScript({ Test-ParameterPaths -Paths $_ })]
        [Parameter(Mandatory)]
        [string[]] $ImagePaths,

        # Padding width, in pixels, to apply to each image. Defaults to 25.
        [int] $Padding = 25,

        # Border width, in pixels, to apply to each image. Defaults to 0.
        [int] $Border = 0,

        # Padding color to apply to each image. Defaults to #FFFFFF, or white.
        [string] $PaddingColor = "#FFFFFF",

        # Border color to apply to each image. Defaults to #BDBDBD, or light gray.
        [string] $BorderColor = "#BDBDBD",

        # Path to save the merged image. Defaults to a temporary file if not specified.
        [string] $OutputImagePath
    )

    if (!$Session.Initialized) {
        throw "Install-ImageMagick must be called first"
    }

    $definedOutputImagePath = if ($OutputImagePath) { $OutputImagePath } else { Get-TempFilePath }

    if ($PSCmdlet.ShouldProcess($definedOutputImagePath)) {
        $arguments = @(
            '-frame'
            $Border
            '-mattecolor'
            """$BorderColor"""
            '-border'
            $Padding
            '-bordercolor'
            """$PaddingColor"""
        ) + @($ImagePaths) + @(
            '-append'
            """$definedOutputImagePath"""
        )
        Write-Verbose "Running '$($Session.ConvertPath) $arguments'"
        & $Session.ConvertPath $arguments
    }

    Write-Verbose "Merged $($ImagePaths.Length) images into '$definedOutputImagePath'"
    $definedOutputImagePath
}

function Get-TempFilePath() {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [string] $Extension = '.png'
    )

    $filePath = New-TemporaryFile -Verbose:$VerbosePreference
    Remove-Item $filePath -Force -Verbose:$VerbosePreference
    "$filePath" -replace '.tmp$', $Extension
}

function Test-ParameterPaths() {
    param(
        [string[]] $Paths
    )

    $Paths | ForEach-Object { Test-ParameterPath -Path $_ }
    return $true
}

function Test-ParameterPath() {
    param(
        [string] $Path
    )

    if (-Not ($Path | Test-Path)) {
        throw "'$Path' does not exist"
    }

    return $true
}