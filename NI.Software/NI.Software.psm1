<#
    .SYNOPSIS
    Returns the path to the latest version of LabVIEW installed on the system or null.

    .DESCRIPTION
    Looks in '<drive>:\Program Files*\National Instruments\LabVIEW xxxx' for LabVIEW.exe and
    selects the location with the most recent version number.
#>
function Find-Lv {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Preferred path to LabVIEW that should be used if it exists.
        [string] $PreferredPath
    )

    $executable = 'LabVIEW.exe'

    if ($PreferredPath -and (Test-Path $PreferredPath)) {
        Write-Verbose "Using $executable at '$PreferredPath'"
        return $PreferredPath
    }

    # Find the latest version of LabVIEW installed
    'HKLM:\SOFTWARE\National Instruments\LabVIEW\*', 'HKLM:\SOFTWARE\WOW6432Node\National Instruments\LabVIEW\*' |
        ForEach-Object { Get-ItemProperty $_ -ErrorAction SilentlyContinue } |
        Where-Object PSChildName -ne 'CurrentVersion' |
        Sort-Object VersionString -Descending |
        ForEach-Object {
            $labviewPath = Join-Path $_.Path $executable
            if ($labviewPath -and (Test-Path $labviewPath)) {
                Write-Verbose "Found $executable at '$labviewPath'"
                $labviewPath
            }
        } |
        Select-Object -First 1
}

<#
    .SYNOPSIS
    Returns the path to LVCompare installed on the system or null.

    .DESCRIPTION
    Selects the first instance of lvcompare.exe found in '<drive>:\Program Files*\National Instruments\Shared\LabVIEW Compare'.
#>
function Find-LvCompare {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Preferred path to LVCompare that should be used if it exists.
        [string] $PreferredPath
    )

    $executable = 'LVCompare.exe'

    if ($PreferredPath -and (Test-Path $PreferredPath)) {
        Write-Verbose "Using $executable at '$PreferredPath'"
        return $PreferredPath
    }

    $labviewPath = Find-Lv
    if ($labviewPath) {
        $niDir = Split-Path (Split-Path $labviewPath)
        $lvComparePath = "$niDir\Shared\LabVIEW Compare\$executable"
        if ($lvComparePath -and (Test-Path $lvComparePath)) {
            Write-Verbose "Found $executable at '$lvComparePath'"
            $lvComparePath
        }
    }
}

<#
    .SYNOPSIS
    Returns true if the process is running, false otherwise.

    .DESCRIPTION
    Searches all running processes on the system for the one whose Path matches the provided path.
#>
function Test-Process {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [string] $ProcessPath
    )

    $null -ne (Get-Process | Where-Object Path -eq $ProcessPath)
}