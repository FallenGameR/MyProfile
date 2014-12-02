Set-StrictMode -Off

. C:\Users\alexko\Dropbox\Tools\Powershell\SetConsoleFont.ps1 | Out-Null
Set-ConsoleFont 10

# Global variables
$global:Profile = $myInvocation.MyCommand.Path
$global:MaximumHistoryCount = 1024
$scriptroot = "C:\src\autopilot\ap_git\"

# Show all matching commands by default
$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"
$PSDefaultParameterValues["Get-RemoteSession:CredSSP"] = $true
$PSDefaultParameterValues["Enter-RemoteSession:CredSSP"] = $true

$PSDefaultParameterValues["Enter-PhxSession:ComputerName"] = "CO3SCH010010102"
$PSDefaultParameterValues["Get-PhxSession:ComputerName"] = "CO3SCH010010102"
$PSDefaultParameterValues["Get-PhxSession:Reconnect"] = $true

$PSDefaultParameterValues["Enter-TunnelSession:ComputerName"] = "CO3SCH010010102"
$PSDefaultParameterValues["Get-TunnelSession:ComputerName"] = "CO3SCH010010102"
$PSDefaultParameterValues["Get-TunnelSession:Reconnect"] = $true

# Use custom formatting for gcm command
Update-FormatData -PrependPath "c:\Users\alexko\Documents\WindowsPowerShell\Format.Custom.ps1xml"

# Includes
#Import-Module "$scriptroot\private\tools\CoreXTAutomation\CoreXTAutomation.psd1" -DisableNameChecking
#Import-Module "$scriptroot\private\tools\PHXAutomation\PHXAutomation.psd1" -DisableNameChecking
#Import-Module s:\codebox\NetworkValidator\Scripts\NetworkValidator.psd1 -DisableNameChecking 3>$null
Import-Module "c:\src\opensource\AntlrAutomation\Module\AntlrAutomation.psd1" -DisableNameChecking
Import-Module "$scriptroot\private\tools\AclAnalysis\Libs\Pester\2.0.3\Pester.psm1" -DisableNameChecking
$env:Path += ";$scriptroot\private\developer\alexko\scripts\Environment\"
$env:Path += ";$scriptroot\private\developer\alexko\scripts\"
$env:Path += ";c:\tools\TeamHub\"
$env:Path += ";c:\tools\git-tf\git-tf-2.0.0.20121030\"
. Add-RelativePathCapture.ps1
. Playground.ps1
Import-Module PsReadLine
Set-StrictMode -Off

# Setting up PSReadLine
$colors = @{
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

# For Git
$env:GIT_ASK_YESNO = "false"
$env:TERM = "msys"

# For SD
$env:sdeditor = 'C:\tools\Vim\vim73\gvim.exe'

# Aliases
New-Alias new new-Object
New-Alias rename Rename-Item
New-Alias delete Remove-Item
New-Alias o Out-GridView
New-Alias m measure

# Drives
New-PSDrive core FileSystem $scriptroot\private\tools\CoreXTAutomation > $null
New-PSDrive phx FileSystem $scriptroot\private\tools\PHXAutomation > $null

# History folder and file
$SCRIPT:history = "c:\automation\history\"
if( -not (Test-Path $history) )
{
    mkdir $history 2>&1 | Out-Null
}
$timeStamp = [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz")
$SCRIPT:historyFile = "$history\$timestamp--$pid.ps1"
$SCRIPT:lastCommandId = -1

# Prompt
$function:prompt = {
    $realLastExitCode = $LASTEXITCODE

    # Preserve last command in log file
    $lastCommand = history -Count 1
    if( $lastCommand )
    {
        if( $lastCommand.Id -ne $SCRIPT:lastCommandId )
        {
            $SCRIPT:lastCommandId = $lastCommand.Id
            Add-Content $historyFile $lastCommand.CommandLine
        }
    }
    else
    {
        $lastCommandId = -1
        Add-Content $historyFile "# No history at this point of time"
    }

    # Update prompt
    $host.UI.RawUI.WindowTitle = "$pwd   [$Env:ComputerName]   $env:UserDomain\$env:UserName"
    Write-Host "$pwd" -ForegroundColor DarkYellow -NoNewline
    Write-Host " [$Env:ComputerName] $env:UserDomain\$env:UserName" -ForegroundColor DarkGreen
    $LASTEXITCODE = $realLastExitCode
    [char] 187 + " "
}

