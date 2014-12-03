Set-StrictMode -Off

# Fix font
. $PSScriptRoot\Helpers\SetConsoleFont.ps1 | Out-Null

# Global variables
$global:Profile = $PSCommandPath
$global:MaximumHistoryCount = 1024

# Show all matching commands by default
$PSDefaultParameterValues["Get-Command:All"] = $true
$PSDefaultParameterValues["Set-Content:Encoding"] = "ASCII"

# Use custom formatting for gcm command
Update-FormatData -PrependPath "c:\Users\alexko\Documents\WindowsPowerShell\Format.Custom.ps1xml"

# Includes
#. Add-RelativePathCapture.ps1
#. Playground.ps1
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

# For SD
$env:sdeditor = 'C:\tools\Vim\vim73\gvim.exe'

# Aliases
New-Alias new new-Object
New-Alias rename Rename-Item
New-Alias delete Remove-Item
New-Alias o Out-GridView
New-Alias m measure

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
    Set-ConsoleFont 10

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
