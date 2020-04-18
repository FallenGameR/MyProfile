$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$enableTiming = $false
# pwsh -noprofile
# . "C:\Users\alexko\OneDrive - Microsoft\Documents\PowerShell\profile.ps1"

function tm($info = "=>")
{
    if( $enableTiming )
    {
        Write-Host "$info $($stopwatch.ElapsedMilliseconds / 1000)"
        $stopwatch.Restart()
    }
}

# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024
$env:PSModulePath += ";$PSScriptRoot\Modules"
tm init

# PsReadline is already included in Windows 10, no need to have it in modules
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    $env:PSModulePath += ";$PSScriptRoot\LegacyModules"
}

$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["edit:NewEditor"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:AutoComplete"] = $true
$PSDefaultParameterValues["Enter-PhxMachine:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Get-TunnelSession:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Invoke-ApTool:TwoFactorAuth"] = $true
tm defaults

# Was fixed in Windows 10
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"
}

Set-Alias new New-Object
Set-Alias rename Rename-Item
Set-Alias m Measure-Object
Set-Alias gite "c:\programs\GitExtensions\GitExtensions.exe"
tm alias

# Environment setup
$addToPath =
    "c:\tools\BeyondCompare4\",
    "c:\tools\SysinternalsSuite\",
    "c:\tools\Vim\vim74\",
    "c:\tools\ILSpy\",
    "c:\tools\Lens\",
    "c:\tools\LinqPad\",
    "c:\tools\Multitran\network\",
    "c:\tools\prorab\",
    "c:\tools\Tagger\",
    "c:\tools\TeamHub\",
    "c:\tools\WinDirStat\",
    "c:\tools\xts\",
    "c:\tools\odd\",
    "C:\tools\SdApi\",
    "e:\root\Compute\Core\NtpInvestigations\FcShell\",
    "f:\autopilot\move\src\Tools\Git\GitNuke\",
    "f:\autopilot\move\src\Tools\Git\GitTrack\"

$env:Path += ";" + ($addToPath -join ";")
$env:SdEditor = "gvim.exe"
$env:TERM = "msys"

# CoreXTAutomation setup
${GLOBAL:CoreXTAutomation.CodeFlow} = "\\codeflow\public\cfdog.cmd"
tm environent

# Additional setup
# 00:00:00.0140114
. $PSScriptRoot\Scripts\Playground.ps1
tm playground

# 00:00:00.0100053
. $PSScriptRoot\Scripts\Load-Functions.ps1
Remove-Variable proc -ea Ignore # hides pro<tab> = profile
tm func

# 00:00:00.2531752 - TODO: optimize
. $PSScriptRoot\Scripts\Initialize-Computer.ps1
tm comp

# #00:00:00.4593232 - TODO: try to optimize (hard - majority of time is spent in color schema redifinition)
. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
tm readline

# 00:00:00.0170141
. $PSScriptRoot\Scripts\Initialize-Prompt.ps1
tm prompt


# That's hacky... but it can dot script other script here
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
tm ProtectedPlayground

if( -not (Test-Path "$oneDriveMicrosoft\Projects\Deployments\scripts\Deployment.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\Deployments\scripts\Deployment.ps1"
tm Deployment

$enableTiming = $true