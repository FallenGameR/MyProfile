# This allows us to control
# - what folders are excluded (hidden folders and files and folders that start with dot like .git)
# - in what order do we see the output (similar to ls order)
# - make sure that we use command that is OneDrive friendly (Linux find downloads everything while enumerating)
# - allow fzf to terminate output early (piped in input blocks fzf from exit)

function excluded_folders
{
    ".git"
    ".pkgrefgen"
    "bin"
    "cache"
    "obj"
    "objd"
    "out"
    "target"
    "TestResults"
}

function included_folders
{
    "$env:HOME/Downloads"
    "$env:HOME/Documents"
    $env:FZF_QUICK_PATHS -split ";"
}

$param = @()
$param += $pwd
$param += "-f" # don't show files, only directories

foreach( $excluded in excluded_folders )
{
    $param += "-e"
    $param += $excluded
}

foreach( $included in included_folders )
{
    $param += "-I"
    $param += $included
}

$walker = "$PsScriptRoot/../Bin/Walker/walker"
if( $PSVersionTable.Platform -eq "Windows" ) { $walker += ".exe" }
& $walker @param