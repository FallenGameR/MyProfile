. $PSScriptRoot\Initialize-Work.ps1

# Tools availability
$env:Path += ";C:\Program Files\Drop\lib\net45\"
$env:Path += ";C:\Program Files\SSTool\"
$env:Path += ";C:\tools\dsmsClient\DsmsClient"

$env:path += ";C:\Program Files\bat"
$env:path += ";C:\Program Files\chafa"
$env:path += ";C:\Program Files\delta"
$env:path += ";C:\Program Files\fd"
$env:path += ";C:\Program Files\Ripgrep\"
$env:path += ";C:\Program Files\Yazi"
$env:path += ";C:\Program Files\glow"


$env:FZF_DEFAULT_COMMAND = 'fd -I --type f --color always'

# mkdir "$env:APPDATA\fd" -ea Ignore | Out-Null
# "bin", "cache", "Help", "obj", "objd", "out", "target", "TestResults" > "$env:APPDATA\fd\ignore"

# DriScripts plus FzfBindings init
function ds
{
    Import-Module DriScripts
    Import-Module FzfBindings

    DriScripts\Register-Shortcut "Alt+g" "code" "Code open"
    DriScripts\Register-Shortcut "Alt+c" "git commit -a" "Git commit dialog"
    DriScripts\Register-Shortcut "Alt+b" "git lg" "Git commit browser"

    DriScripts\Register-Shortcut "Alt+h" "hf" "History search"
    DriScripts\Register-Shortcut "Alt+o" "startf" "Open file"
    DriScripts\Register-Shortcut "Alt+r" "rgf" "Ripgrep search"
    DriScripts\Register-Shortcut "Alt+k" "killf" "Kill process"
    DriScripts\Register-Shortcut "Alt+f" "codef" "Code to open file or directory"
    DriScripts\Register-Shortcut "Alt+v" "codef" "Code to open file or directory (shortcut from Vim"
    DriScripts\Register-Shortcut "Alt+d" "cdf" "Change directory"
    DriScripts\Register-Shortcut "Alt+u" "pushf" "Go up fuzzy"
    DriScripts\Register-Shortcut "Alt+s" "Select-GitBranch" "Switch to a git branch"
    DriScripts\Register-Shortcut "Alt+p" "Send-GitBranch" "Pull request for a git branch"
    DriScripts\Register-Shortcut "Alt+l" "Clear-GitBranch" "Clear a completed pull request for a git branch"
}

# DriScripts for some reason are not auto-resolved
# Cant import signed modules in profile on SAW o_O

tm (Split-Path $PSCommandPath -Leaf)

