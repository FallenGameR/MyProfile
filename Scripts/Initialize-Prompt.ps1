# Elevated test
$SCRIPT:isElevated = Test-Elevated

# History folder and file
$SCRIPT:historyFolder = "c:\automation\history\"
if( -not (Test-Path $historyFolder) )
{
    mkdir $historyFolder -ea Ignore | Out-Null
}
$SCRIPT:historyFile = "$historyFolder\{0}--$pid.ps1" -f [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz")
$SCRIPT:lastCommandId = -1

# Prompt
$function:prompt = {
    $realLastExitCode = $LASTEXITCODE

    # Preserve last command in log file
    $lastCommand = Get-History -Count 1
    if( $lastCommand )
    {
        if( $lastCommand.Id -ne $SCRIPT:lastCommandId )
        {
            $SCRIPT:lastCommandId = $lastCommand.Id
            Add-Content $historyFile $lastCommand.CommandLine.Replace("`n", "`r`n")
        }
    }
    else
    {
        $lastCommandId = -1
        Add-Content $historyFile "# No history at this point of time"
    }

    # Update title
    $title = "$pwd   [$Env:ComputerName]   $env:UserDomain\$env:UserName"
    if( $SCRIPT:isElevated )
    {
        $title += "   ELEVATED"
    }
    $host.UI.RawUI.WindowTitle = $title

    # Update prompt
    Write-Host "$pwd" -ForegroundColor DarkYellow -NoNewline
    Write-Host " [$Env:ComputerName] $env:UserDomain\$env:UserName" -ForegroundColor DarkGreen
    $LASTEXITCODE = $realLastExitCode
    [char] 187 + " "
}
