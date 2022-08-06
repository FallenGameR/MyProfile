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
$global:MaximumHistoryCount = 1024

# Make sure modules path is not lost (it should be present but some times it is not)
$modules = Join-Path (Split-Path $profile) Modules
if( -not $env:PSModulePath.Contains($modules) )
{
    $env:PSModulePath += ";$modules"
}
tm init

# Default command arguments
$PSDefaultParameterValues["Get-Command:All"] = $true
tm defaults

# Was fixed in Windows 10
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"
}

Set-Alias new New-Object
Set-Alias m Measure-Object
tm alias

# Environment setup
. $PSScriptRoot\Scripts\Environment.ps1
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

# That's hacky... but it can dot script other script here
if( -not (Test-Path "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1"
tm ProtectedPlayground