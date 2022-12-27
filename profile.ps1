[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Common/Initialize-Helpers.ps1
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Vars.ps1"
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Common.ps1"
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Windows.ps1" (Test-Windows)
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-WindowsElevated.ps1" ((Test-Windows) -and (Test-Elevated))
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Unix.ps1" (Test-Unix)
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Prompt.ps1"
. Import-AsDotSource "$PSScriptRoot/Common/Initialize-Fzf.ps1"
. Import-AsDotSource "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1" (Test-Windows)

if( $PSVersionTable.Platform -eq "Unix" )
{
    return
}

tm prompt

. Import-AsDotSource "$PSScriptRoot\Scripts\Playground.ps1"
tm playground

# Conditional dot sourcing
function Import-ProtectedPlayground
{
    $path = "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1"
    if( -not (Test-Path $path) ) { return }
    . $path
}

. Import-ProtectedPlayground
tm ProtectedPlayground