# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024

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
    "c:\tools\Ticino\",
    "c:\tools\WinDirStat\",
    "c:\tools\xts\"

$env:Path += ";" + ($addToPath -join ";")
$env:SdEditor = "gvim.exe"
$env:TERM = "msys"

# CoreXTAutomation setup
${GLOBAL:CoreXTAutomation.CodeFlow} = "\\codeflow\public\cfdog.cmd"

# Additional setup
. $PSScriptRoot\Helpers\Playground.ps1
. $PSScriptRoot\Helpers\Set-ConsoleFont.ps1 | Out-Null
. $PSScriptRoot\Helpers\Initialize-Computer.ps1
. $PSScriptRoot\Helpers\Initialize-PsReadLine.ps1
. $PSScriptRoot\Helpers\Initialize-Prompt.ps1

# Cleaning up variables
Remove-Variable proc    # Don't know who populates this constant, but it hides pro<tab> = profile

# That's hacky...
if( -not (Test-Path "E:\OneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "E:\OneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
