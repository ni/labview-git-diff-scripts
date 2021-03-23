# LabVIEW Git Diff Scripts

PowerShell cmdlets to generate diffs of LabVIEW files residing in a git repository.

![GitHub](https://img.shields.io/github/license/ni/labview-git-diff-scripts)

## Installing

```pwsh
# Clone this repository
PS> git clone 'https://github.com/ni/labview-git-diff-scripts.git'
```

## Getting Started

```pwsh
# Import the main module
PS> cd 'labview-git-diff-scripts'
PS> Import-Module .\NI.LvDiff\NI.LvDiff.psm1 -Force
```

## Usage

- Output an object per changed LabVIEW file that contains its path and connector pane, front panel, and block diagram `[NI.ImageDiff]`:

  ```pwsh
  > Start-LvDiff -RepositoryPath <repo path>
  > Compare-LvFiles -NewCommit HEAD -BaseCommit main

  Path                        ImageDiffs
  ----                        ----------
  C:\repo\path\File1.vi       {JFoOfu_File1_connector, JFoOfu_File1_frontpanel_Resized,JFoOfu_File1_blockdiagram}
  C:\repo\path\File2.vi       {3v3qjk_File2_connector, 3v3qjk_File2_frontpanel,3v3qjk_File2_blockdiagram}
  ```

- Output a merged before/after image (containing connector pane, front panel, and block diagram) per changed LabVIEW file:

  ```pwsh
  > Start-LvDiff -RepositoryPath <repo path>
  > Compare-LvFiles -NewCommit HEAD -BaseCommit main | ForEach-Object { $_.ImageDiffs | Merge-ImageDiffs }

  C:\users\<user>\AppData\Local\Temp\tmpB202\Before.png
  C:\users\<user>\AppData\Local\Temp\tmpB202\After.png
  C:\users\<user>\AppData\Local\Temp\tmpD192\Before.png
  C:\users\<user>\AppData\Local\Temp\tmpD192\After.png
  ```

  Or, using the same output directory for all files:

  ```pwsh
  > Start-LvDiff -RepositoryPath <repo path>
  > $outputPath = New-TemporaryPath
  > Compare-LvFiles -OutputPath $outputPath -NewCommit HEAD -BaseCommit main |
        ForEach-Object { $i = 0 } {
            $i += 1
            Merge-ImageDiffs `
                -OutputPath $outputPath `
                -BeforeName "Before$i" `
                -AfterName "After$i" `
                -ImageDiffs $_.ImageDiffs[$i]
        }
  ```

If `Start-LvDiff` is to be used multiple times in the same PowerShell session, `Stop-LvDiff` should be called before calling `Start-LvDiff` with a different repository e.g.:

```pwsh
try {
    Start-LvDiff -RepositoryPath <repo path>
    ...
} finally {
    Stop-LvDiff
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

LabVIEW Git Diff Scripts is released under the [MIT License](LICENSE.md)
