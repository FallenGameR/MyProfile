$jumpbox = "netjb1-westus2.phx.gbl"

$env:Path += ";C:\Program Files\Ripgrep\"
$env:Path += ";C:\tools\FcShell"
$env:Path += ";C:\tools\dcm.explorer"
$env:Path += ";C:\tools\xts"
$env:Path += ";C:\Program Files\Drop\lib\net45"
$env:Path += ";C:\tools\lens"
$env:Path += ";C:\tools\prorab"

$env:PSModulePath = "C:\tools\JitShell;$env:PSModulePath"
$env:PSModulePath = "C:\tools\TipNodeServiceAME;$env:PSModulePath"
$env:PSModulePath = "$env:PSModulePath;C:\tools\DriScripts"

Set-DsSetting -XtsApiClouds "PilotFish", "ApClassic", "Fairfax", "FairfaxDoD", "Mooncake", "Bleu"
Set-DsSetting -CockpitQueryFolder "C:\tools\CockpitQueryTest"

function s1( $name ) { \\alexko-11\NTP\scripts\s1-tools\Initialize-Stratum1.ps1 $name | code - }
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

tm (Split-Path $PSCommandPath -Leaf)
