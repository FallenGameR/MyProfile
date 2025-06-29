﻿# Profile for any PowerShell host on WindowsInitialize-Apps.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Scripts/Utils.ps1

# Import-AsDotSource causes all $SCRIPT variables to be global

. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Computer.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-$(Get-Platform).ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Computer/$SCRIPT:hostName.ps1"
. Import-AsDotSource "$PSScriptRoot/Scripts/Initialize-Functions.ps1"
. Import-AsDotSource "$env:OneDriveCommercial/Projects/ProtectedPlayground.ps1" (Test-Windows)

$env:PSModulePath = "C:\tools\apShell;$env:PSModulePath"
