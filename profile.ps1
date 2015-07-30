# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024
$env:PSModulePath += ";$PSScriptRoot\Modules"

$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["edit:NewEditor"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:AutoComplete"] = $true

Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"

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
. $PSScriptRoot\Scripts\Playground.ps1
. $PSScriptRoot\Scripts\Load-Functions.ps1
. $PSScriptRoot\Scripts\Set-ConsoleFont.ps1 | Out-Null
. $PSScriptRoot\Scripts\Initialize-Computer.ps1
. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
. $PSScriptRoot\Scripts\Initialize-Prompt.ps1

# Cleaning up variables
Remove-Variable proc    # Don't know who populates this constant, but it hides pro<tab> = profile

# Windows 10 has beatifull maximized powershell window
Set-WindowStyle MAXIMIZE

# That's hacky...
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
