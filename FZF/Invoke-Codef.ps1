# This allows us to control
# - what folders are excluded (hidden folders and files and folders that start with dot like .git)
# - in what order do we see the output (similar to ls order)
# - make sure that we use command that is OneDrive friendly (Linux find downloads everything while enumerating)
# - allow fzf to terminate output early (piped in input blocks fzf from exit)
#

function excluded_folders
{
    ".git"
    ".pkgrefgen"
    "bin"
    "obj"
    "objd"
    "target"
    "TestResults"
}

$param = @()
$param += $pwd
$param += "-d" # don't show directories, only files
$param += "-D" # traverse into .directories

foreach( $excluded in excluded_folders )
{
    $param += "-e"
    $param += $excluded
}

$walker = "$PsScriptRoot\..\Bin\Walker\walker.exe"
& $walker @param