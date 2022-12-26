[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$global:Profile = $PSCommandPath

. $PSScriptRoot/Common/Initialize-Helpers.ps1
. Import-AsDotSource "$PSScriptRoot/Common/Import-ComputerVars.ps1"
Import-AsInvoke "$PSScriptRoot/Common/Initialize-PreOs.ps1"
Import-AsInvoke "$PSScriptRoot/Common/Initialize-Windows.ps1" ($PSVersionTable.Platform -eq "Windows")
Import-AsInvoke "$PSScriptRoot/Common/Initialize-WindowsElevated.ps1" (($PSVersionTable.Platform -eq "Windows") -and (Test-Elevated))
Import-AsInvoke "$PSScriptRoot/Common/Initialize-Unix.ps1" ($PSVersionTable.Platform -eq "Unix")
Import-AsInvoke "$PSScriptRoot/Common/Initialize-PostOs.ps1"
Import-AsInvoke "$PSScriptRoot/Common/Initialize-PsReadLine.ps1" (-not (Test-ProcessRedirected (Get-Process -Id $pid)))

if( $PSVersionTable.Platform -eq "Unix" )
{
    return
}

# Unclear if still needed
# Remove-Variable proc -ea Ignore # hides pro<tab> = profile

. Import-AsDotSource "$PSScriptRoot\Scripts\Initialize-Prompt.ps1"
tm prompt

# For some reason they changed progress color in PS 7.1.1
$host.privatedata.ProgressForegroundColor = "White"
$host.privatedata.ProgressBackgroundColor = "DarkCyan"

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