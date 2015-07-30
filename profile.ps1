# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024
$env:PSModulePath += ";$PSScriptRoot\Modules"

# PsReadline is already included in Windows 10, no need to have it in modules
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    $env:PSModulePath += ";$PSScriptRoot\LegacyModules"
}

$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["edit:NewEditor"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:AutoComplete"] = $true

# Was fixed in Windows 10
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"
}

Set-Alias new New-Object
Set-Alias rename Rename-Item
Set-Alias m Measure-Object
Set-Alias gite "c:\programs\GitExtensions\GitExtensions.exe"

# Environment setup
$addToPath =
    "c:\tools\BeyondCompare4\",
    "c:\tools\SysinternalsSuite\",
    "c:\tools\Vim\vim74\",
    "c:\tools\ILSpy\",
    "c:\tools\Lens\",
    "c:\tools\LinqPad\",
    "c:\tools\Multitran\network",
    "c:\tools\Tagger\",
    "c:\tools\TeamHub\",
    "c:\tools\WinDirStat\",
    "c:\tools\xts\"

$env:Path += ";" + ($addToPath -join ";")
$env:SdEditor = "gvim.exe"
$env:TERM = "msys"

# CoreXTAutomation setup
${GLOBAL:CoreXTAutomation.CodeFlow} = "\\codeflow\public\cfdog.cmd"

# Additional setup
# 00:00:00.0140114
. $PSScriptRoot\Scripts\Playground.ps1
# 00:00:00.0100053
. $PSScriptRoot\Scripts\Load-Functions.ps1
# 00:00:00.1971376 - TODO: not needed on Win10, exclude from profile as well
. $PSScriptRoot\Scripts\Set-ConsoleFont.ps1 | Out-Null
Remove-Variable proc    # hides pro<tab> = profile
# 00:00:00.2531752 - TODO: optimize
. $PSScriptRoot\Scripts\Initialize-Computer.ps1
# #00:00:00.4593232 - TODO: try to optimize (hard - majority of time is spent in color schema redifinition)
. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
# 00:00:00.0170141
. $PSScriptRoot\Scripts\Initialize-Prompt.ps1


# Windows 10 has beatifull maximized powershell window
if( [Environment]::OSVersion.Version.Major -ge 10 )
{
    # 00:00:00.1370967
    Set-WindowStyle MAXIMIZE
}

# That's hacky...
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
