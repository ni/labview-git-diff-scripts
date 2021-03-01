<#
    .SYNOPSIS
    .DESCRIPTION
#>
Add-Type -TypeDefinition @"
using System.IO;

namespace NI
{
    public enum ChangeType
    {
        Added,
        Removed,
        Modified,
        Unclassified,
    }

    public class ChangedFile
    {
        public ChangedFile(string repositoryPath, string diffLine)
        {
            var parts = diffLine.Split('\t');
            var code = parts[0];

            this.Path = System.IO.Path.Combine(repositoryPath, parts[1]);
            this.ChangeType = GetChangeTypeForCode(code);
        }

        public string Path { get; private set; }
        public ChangeType ChangeType { get; private set; }

        private ChangeType GetChangeTypeForCode(string code)
        {
            switch (code) {
                case "A":
                    return ChangeType.Added;
                case "D":
                    return ChangeType.Removed;
                case "M":
                    return ChangeType.Modified;
                default:
                    return ChangeType.Unclassified;
            }
        }
    }

    public class ImageDiff
    {
        public ImageDiff(string beforeImagePath, string afterImagePath)
        {
            this.BeforeImagePath = beforeImagePath;
            this.AfterImagePath = afterImagePath;

            this.BeforeImageName = Path.GetFileNameWithoutExtension(BeforeImagePath);
            this.AfterImageName = Path.GetFileNameWithoutExtension(AfterImagePath);
        }

        public string BeforeImagePath { get; private set; }
        public string AfterImagePath { get; private set; }

        public string BeforeImageName { get; private set; }
        public string AfterImageName { get; private set; }
    }
}
"@