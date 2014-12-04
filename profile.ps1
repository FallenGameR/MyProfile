# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024

$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["edit:NewEditor"] = $true

Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"

New-Alias new New-Object
New-Alias rename Rename-Item
New-Alias m measure

# Environment setup
$addToPath =
    "c:\tools\BeyondCompare4\",
    "c:\tools\SysinternalsSuite\",
    "c:\tools\Vim\vim74\",
    "c:\tools\ILSpy\",
    "c:\tools\LinqPad\"

$env:Path += ";" + ($addToPath -join ";")
$env:SdEditor = 'C:\tools\Vim\vim73\gvim.exe'

#Set-StrictMode -Off

Import-Module PsReadLine

# Setting up PSReadLine
$colors =
@{
    Command = "DarkCyan"
    Comment = "DarkGreen"
    Keyword = "Gray"
    Number = "DarkGray"
    Member = "DarkCyan"
    Operator = "DarkRed"
    Parameter = "DarkMagenta"
    String = "DarkYellow"
    Type = "DarkCyan"
    Variable = "DarkGray"
}
foreach( $token in $colors.Keys ) { Set-PSReadlineOption -ForegroundColor ($colors.$token) -TokenKind $token }
Set-PSReadlineKeyHandler -Chord "Ctrl+D,Ctrl+C" -Function CaptureScreen

# CoreXTAutomation setup
${GLOBAL:CoreXTAutomation.CodeFlow} = "\\codeflow\public\cfdog.cmd"

# Additional setup
. $PSScriptRoot\Helpers\Playground.ps1
. $PSScriptRoot\Helpers\Set-ConsoleFont.ps1 | Out-Null
. $PSScriptRoot\Helpers\Initialize-Prompt.ps1
