# Profile for any PowerShell host on WindowsInitialize-Apps.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

# Functions that are used in all scripts, including this one
. $PSScriptRoot/Scripts/Utils.ps1
$computer = Get-ComputerEnvironment

# Note that Import-AsDotSource causes all $SCRIPT variables to be global, this may need to be fixed

# OS things
. Import-AsDotSource "$PSScriptRoot/Scripts/Platform/Initialize-Common.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Platform/Initialize-$($computer.Platform).ps1"

# Location things, computer-specific script inits environment variables consumed by location
. Import-AsDotSource "$PSScriptRoot/Scripts/Computer/$($computer.Name).ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Location/Initialize-$($computer.Location).ps1"

# Powershell environment
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Functions.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))

# Playgrdoun
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)

