[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Scripts/Initialize-Helpers.ps1

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-WindowsApps.ps1" (Test-Windows)
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Windows.ps1" (Test-Windows)
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-WindowsElevated.ps1" ((Test-Windows) -and (Test-Elevated))

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-UnixApps.ps1" (Test-Unix)
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Unix.ps1" (Test-Unix)

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-AnyOS.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Fzf.ps1"

. Import-AsDotSource "$PSScriptRoot/Scripts/$SCRIPT:hostName/Initialize-Computer.ps1"
. Import-AsDotSource "$PSScriptRoot/playground.ps1"
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)
