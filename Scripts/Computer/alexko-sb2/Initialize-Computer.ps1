Complete-Once "Computer-specific environment vars" {
    Set-EnvironmentVariable "AzCompute" "c:\src\mv\"
    Set-EnvironmentVariable "ApGold" "c:\src\gold\ap\"
    Set-EnvironmentVariable "PfGold" "c:\src\gold\pf\"
    Set-EnvironmentVariable "NTP" "C:\src\ntp\"
}

Set-DsSetting -CockpitQueryFolder "c:\tools\DriScripts\CockpitQuery\"

$env:Path = "$env:Path;C:\tools\FcShell"
$env:Path = "$env:Path;C:\tools\dcm.explorer"
$env:Path = "$env:Path;C:\tools\xts"
$env:Path = "$env:Path;C:\tools\drop"
$env:Path = "$env:Path;C:\tools\lens"
$env:Path = "$env:Path;C:\tools\prorab"
$env:Path = "$env:Path;C:\tools\oneAccess"

$env:PSModulePath = "C:\src\mv\src\Client\NTP\scripts\modules;$env:PSModulePath"
$env:PSModulePath = "C:\tools\JitShell;$env:PSModulePath"
$env:PSModulePath = "C:\tools\TipNodeServiceAME;$env:PSModulePath"
$env:PSModulePath = "$env:PSModulePath;C:\tools\DriScripts"

tm (Split-Path $PSCommandPath -Leaf)
