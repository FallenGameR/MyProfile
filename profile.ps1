$SCRIPT:profiling = get-date
$SCRIPT:profilingCounter = 1

function SCRIPT:profile
{
    $now = get-date
    $message = "{0:00} # {1}" -f $profilingCounter, ($now - $profiling)
    Write-Host $message -fore darkgreen
    $SCRIPT:profiling = $now
    $SCRIPT:profilingCounter +=1
}

# Powershell behaviour setup
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024
$env:PSModulePath += ";$PSScriptRoot\Modules"
profile # 00:00:00.0080076

$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["edit:NewEditor"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:AutoComplete"] = $true
profile # 00:00:00.0280170

# Was fixed in Windows 10
if( [Environment]::OSVersion.Version.Major -lt 10 )
{
    Update-FormatData -PrependPath "$PSScriptRoot\Format.Custom.ps1xml"
    profile # 00:00:00.1010683
}

Set-Alias new New-Object
Set-Alias rename Rename-Item
Set-Alias m Measure-Object
Set-Alias gite "c:\programs\GitExtensions\GitExtensions.exe"
profile # 00:00:00.0050020

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
profile # 00:00:00.0060029

# Additional setup
. $PSScriptRoot\Scripts\Playground.ps1
profile # 00:00:00.0140114
. $PSScriptRoot\Scripts\Load-Functions.ps1
profile # 00:00:00.0100053
. $PSScriptRoot\Scripts\Set-ConsoleFont.ps1 | Out-Null
profile # 00:00:00.1971376
. $PSScriptRoot\Scripts\Initialize-Computer.ps1
profile # 00:00:00.2531752
. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
profile # 00:00:00.6534536
. $PSScriptRoot\Scripts\Initialize-Prompt.ps1
profile # 00:00:00.0170141

# Cleaning up variables
Remove-Variable proc    # Don't know who populates this constant, but it hides pro<tab> = profile

# Windows 10 has beatifull maximized powershell window
if( [Environment]::OSVersion.Version.Major -ge 10 )
{
    Set-WindowStyle MAXIMIZE
}
profile # 00:00:00.1370967

# That's hacky...
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"
profile # 00:00:00.0120067
