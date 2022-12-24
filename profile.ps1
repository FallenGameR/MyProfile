[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Common/Initialize-Helpers.ps1
Import-AsInvoke "$PSScriptRoot/Common/Initialize-PreOsSpecific.ps1"
Import-AsInvoke "$PSScriptRoot/Windows/Initialize-Windows.ps1" ($PSVersionTable.Platform -eq "Windows")
Import-AsInvoke "$PSScriptRoot/Unix/Initialize-Unix.ps1" ($PSVersionTable.Platform -eq "Unix")
Import-AsInvoke "$PSScriptRoot/Common/Initialize-PostOsSpecific.ps1"






# Environment setup
. $PSScriptRoot\Scripts\Initialize-Environment.ps1
tm environment

# Additional setup
. $PSScriptRoot\Scripts\Load-Functions.ps1
Remove-Variable proc -ea Ignore # hides pro<tab> = profile
tm func

. $PSScriptRoot\Scripts\Initialize-Computer.ps1
tm comp

. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
tm psreadline

. $PSScriptRoot\Scripts\Initialize-Prompt.ps1
tm prompt

# For some reason they changed progress color in PS 7.1.1
$host.privatedata.ProgressForegroundColor = "White"
$host.privatedata.ProgressBackgroundColor = "DarkCyan"

. $PSScriptRoot\Scripts\Playground.ps1
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