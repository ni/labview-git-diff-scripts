# Contributing to labview-git-diff-scripts

Contributions to labview-git-diff-scripts are welcome from all!

labview-git-diff-scripts is managed via [git](https://git-scm.com), with the canonical upstream
repository hosted on [GitHub](https://github.com/ni/labview-git-diff-scripts/).

labview-git-diff-scripts follows a pull-request model for development. If you wish to
contribute, you will need to create a GitHub account, fork this project, push a
branch with your changes to your project, and then submit a pull request.

Please remember to sign off your commits (e.g., by using `git commit -s` if you
are using the command line client). This amends your git commit message with a line
of the form `Signed-off-by: Name Lastname <name.lastmail@emailaddress.com>`. Please
include all authors of any given commit into the commit message with a
`Signed-off-by` line. This indicates that you have read and signed the Developer
Certificate of Origin (see below) and are able to legally submit your code to
this repository.

See [GitHub's official documentation](https://help.github.com/articles/using-pull-requests/) for more details.

# Getting Started

labview-git-diff-scripts contains PowerShell cmdlets to generate diffs of LabVIEW
files residing in a git repository. See the [README](README.md) for usage details.

## Architecture

The ultimate goal of this project is to balance ease-of-use with flexibility; this is why `Compare-LvFiles` doesn't call `Merge-ImageDiffs`, for example.

### Modules

- `NI.LvDiff` - Cmdlets for obtaining and manipulating image diffs of LabVIEW files
- `NI.Software` - Cmdlets for getting information about installed NI software
- `NI.Git` - PowerShell wrapper for a subset of [Git](https://git-scm.com/doc)'s capabilities
- `NI.ImageMagick` - PowerShell wrapper for a subset of [ImageMagick](https://imagemagick.org/index.php)'s capabilities

## Conventions

- Cmdlets (including non-exported) should be named Verb-Noun and only use [approved verbs](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-5.1)
- Always specify parameters by name (no positional parameters)
- Use [OTBS](<https://en.wikipedia.org/wiki/Indentation_style#Variant:_1TBS_(OTBS)>)
- Do not use aliases (KISS)
- Document exported cmdlets with at least `.SYNOPSIS` and `.DESCRIPTION`
- Document exported cmdlet parameters, including default values
- Qualify exported cmdlets with their module name e.g. `NI.Software\Find-Lv`
- Ensure verbosity preference passes to another module's scope e.g. `-Verbose:$VerbosePreference`

> Note: [.vscode/settings.json](.vscode/settings.json) and [PSScriptAnalyzerSettings.psd1](PSScriptAnalyzerSettings.psd1) will ensure the correct style is followed when coding in [Visual Studio Code](https://azure.microsoft.com/en-us/products/visual-studio-code/) with the [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell) extension

# Testing

Ideally, each public function is tested with [Pester](https://pester.dev/docs/quick-start). Please ensure your tests pass before submitting a PR.

## Conventions

We try to adhere to the [Given-When-Then](https://en.wikipedia.org/wiki/Given-When-Then) philosophy of test naming.

- `Describe` lists the "Given", or software under test (SUT)
- `It` is a sentence fragment that succinctly states "When" and "Then"

> Note: "When" is not required in every circumstance

## Examples

Pester's documentation gives the following [example](https://pester.dev/docs/quick-start#creating-a-pester-test):

```pwsh
Describe 'Get-Planet' {
  It 'Given no parameters, it lists all 8 planets' { }
}
```

Adapted to our conventions:

```pwsh
Describe 'Get-Planet' {
  It 'without parameters, lists all 8 planets' { }
}
```

Or, better yet:

```pwsh
Describe 'Get-Planet' {
  It 'lists all 8 planets' { }

  # Another example
  It 'with MaxDistance of 150, lists first 3 planets' { }
}
```

# Developer Certificate of Origin (DCO)

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
have the right to submit it under the open source license
indicated in the file; or

(b) The contribution is based upon previous work that, to the best
of my knowledge, is covered under an appropriate open source
license and I have the right under that license to submit that
work with modifications, whether created in whole or in part
by me, under the same open source license (unless I am
permitted to submit under a different license), as indicated
in the file; or

(c) The contribution was provided directly to me by some other
person who certified (a), (b) or (c) and I have not modified
it.

(d) I understand and agree that this project and the contribution
are public and that a record of the contribution (including all
personal information I submit with it, including my sign-off) is
maintained indefinitely and may be redistributed consistent with
this project or the open source license(s) involved.

(taken from [developercertificate.org](https://developercertificate.org/))

See [LICENSE](https://github.com/ni/labview-git-diff-scripts/blob/main/LICENSE)
for details about how labview-git-diff-scripts is licensed.
