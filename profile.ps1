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
$PSDefaultParameterValues["Enter-PhxMachine:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Enter-TunnelSession:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Get-TunnelSession:TwoFactorAuth"] = $true
$PSDefaultParameterValues["Invoke-ApTool:TwoFactorAuth"] = $true


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

# Additional setup
# 00:00:00.0140114
. $PSScriptRoot\Scripts\Playground.ps1
# 00:00:00.0100053
. $PSScriptRoot\Scripts\Load-Functions.ps1
# 00:00:00.1971376 - TODO: not needed on Win10, exclude from profile as well
. $PSScriptRoot\Scripts\Set-ConsoleFont.ps1 | Out-Null
Remove-Variable proc -ea Ignore # hides pro<tab> = profile
# 00:00:00.2531752 - TODO: optimize
. $PSScriptRoot\Scripts\Initialize-Computer.ps1
# #00:00:00.4593232 - TODO: try to optimize (hard - majority of time is spent in color schema redifinition)
. $PSScriptRoot\Scripts\Initialize-PsReadLine.ps1
# 00:00:00.0170141
. $PSScriptRoot\Scripts\Initialize-Prompt.ps1

# Setup for tye fuck program
# https://github.com/nvbn/thefuck/wiki/Shell-aliases
# Update: pip.exe install thefuck --upgrade
# Requirement - latest python installed and availabe in path
#
# Interesting commands:
# cd_correction  – spellchecks and correct failed cd commands;
# cd_mkdir  – creates directories before cd'ing into them;
# dirty_unzip  – fixes  unzip  command that unzipped in the current directory;
# dry  – fixes repetitions like  git git push ;
# git_branch_delete  – changes  git branch -d  to  git branch -D ;
# git_branch_list  – catches  git branch list  in place of  git branch  and removes created branch;
# git_checkout  – fixes branch name or creates new branch;
# git_help_aliased  – fixes  git help <alias>  commands replacing with the aliased command;
# git_pull  – sets upstream before executing previous  git pull ;
# git_push_pull  – runs  git pull  when  push  was rejected;
# git_stash  – stashes you local modifications before rebasing or switching branch;
# git_two_dashes  – adds a missing dash to commands like  git commit -amend  or  git rebase -continue ;
# has_exists_script  – prepends  ./  when script/binary exists;
# history  – tries to replace command with most similar command from history;
# sed_unterminated_s  – adds missing '/' to  sed 's  s  commands;
# sl_ls  – changes  sl  to  ls ;
# switch_lang  – switches command from your local layout to en;
function fuck
{
    $fuck = $(thefuck (Get-History -Count 1).CommandLine)
    if (-not [string]::IsNullOrWhiteSpace($fuck))
    {
        if ($fuck.StartsWith("echo")) { $fuck = $fuck.Substring(5) }
        else { iex "$fuck" }
    }
}

# That's hacky... but it can dot script other script here
if( -not (Test-Path "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\ProtectedPlayground.ps1"

if( -not (Test-Path "$oneDriveMicrosoft\Projects\Deployments\scripts\Deployment.ps1") )
{
    return
}
. "$oneDriveMicrosoft\Projects\Deployments\scripts\Deployment.ps1"

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
