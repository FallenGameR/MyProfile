[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Scripts/Initialize-Helpers.ps1

# Import-AsDotSource causes all $SCRIPT variables to be global

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-OS.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Apps.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/$(Get-Platform)/Initialize-OS.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/$(Get-Platform)/Initialize-Apps.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Fzf.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Computer/$SCRIPT:hostName/Initialize-Computer.ps1"
. Import-AsDotSource "$PSScriptRoot/playground.ps1"
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
#If (Test-Path "c:\tools\miniconda3\Scripts\conda.exe") {
#    (& "c:\tools\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
#}
#endregion

$env:Path = "$env:Path;C:\tools\FcShell"
$env:Path = "$env:Path;C:\tools\dcm.explorer"
$env:Path = "$env:Path;C:\tools\xts"
$env:Path = "$env:Path;C:\tools\drop"
$env:Path = "$env:Path;C:\tools\lens"
$env:Path = "$env:Path;C:\tools\prorab"

$env:PSModulePath = "C:\tools\JitShell;$env:PSModulePath"
$env:PSModulePath = "D:\src\mv\src\Client\NTP\scripts\modules;$env:PSModulePath"
$env:PSModulePath = "C:\src\mv\src\Client\NTP\scripts\modules;$env:PSModulePath"
$env:PSModulePath = "$env:PSModulePath;C:\tools\DriScripts"
