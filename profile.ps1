[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$enableTiming = $false

function tm($info = "=>")
{
    if( $enableTiming )
    {
        Write-Host "$($stopwatch.ElapsedMilliseconds / 1000) $info"
        $stopwatch.Restart()
    }
}

# Powershell behavior setup
$global:Profile = $PSCommandPath

# Modules path as profile subfolder
$modules = Join-Path (Split-Path $profile) Modules
if( -not $env:PSModulePath.Contains($modules) )
{
    $separator = if( $PSVersionTable.Platform -eq "Unix" ) {":"} else {";"}
    $env:PSModulePath += $separator + $modules
}
tm init

# Default command arguments
$PSDefaultParameterValues["Get-Command:All"] = $true
tm defaults

# Aliases
Set-Alias m Measure-Object
Set-Alias ls Get-ChildItem
tm alias

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
$host.privatedata.ProgressBackgroundColor = "DarkCyan"
$host.privatedata.ProgressForegroundColor = "White"

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