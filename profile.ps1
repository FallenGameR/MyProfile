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
$addToPath =
"C:\Program Files\Beyond Compare 4\",
"C:\Program Files (x86)\WinDirStat\",
"C:\Program Files (x86)\LINQPad5\"

$env:Path += ";" + ($addToPath -join ";")
$env:LESS = "-IeFRX"
$env:BAT_THEME = "Visual Studio Dark+"
$env:RIPGREP_CONFIG_PATH = "$PSScriptRoot\rg.config"
#$env:DELTA_PAGER = "0" # By default it uses less with -R incompatible switch set - but this breaks git
$env:FZF_DEFAULT_OPTS = "--layout=reverse --height 60% --info=hidden --tabstop=4 -m --cycle"

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

# fe, fh, fkill, fd, frg
# codef, hf, killf, cdf, rgf
Set-PSFzfOption -EnableAliasFuzzyEdit
Set-PSFzfOption -EnableAliasFuzzyHistory
Set-PSFzfOption -EnableAliasFuzzyKillProcess
Set-PSFzfOption -EnableAliasFuzzySetLocation
Set-PsFzfOption -PSReadlineChordProvider 'Alt+f' -PSReadlineChordReverseHistory "Alt+h"
Set-PsFzfOption -TabExpansion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-Alias frg Invoke-PsFzfRipgrep

Set-Alias codef Invoke-FuzzyEdit
Set-Alias hf Invoke-FuzzyHistory
Set-Alias killf Invoke-FuzzyKillProcess
Set-Alias cdf Invoke-FuzzySetLocation
Set-Alias rgf Invoke-PsFzfRipgrep
tm pffzf

. $PSScriptRoot\Scripts\Initialize-Prompt.ps1
tm prompt

# For some reason they changed progress color in PS 7.1.1
$host.privatedata.ProgressBackgroundColor = "DarkCyan"
$host.privatedata.ProgressForegroundColor = "White"

# That's hacky... but it can dot script other script here
if( -not (Test-Path "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$env:OneDriveCommercial\Projects\ProtectedPlayground.ps1"
tm ProtectedPlayground

$enableTiming = $true