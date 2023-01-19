[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param()

# Elevated test
$SCRIPT:isElevated = Test-Elevated

# History folder and file
$SCRIPT:historyFolder = switch( Get-Platform )
{
    "Win32NT" { "c:\automation\history\" }
    "Unix" { "~\.pwsh_history\" }
    default { "pwsh_history" }
}

if( -not (Test-Path $historyFolder) )
{
    mkdir $historyFolder -ea Ignore | Out-Null
}

$SCRIPT:historyFile = Join-Path $historyFolder ("{0}--$pid.ps1" -f [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz"))
$SCRIPT:lastCommandId = -1

# Prompt
# https://duffney.io/usingansiescapesequencespowershell/
function SCRIPT:e { "`e[" + ($args -join ";") + "m" }

# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
$SCRIPT:pathColor = e 0 33
$SCRIPT:gitRootColor = e 38 5 172 #208 # e 4 33
$SCRIPT:hostColor = e 0 32
$SCRIPT:clearColor = e 0
$SCRIPT:elevatedColor = e 0 36

$SCRIPT:promptCacheKey = $null
$SCRIPT:promptCacheValue = $null

function SCRIPT:Get-GitPath
{
    $pwdPath = $pwd.Path
    $pwdPathParts = @($pwdPath -split "\\|/")

    $gitRoot = git rev-parse --show-toplevel 2>$null
    $gitRootParts = @($gitRoot -split "\\|/")

    $gitPathStartIndex = $gitRootParts.Length - 1

    if( $gitPathStartIndex -eq -1 )
    {
        $pwdPathParts, @()
    }
    else
    {
        @($pwdPathParts[0..($gitPathStartIndex-1)]), $pwdPathParts[$gitPathStartIndex..($pwdPathParts.Length - 1)]
    }
}

function SCRIPT:Show-PromptPath
{
    $pwdPath = $pwd.Path
    if( $SCRIPT:promptCacheKey -eq $pwdPath ) { return $SCRIPT:promptCacheValue }

    $pwdParts, $gitParts = Get-GitPath
    if( $gitParts ) { $gitParts[0] = $gitRootColor + $gitParts[0] + $pathColor }

    $path = @($pwdParts + $gitParts) -join [io.path]::DirectorySeparatorChar
    $path = $pathColor + $path + $hostColor + " [$hostName] "

    if( $SCRIPT:isElevated )
    {
        $path += $elevatedColor + " ELEVATED"
    }

    $path += $clearColor
    $path = $path -replace [regex]::Escape("$($env:USERNAME).$($env:USERDOMAIN)"), $env:USERNAME
    $path += [environment]::NewLine
    $path += [char] 187 + " "

    $SCRIPT:promptCacheKey = $pwdPath
    $SCRIPT:promptCacheValue = $path
    $path
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
    $pwdParts, $gitParts = Get-GitPath
    $path = if( $gitParts )
    {
        $gitParts -join [io.path]::DirectorySeparatorChar
    }
    else
    {
        $pwdParts -join [io.path]::DirectorySeparatorChar
    }
    $path = $path -replace [regex]::Escape("$($env:USERNAME).$($env:USERDOMAIN)"), $env:USERNAME

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
            if( $home ) { $title = replace $title $home "home" }
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

    # Position

    <#
    # Title can show path relative to the root
    Write-Host $path -ForegroundColor DarkYellow -NoNewline
    Write-Host " [$hostName] " -ForegroundColor DarkGreen -NoNewline
    if( $SCRIPT:isElevated )
    {
        Write-Host " ELEVATED" -ForegroundColor DarkCyan -NoNewline
    }
    Write-Host ""
    #>

    Show-PromptPath

    $LASTEXITCODE = $realLastExitCode
}

tm (Split-Path $PSCommandPath -Leaf)