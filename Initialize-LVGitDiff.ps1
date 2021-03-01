[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '', Justification = "False positive")]
param(
    # Path to a Git repository that needs to be initialized for diffing LabVIEW files.
    [Parameter(Mandatory = $true)]
    [string] $RepositoryPath,

    # Explicit path to LVCompare. Defaults to '<drive>:\Program Files*\National Instruments\Shared\LabVIEW Compare\lvcompare.exe'.
    [string] $LvComparePath
)

$main = {
    if (!(Test-Path $RepositoryPath)) {
        throw "$RepositoryPath does not exist!"
    }

    Import-Module $PSScriptRoot\NI.Software\NI.Software.psm1 -Force

    function EscapePath([string] $UnescapedPath) {
        $UnescapedPath.Replace('\', '\\')
    }

    $wrapperScriptPath = Copy-Item "$PSScriptRoot\GitDiffCommand.sh" $env:USERPROFILE -PassThru

    $lvComparePath = Find-LvCompare $LvComparePath -Verbose:$VerbosePreference
    if ($lvComparePath -and (Test-Path $lvComparePath)) {
        $CgFileTypes | Enable-FileTypeDiff $RepositoryPath 'cg-diff' "$(EscapePath($wrapperScriptPath)) '\""$(EscapePath($lvComparePath))\"" -nobdpos -nofppos \""`$FIXED_OLD\"" \""`$FIXED_NEW\""' $true"
    } else {
        Write-Warning "Could not locate LV Compare; Re-run this script and specify the location of lvcompare.exe with -LvComparePath or LV CG files will not be graphically diffed."
    }
}

function Enable-FileTypeDiff {
    param(
        [string] $RepositoryPath,
        [string] $DiffName,
        [string] $DiffCommand
    )

    git config --global diff."$DiffName".command $DiffCommand

    $labviewType = ''
    if ($DiffName -match '([^-]+)') {
        $labviewType = " $($Matches[1])".ToUpperInvariant()
    }

    $hasHeader = $false
    $gitAttributes = "$RepositoryPath\.gitattributes"
    $newlineCount = if (Test-Path $gitAttributes) { 2 } else { 0 }

    foreach ($filetype in $input) {
        if ("$(git -C $RepositoryPath check-attr diff *$filetype)" -notmatch $DiffName) {
            if (!$hasHeader) {
                # AppendAllText will automatically create the file if it doesn't exist, unlike Add-Content
                [System.IO.File]::AppendAllText($gitAttributes, [Environment]::NewLine * $newlineCount + @"
###############################################################################
# Use $DiffName to diff LabVIEW$labviewType files
###############################################################################
"@)
                $hasHeader = $true
            }

            [System.IO.File]::AppendAllText($gitAttributes, [Environment]::NewLine + "*$filetype diff=$DiffName")
        }
    }
}

& $main