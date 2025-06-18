# Profile for any PowerShell host on WindowsInitialize-Apps.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Scripts/Initialize-Helpers.ps1

# Import-AsDotSource causes all $SCRIPT variables to be global

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Env.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Apps.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Platform/Initialize-$(Get-Platform)-Env.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Platform/Initialize-$(Get-Platform)-Apps.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Computer/Initialize-$SCRIPT:hostName.ps1"
. Import-AsDotSource "$PSScriptRoot/playground.ps1"
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
#If (Test-Path "c:\tools\miniconda3\Scripts\conda.exe") {
#    (& "c:\tools\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
#}
#endregion

$env:PSModulePath = "C:\tools\apShell;$env:PSModulePath"
