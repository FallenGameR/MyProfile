[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars')]
param()

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

# Powershell behavior setup
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
tm environment

# Additional setup
. $PSScriptRoot\Scripts\Playground.ps1
tm playground

. $PSScriptRoot\Scripts\Load-Functions.ps1
Remove-Variable proc -ea Ignore # hides pro<tab> = profile
tm func

. $PSScriptRoot\Scripts\Initialize-Computer.ps1
tm comp

. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
tm psreadline

. $PSScriptRoot\Scripts\Initialize-Prompt.ps1
tm prompt


# That's hacky... but it can dot script other script here
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
tm ProtectedPlayground

$enableTiming = $true