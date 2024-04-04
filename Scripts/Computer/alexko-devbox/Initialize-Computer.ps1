Complete-Once env-computer {
    Set-EnvironmentVariable "AzCompute" "C:\src\Azure-Compute-Move\"
    Set-EnvironmentVariable "ApGold" "c:\src\Config-AfGold"
    Set-EnvironmentVariable "PfGold" "c:\src\Config-PfGold"
    Set-EnvironmentVariable "NTP" "c:\src\ntp\"
}

Complete-Once junction-one-drive-ms {
    New-Item -ItemType Junction -Name "D:\OneDrive.MS" -Target $env:OneDriveCommercial -ea Ignore
    Set-EnvironmentVariable "OneDriveCommercial" "D:\OneDrive.MS"
}

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
