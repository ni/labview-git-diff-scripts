using module ..\SharedTypes.ps1

<#
    .SYNOPSIS
    Returns an array of [NI.ChangedFile] for each file change between two commits.

    .DESCRIPTION
    Uses git.exe to ensure proper values for parameters and then calls `git diff` between the
    specified commits. These "commits" can be any value allowed under SPECIFYING REVISIONS
    detailed here: https://git-scm.com/docs/gitrevisions. Returns the type [NI.ChangedFile]
    to record properties related to the change.
#>
function Get-ChangesBetweenCommits {
    [CmdletBinding()]
    [OutputType([NI.ChangedFile[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '', Justification = "False positive")]
    param(
        # Path to a git repository. Defaults to the current working directory.
        [string] $RepositoryPath = (Get-Location),

        # Commit that deviates from the baseline. Defaults to HEAD.
        [string] $NewCommit = "HEAD",

        # Commit that acts as the baseline. Defaults to master.
        [string] $BaseCommit = "master",

        # Don't fetch the latest remote changes.
        [switch] $SkipFetch,

        # Don't error if the tip of the branch isn't equal to HEAD.
        [switch] $IgnoreOutOfDate
    )

    function Test-Commit ($Commit) {
        $null = git -C $RepositoryPath cat-file commit $Commit 2>&1
        $LASTEXITCODE -eq 0
    }

    function Get-Rev ($Commit) {
        git -C $RepositoryPath rev-parse $Commit
    }

    # First, ensure we're in a git repository
    $gitPath = Join-Path $RepositoryPath ".git"
    if (!(Test-Path $gitPath)) {
        throw "'$gitPath' not found. Specify a path to a git repository with -RepositoryPath"
    }

    if (!$SkipFetch) {
        Write-Verbose "Fetching updates from upstream..."
        git -C $RepositoryPath fetch
    }

    # Second, check new commit
    switch ($NewCommit) {
        { -not $_ } { throw "-NewCommit must be specified" }
        { -not (Test-Commit $_) } { throw "-NewCommit '$NewCommit' does not exist" }
        { (Get-Rev $_) -ne (Get-Rev HEAD) -and -not $IgnoreOutOfDate } {
            throw "-NewCommit '$NewCommit' is not up-to-date. Pass -IgnoreOutOfDate to ignore this error"
        }
    }

    # Third, check base commit
    switch ($BaseCommit) {
        { -not $_ } { throw "-BaseCommit must be specified" }
        { -not (Test-Commit $_) } { throw "-BaseCommit '$BaseCommit' does not exist" }
    }

    Write-Verbose "Getting changes for repository: $RepositoryPath"
    git -C $RepositoryPath diff --name-status "$BaseCommit..$NewCommit" |
        ForEach-Object { [NI.ChangedFile]::new($RepositoryPath, $_) }
}

<#
    .SYNOPSIS
    Runs `git difftool` for the specified repository, commits, and command.

    .DESCRIPTION
    Provides a reproducible way to run `git difftool` for the specified repository, commits, and
    command as there are a lot of moving parts here.
#>
function Compare-ChangesWithTool {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        # Path to a git repository. Defaults to the current working directory.
        [string] $RepositoryPath = (Get-Location),

        # Commit that deviates from the baseline. Defaults to HEAD.
        [string] $NewCommit = "HEAD",

        # Commit that acts as the baseline. Defaults to master.
        [string] $BaseCommit = "master",

        # Name for the custom diff tool. Defaults to "custom".
        [string] $DifftoolName = "custom",

        # Command the difftool should execute.
        [Parameter(Mandatory)]
        [string] $DifftoolCmd,

        # Path to the file that should be diffed.
        # Defaults to $null which means "diff all changed files".
        [string] $FilePath = $null
    )

    $arguments = @(
        '-C'
        """$RepositoryPath"""
        '-c'
        "difftool.$DifftoolName.cmd=$DifftoolCmd"
        "difftool"
        "--no-prompt"
        '-t'
        $DifftoolName
        """$BaseCommit...$NewCommit"""
    )
    if ($FilePath) {
        Write-Debug "FilePath was specified: $FilePath"
        $arguments += @('--', $FilePath)
    }

    Write-Verbose "Running 'git $arguments'"
    $output = & git $arguments
    Write-Debug "Difftool '$Difftoolname' output: $output"
}

<#
    .SYNOPSIS
    Disables diff tool(s) for the specified file types in the specified .gitattributes file.

    .DESCRIPTION
    Diff tools in .gitattributes files override any difftool provided to Git on-the-fly. Thus,
    this cmdlet allows `git difftool` to actually work in those cases. It can be run many times
    to no ill affect (idempotent).
#>
function Disable-DiffTool {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        # Path to a .gitattributes file.
        [Parameter(Mandatory)]
        [string] $GitAttributesPath,

        # Array of filetypes whose custom diff tool should be disabled.
        [Parameter(Mandatory)]
        [string[]] $FileTypes
    )

    Edit-EnabledDiffTool -GitAttributesPath $GitAttributesPath -FileTypes $FileTypes -Disable
}

<#
    .SYNOPSIS
    Enables diff tool(s) for the specified file types in the specified .gitattributes file.

    .DESCRIPTION
    Allows `git diff` to run custom diff tools for certain filetypes by default. It can be run
    many times to no ill affect (idempotent).
#>
function Enable-DiffTool {
    [CmdletBinding()]
    param(
        # Path to a .gitattributes file.
        [Parameter(Mandatory)]
        [string] $GitAttributesPath,

        # Array of filetypes whose custom diff tool should be enabled.
        [Parameter(Mandatory)]
        [string[]] $FileTypes
    )

    Edit-EnabledDiffTool -GitAttributesPath $GitAttributesPath -FileTypes $FileTypes -Enable
}

function Edit-EnabledDiffTool {
    [CmdletBinding()]
    [OutputType([System.Void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '', Justification = "False positive")]
    param(
        [Parameter(Mandatory)]
        [string] $GitAttributesPath,

        [Parameter(Mandatory)]
        [string[]] $FileTypes,

        [Parameter(Mandatory, ParameterSetName = "Enable")]
        [switch] $Enable,

        [Parameter(Mandatory, ParameterSetName = "Disable")]
        [switch] $Disable
    )

    if (Test-Path $GitAttributesPath) {
        $content = Get-Content $GitAttributesPath
        Write-Debug "Read the following from .gitattributes:`n`n$content"

        $FileTypes | ForEach-Object {
            if ($Enable) {
                $search = '-'
                $replace = ''
            } elseif ($Disable) {
                $search = ''
                $replace = '-'
            }
            $content = $content -replace "^\*$_ ${search}diff=(.*)$", "*$_ ${replace}diff=`$1"
        }

        Write-Verbose "Writing the following to .gitattributes:`n`n$content"
        Set-Content $GitAttributesPath $content
    }
}