[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

# Elevated test
$SCRIPT:isElevated = Test-Elevated

# Don't use history in PsReadLine, it is buggy in the latest PS release
Set-PSReadlineOption -HistorySaveStyle SaveNothing

# History folder and file
$SCRIPT:historyFolder = "c:\automation\history\"
if( -not (Test-Path $historyFolder) )
{
    mkdir $historyFolder -ea Ignore | Out-Null
}
$SCRIPT:historyFile = "$historyFolder\{0}--$pid.ps1" -f [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz")
$SCRIPT:lastCommandId = -1

# Prompt
function prompt
{
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

    # Path to use
    $path = $pwd -replace [regex]::Escape("$($env:USERNAME).$($env:USERDOMAIN)"), $env:USERNAME

    # Update title
    if( $ExecutionContext.SessionState.LanguageMode -eq "FullLanguage" )
    {
        if( $GLOBAL:WindowTitle )
        {
            $host.UI.RawUI.WindowTitle = $GLOBAL:WindowTitle
        }
        else
        {
            function replace($all, $part, $short)
            {
                $all = $all -replace [regex]::Escape($part), $short
                if( $all ) { $all } else { $short + "\" }
            }

            $title = $path
            if( $env:home ) { $title = replace $title $env:home "~" }
            if( $env:inetroot )
            {
                $title = replace $title $env:inetroot ""
                $title = replace $title "\src\Client\NTP" "NTP"
                $title = replace $title "NTP\managed\Clockwork" "Clockwork"
                $title = replace $title "\data\Autopilot\NtpReferenceClock\Firmware" "Firmware"
            }
            $host.UI.RawUI.WindowTitle = $title
        }
    }

    # Update prompt
    Write-Host $path -ForegroundColor DarkYellow -NoNewline
    Write-Host " [$Env:ComputerName] " -ForegroundColor DarkGreen -NoNewline
    if( $SCRIPT:isElevated )
    {
        Write-Host " ELEVATED" -ForegroundColor DarkCyan -NoNewline
    }
    Write-Host ""

    $LASTEXITCODE = $realLastExitCode
    [char] 187 + " "
}
