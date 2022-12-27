[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

# Elevated test
$SCRIPT:isElevated = Test-Elevated

# History folder and file
$SCRIPT:historyFolder = switch( $PSVersionTable.Platform )
{
    "Windows" { "c:\automation\history\" }
    "Unix" { "~\.pwsh_history\" }
    default { "pwsh_history" }
}

if( -not (Test-Path $historyFolder) )
{
    mkdir $historyFolder -ea Ignore | Out-Null
}

$SCRIPT:historyFile = Join-Path $historyFolder ("{0}--$pid.ps1" -f [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz"))
$SCRIPT:lastCommandId = -1

# Computername to use
$SCRIPT:hostName = switch( $PSVersionTable.Platform )
{
    "Windows" { $Env:ComputerName }
    "Unix" { hostname }
    default { "UNKNOWN" }
}

# Prompt
function prompt
{
    $realLastExitCode = $LASTEXITCODE
    $LASTEXITCODE = $realLastExitCode
    [char] 187 + " "
}

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
            $lineNormalized = $lastCommand.CommandLine -replace "`r?`n", [environment]::NewLine
            Add-Content $historyFile $lineNormalized
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
    if( Test-Full )
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
    Write-Host " [$hostName] " -ForegroundColor DarkGreen -NoNewline
    if( $SCRIPT:isElevated )
    {
        Write-Host " ELEVATED" -ForegroundColor DarkCyan -NoNewline
    }
    Write-Host ""

    $LASTEXITCODE = $realLastExitCode
    [char] 187 + " "
}

tm (Split-Path $PSCommandPath -Leaf)