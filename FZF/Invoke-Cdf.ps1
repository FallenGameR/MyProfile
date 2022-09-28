# This allows us to control
# - what folders are excluded (hidden folders and files and folders that start with dot like .git)
# - in what order do we see the output (simialar to ls order)
# - make sure that we use command that is OneDrive friendly (Linux find downloads everything while enumerating)
# - allow fzf to terminate output early (piped in input blocks fzf from exit)
#
# BUG: doesn't work with Cyrillic folders
<#
rust analon requirements:
- work with cyrillic folders
- work with OneDrive folders
- support excluded folders (env vars / settings file)
- support both folder (cdf) and file and folder (codef) scenarios
- be fast
- work on relative paths (normalization)
- traverse files first then drill into folders
- support quick access (env vars) - add it to the end of list???

#>

$excludedFolders = ".git", ".pkgrefgen", "bin", "obj", "objd", "TestResults"
$commonPathPrefixLength = $pwd.ToString().Length + 1

function find_folders($root)
{
    Get-ChildItem $root -Directory -ea Ignore
}

function normalize($path)
{
    $path.FullName.Substring($commonPathPrefixLength)
}

function find_recursive($root)
{
    # Current level
    $folders = find_folders $root
    $folders | %{ normalize $psitem }

    # Then recurse into every folder if it is not excluded
    foreach( $folder in $folders | where Name -notin $excludedFolders )
    {
        find_recursive $folder
    }
}

function quick_access
{
    "$env:HOME\Downloads"
    "$env:HOME\Documents"
    #"$env:OneDriveConsumer"
    #"$env:OneDriveCommercial"
    $env:FZF_QUICK_PATHS -split ";"
}

filter normalize_quick_access
{
    $psitem | where{ Test-Path $psitem -ea Ignore } | foreach{ [System.IO.Path]::GetFullPath($psitem) }
}

if( $env:FZF_IS_QUICK )
{
    quick_access | normalize_quick_access
}

find_recursive "."