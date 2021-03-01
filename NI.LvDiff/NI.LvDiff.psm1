using module ..\SharedTypes.ps1

$LvFileTypes = '.vi', '.vim', '.vit', '.ctt', '.ctl'

$Session = @{
    Initialized        = $false
    RepositoryPath     = $null
    LvPath             = $null
    CompareViPath      = $null
    GitDiffCommandPath = $null
}

<#
    .SYNOPSIS
    Initiates a LabVIEW diffing session.

    .DESCRIPTION
    Initiates a LabVIEW diffing session for a given repository. Most importantly, it disables
    running any diff tool associated with LabVIEW files until Stop-LvDiff is called. This allows
    Compare-LvFiles to use its own diff tool.
#>
function Start-LvDiff {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param(
        # Path to a Git repository. Defaults to the current location.
        [string] $RepositoryPath = (Get-Location),

        # Path to LabVIEW so we can execute Compare.vi.
        # Defaults to the latest version of LabVIEW installed on the system, regardless of bitness.
        [string] $LvPath,

        # Path to the VI that will generate screenshots from two VIs.
        # Defaults to "$PSScriptRoot\Compare\Compare.vi"
        [string] $CompareViPath = "$PSScriptRoot\Compare\Compare.vi",

        # Path to a Bash script that will...
        # 1. Copy the files being diffed into $RepositoryPath (so their dependencies can be found)
        # 2. Execute the passed in command.
        # Defaults to "$PSScriptRoot\..\GitDiffCommand.sh"
        [string] $GitDiffCommandPath = "$PSScriptRoot\..\GitDiffCommand.sh"
    )

    $Session.RepositoryPath = $RepositoryPath -replace '\\$', ''
    $Session.LvPath = $LvPath
    $Session.CompareViPath = $CompareViPath
    $Session.GitDiffCommandPath = $GitDiffCommandPath

    NI.ImageMagick\Install-ImageMagick -Verbose:$VerbosePreference

    $gitAttributesPath = "$($Session.RepositoryPath)/.gitattributes"
    if ($PScmdlet.ShouldProcess($gitAttributesPath)) {
        NI.Git\Disable-DiffTool -GitAttributesPath $gitAttributesPath -FileTypes $LvFileTypes -Verbose:$VerbosePreference
    }

    $Session.Initialized = $true
}

<#
    .SYNOPSIS
    Returns an array of { Name, ImageDiffs } for each changed LabVIEW file.

    .DESCRIPTION
    Uses the NI.Git module to find any added, modified, or deleted LabVIEW file(s) between two
    commits. For each LabVIEW file that was added or modified, a custom diff tool is launched.
    It produces before/after images of the LabVIEW file's connector pane, front panel, and
    block diagram. These images are intelligently paired and resized for better visual diffing
    later. An array of hashes grouping file name and these pairings is returned for each file.
#>
function Compare-LvFiles {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '', Justification = "False positive")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", '', Justification = "False positive")]
    param(
        # Path to output images of LabVIEW files. Defaults to a temporary folder under %TEMP%.
        [string] $OutputPath = (New-TemporaryPath),

        # Git commit identifier.
        [string] $NewCommit,

        # Git commit identifier.
        [string] $BaseCommit
    )

    if (!$Session.Initialized) {
        throw "Start-LvDiff must be called first"
    }

    NI.Git\Get-ChangesBetweenCommits -RepositoryPath $Session.RepositoryPath -NewCommit $NewCommit -BaseCommit $BaseCommit -Verbose:$VerbosePreference |
        ForEach-Object { $i = 0 } {
            $i++
            $change = $_
            $fileOutputPath = "$OutputPath\$i"
            $null = New-Item -Type Directory $fileOutputPath -Force -Verbose:$VerbosePreference

            switch ($change.ChangeType) {
                { $_ -eq [NI.ChangeType]::Added -or $_ -eq [NI.ChangeType]::Modified } {
                    $difftoolCmd = Get-DiffToolCmd -DiffOutputPath $fileOutputPath -Verbose:$VerbosePreference
                    $arguments = @{
                        RepositoryPath = $Session.RepositoryPath
                        NewCommit      = $NewCommit
                        BaseCommit     = $BaseCommit
                        DifftoolName   = "gcompare"
                        DifftoolCmd    = $difftoolCmd
                        FilePath       = """$($change.Path)"""
                        Verbose        = $VerbosePreference
                        Debug          = $DebugPreference
                    }
                    NI.Git\Compare-ChangesWithTool @arguments
                }
                ([NI.ChangeType]::Removed) {
                    Write-Verbose "Skipping removed file '$($change.Path)'"
                    continue
                }
            }

            [pscustomobject]@{ Path = Resolve-Path $_.Path; ImageDiffs = Get-ImageDiffs -DiffOutputPath $fileOutputPath }
        }
}

<#
    .SYNOPSIS
    Transforms multiple before/after images for a LabVIEW file into a single before/after image.

    .DESCRIPTION
    Uses the NI.ImageMagick module to append each before/after image into a new image.
#>
function Merge-ImageDiffs {
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        # Array containing groupings of before/after images for a given LabVIEW file.
        [Parameter(Mandatory, ValueFromPipeline)]
        [NI.ImageDiff[]] $ImageDiffs,

        # Path to output images of LabVIEW files. Defaults to a temporary folder under %TEMP%.
        [string] $OutputPath = (New-TemporaryPath),

        # Name to call the 'before' image. Defaults to 'Before'.
        [string] $BeforeName = 'Before',

        # Name to call the 'after' image. Defaults to 'After'.
        [string] $AfterName = 'After',

        # Name to call the 'diffence' image. Defaults to 'Diff'.
        [string] $DiffName = 'Diff',

        # Include a "difference" image to highlight differences between the before and after images.
        [switch] $IncludeDiffImage
    )

    BEGIN {
        if (!$Session.Initialized) {
            throw "Start-LvDiff must be called first"
        }

        $allImageDiffs = @()
    }

    PROCESS {
        $allImageDiffs += $ImageDiffs
    }

    END {
        $beforeImagePaths = ($allImageDiffs | ForEach-Object { $_.BeforeImagePath })
        $beforeImagePath = NI.ImageMagick\Merge-Images -ImagePaths $beforeImagePaths -OutputImagePath "$OutputPath\$BeforeName.png" -Verbose:$VerbosePreference

        $afterImagePaths = ($allImageDiffs | ForEach-Object { $_.AfterImagePath })
        $afterImagePath = NI.ImageMagick\Merge-Images -ImagePaths $afterImagePaths -OutputImagePath "$OutputPath\$AfterName.png" -Verbose:$VerbosePreference

        if ($IncludeDiffImage) {
            $arguments = @{
                BeforeImagePath = $beforeImagePath
                AfterImagePath  = $afterImagePath
                OutputImagePath = "$OutputPath\$DiffName.png"
                Verbose         = $VerbosePreference
            }
            $beforeImagePath, $afterImagePath, (NI.ImageMagick\New-DIffImage @arguments)
        } else {
            $beforeImagePath, $afterImagePath, $null   # callers expect this to return 3 values
        }
    }
}

<#
    .SYNOPSIS
    Terminates a LabVIEW diffing session.

    .DESCRIPTION
    Terminates a LabVIEW diffing session for the current repository. Most importantly, it enables
    running any diff tool associated with LabVIEW files.
#>
function Stop-LvDiff {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param()

    $Session.Initialized = $false

    $gitAttributesPath = "$($Session.RepositoryPath)/.gitattributes"
    if ($PSCmdlet.ShouldProcess($gitAttributesPath)) {
        NI.Git\Enable-DiffTool -GitAttributesPath $gitAttributesPath -FileTypes $LvFileTypes -Verbose:$VerbosePreference
    }
}

<#
    .SYNOPSIS
    Returns a path to a temporary directory.

    .DESCRIPTION
    Uses New-TemporaryFile to obtain a path to a unique file. This file is then removed and its
    path and name concatenated to form a directory path. Finally, the directory is created and
    its full path returned.
#>
function New-TemporaryPath {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param()

    # Note: while it's possible our temporary file name could be reused, it's very unlikely
    $tempFilePath = New-TemporaryFile -Verbose:$VerbosePreference
    Remove-Item $tempFilePath -Force -Verbose:$VerbosePreference
    $tempPath = $tempFilePath -replace ".tmp$"
    (New-Item $tempPath -ItemType Directory -Verbose:$VerbosePreference).FullName
}

function Get-DiffToolCmd {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $DiffOutputPath
    )

    $comparePath = "$PSScriptRoot\Compare\Compare.vi"
    if (!(Test-Path $comparePath)) {
        throw "Compare path cannot be found: $comparePath"
    }

    $labviewPath = NI.Software\Find-Lv -PreferredPath $Session.LvPath -Verbose:$VerbosePreference
    if (!$labviewPath -or !(Test-Path $labviewPath)) {
        throw 'LabVIEW cannot be found.'
    }
    if (NI.Software\Test-Process $labviewPath) {
        throw "All instances of '$labviewPath' must be closed before running this script."
    }

    $escapedDiffCommandPath = "\""$($Session.GitDiffCommandPath.Replace('\', '\\'))\"""
    $escapedToolCmd = "\""$($labviewPath.Replace('\', '\\'))\"" \""$($Session.CompareViPath.Replace('\', '\\'))\"""
    $differ = @(
        "$escapedDiffCommandPath '$escapedToolCmd --"
        '--old \"$FIXED_OLD\" --new \"$FIXED_NEW\"'
        "--out $($DiffOutputPath.Replace('\', '\\')) --quit 1'"
    ) -join ' '
    $cmd = @(
        $differ
        $false
        '\"$MERGED\"'
        '\"$LOCAL\"'
        "old_sha"
        "old_mode"
        '\"$REMOTE\"'
    ) -join ' '
    Write-Verbose "Git difftool will use cmd: $cmd"
    $cmd
}

function Get-ImageDiffs {
    [CmdletBinding()]
    [OutputType([NI.ImageDiff[]])]
    param(
        [string] $DiffOutputPath
    )

    $blockDiagramPattern = '*_blockdiagram*.png'
    $beforeImagePaths = @(Get-ChildItem "$DiffOutputPath\vi1shots\$blockDiagramPattern" | ForEach-Object FullName)
    $afterImagePaths = @(Get-ChildItem "$DiffOutputPath\vi2shots\$blockDiagramPattern" | ForEach-Object FullName)
    $rankedImageDiffs = Measure-ImageDiffs -BeforeImagePaths $beforeImagePaths -AfterImagePaths $afterImagePaths
    $blockDiagramImageDiffs = @(
        Select-BestImageDiffs -BeforeImagePaths $beforeImagePaths -AfterImagePaths $afterImagePaths -RankedImageDiffs $rankedImageDiffs
    )
    $imageDiffs = @(
        '*_connector.png', '*_frontpanel.png' |
            ForEach-Object {
                $beforeImagePaths = @(Get-ChildItem "$DiffOutputPath\vi1shots\$_" | ForEach-Object FullName)
                $afterImagePaths = @(Get-ChildItem "$DiffOutputPath\vi2shots\$_" | ForEach-Object FullName)
                if ($beforeImagePaths.Length -gt 1 -or $afterImagePaths.Length -gt 1) {
                    throw "Detected more than 1 connector/front panel image, which is unsupported."
                }
                if ($beforeImagePaths.Length -gt 0 -or $afterImagePaths.Length -gt 0) {
                    [NI.ImageDiff]::new($beforeImagePaths[0], $afterImagePaths[0])
                }
            }
    ) + $blockDiagramImageDiffs

    Format-ImageDiffs -ImageDiffs $imageDiffs
}

function Measure-ImageDiffs {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory)]
        [string[]] $BeforeImagePaths,

        [Parameter(Mandatory)]
        [string[]] $AfterImagePaths
    )

    $rankedDiffs = [ordered]@{}
    for ($i = 0; $i -lt $BeforeImagePaths.Length; $i++) {
        for ($j = 0; $j -lt $AfterImagePaths.Length; $j++) {
            $beforeImagePath = $BeforeImagePaths[$i]
            $afterImagePath = $AfterImagePaths[$j]

            $percentage = NI.ImageMagick\Compare-Images -ImageAPath $beforeImagePath -ImageBPath $afterImagePath
            $beforeImageName = Split-Path $beforeImagePath -Leaf
            $afterImageName = Split-Path $afterImagePath -Leaf
            Write-Debug "$percentage%: '$beforeImageName' to '$afterImageName'"

            if ($rankedDiffs.Contains($percentage)) {
                $rankedDiffs[[object]$percentage] += @([NI.ImageDiff]::new($beforeImagePath, $afterImagePath))
            } else {
                $rankedDiffs += @{ $percentage = @([NI.ImageDiff]::new($beforeImagePath, $afterImagePath)) }
            }
        }
    }

    $rankedDiffs
}

function Select-BestImageDiffs {
    [CmdletBinding()]
    [OutputType([NI.ImageDiff[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '', Justification = "False positive")]
    param(
        [Parameter(Mandatory)]
        [string[]] $BeforeImagePaths,

        [Parameter(Mandatory)]
        [string[]] $AfterImagePaths,

        [Parameter(Mandatory)]
        $RankedImageDiffs
    )

    # This syntax deep-copies the array so it can be modified without affecting callers
    $unmatchedBeforeImagePaths = { $BeforeImagePaths }.Invoke()
    $unmatchedAfterImagePaths = { $AfterImagePaths }.Invoke()

    $RankedImageDiffs.Keys |
        ForEach-Object {
            $key = $_
            $RankedImageDiffs[[object]$key] |
                ForEach-Object {
                    $diff = $_
                    $isBeforeImageUnmatched = $unmatchedBeforeImagePaths -contains $diff.BeforeImagePath
                    $isAfterImageUnmatched = $unmatchedAfterImagePaths -contains $diff.AfterImagePath

                    # The images must differ less than 25% for them to be considered a diff
                    if ([double]$key -lt 25 -and $isBeforeImageUnmatched -and $isAfterImageUnmatched) {
                        $null = $unmatchedBeforeImagePaths.Remove($diff.BeforeImagePath)
                        $null = $unmatchedAfterImagePaths.Remove($diff.AfterImagePath)
                        Write-Verbose "$key%: Matched '$($diff.BeforeImageName)' with '$($diff.AfterImageName)'"
                        [NI.ImageDiff]::new($diff.BeforeImagePath, $diff.AfterImagePath)
                    } else {
                        Write-Debug "$key%: No match '$($diff.BeforeImageName)' '$($diff.AfterImageName)'"
                    }
                }
            }

    $unmatchedBeforeImagePaths |
        ForEach-Object {
            Write-Verbose "Did not find match for 'before' image: '$_'"
            [NI.ImageDiff]::new($_, $null)
        }
    $unmatchedAfterImagePaths |
        ForEach-Object {
            Write-Verbose "Did not find match for 'after' image: '$_'"
            [NI.ImageDiff]::new($null, $_)
        }
}

function Format-ImageDiffs {
    [CmdletBinding()]
    [OutputType([NI.ImageDiff[]])]
    param(
        [NI.ImageDiff[]] $ImageDiffs
    )

    # Loop through the pairs and create composed before/after images
    $ImageDiffs |
        ForEach-Object {
            $beforeImagePath = $_.BeforeImagePath
            $afterImagePath = $_.AfterImagePath
            $beforeWidth, $beforeHeight = NI.ImageMagick\Get-ImageSize -ImagePath $beforeImagePath -Verbose:$VerbosePreference
            $afterWidth, $afterHeight = NI.ImageMagick\Get-ImageSize -ImagePath $afterImagePath -Verbose:$VerbosePreference
            $maxWidth = [Math]::Max($beforeWidth, $afterWidth)
            $maxHeight = [Math]::Max($beforeHeight, $afterHeight)
            $guid = (New-Guid).Guid -replace '-', ''
            $blankImagePath = "$DiffOutputPath\${guid}_Blank.png"

            # Resize smaller image to be the same size as the larger for diffing purposes
            if ($beforeWidth -lt $maxWidth -or $beforeHeight -lt $maxHeight) {
                $beforeImagePath = if ($beforeImagePath) {
                    NI.ImageMagick\New-ResizedImage -ImagePath $beforeImagePath -Width $maxWidth -Height $maxHeight -Verbose:$VerbosePreference
                } else {
                    NI.ImageMagick\New-BlankImage -Width $maxWidth -Height $maxHeight -OutputImagePath $blankImagePath -Verbose:$VerbosePreference
                }
            }

            if ($afterWidth -lt $maxWidth -or $afterHeight -lt $maxHeight) {
                $afterImagePath = if ($afterImagePath) {
                    NI.ImageMagick\New-ResizedImage -ImagePath $afterImagePath -Width $maxWidth -Height $maxHeight -Verbose:$VerbosePreference
                } else {
                    NI.ImageMagick\New-BlankImage -Width $maxWidth -Height $maxHeight -OutputImagePath $blankImagePath -Verbose:$VerbosePreference
                }
            }

            [NI.ImageDiff]::new($beforeImagePath, $afterImagePath)
        }
}