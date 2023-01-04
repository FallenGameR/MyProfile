[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Scripts/Initialize-Helpers.ps1

. Import-AsDotSource "$PSScriptRoot/Scripts/$(Get-Platform)/Initialize-Apps.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/$(Get-Platform)/Initialize-Root.ps1" (Test-Elevated)
. Import-AsDotSource "$PSScriptRoot/Scripts/$(Get-Platform)/Initialize-System.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-AnyOS.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Fzf.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/Computer/$SCRIPT:hostName/Initialize-Computer.ps1"
. Import-AsDotSource "$PSScriptRoot/playground.ps1"
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)
