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

# https://duffney.io/usingansiescapesequencespowershell/
function SCRIPT:e
{
    # Compatibility with PS5 that doesn't handle ANSI
    if( $PSVersionTable.PSVersion.Major -gt 5 )
    {
        "`e[" + ($args -join ";") + "m"
    }
}

# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
$SCRIPT:pathColor = e 0 33
$SCRIPT:gitRootColor = e 38 5 214 # 172 # 208 # e 4 33
$SCRIPT:hostColor = e 0 32
$SCRIPT:clearColor = e 0
$SCRIPT:elevatedColor = e 0 36

$SCRIPT:cachedForPath = $null
$SCRIPT:pathParts = $null
$SCRIPT:promptPath = $null
$SCRIPT:titlePath = $null


$SCRIPT:cache = @{}

function SCRIPT:Get-CachedResult( $functionName )
{
    $cached = $SCRIPT:cache[$functionName]
    if( -not $cached ) { return }

    $path, $value = $cached
    if( $path -eq $pwd.Path ) { return $value }
}

function SCRIPT:Update-CachedResult( $functionName, $value )
{
    $SCRIPT:cache[$functionName] = $pwd.Path, $value
    $value
}

function SCRIPT:Get-GitPath
{
    $cached = Get-CachedResult "Get-GitPath"
    if( $cached ) { return $cached }

    $pwdPath = $pwd.Path
    $pwdPathParts = @($pwdPath -split "\\|/")
    $gitRoot = git rev-parse --show-toplevel 2>$null
    $gitRootParts = @($gitRoot -split "\\|/")

    $gitPathStartIndex = $gitRootParts.Length - 1
    $result = if( $gitPathStartIndex -eq -1 )
    {
        $pwdPathParts, @()
    }
    else
    {
        @($pwdPathParts[0..($gitPathStartIndex-1)]), $pwdPathParts[$gitPathStartIndex..($pwdPathParts.Length - 1)]
    }

    Update-CachedResult "Get-GitPath" $result
}

function SCRIPT:Update-UserAliasInPath( $path )
{
    $path -replace [regex]::Escape("$($env:USERNAME).$($env:USERDOMAIN)"), $env:USERNAME
}

function SCRIPT:Get-PromptPath
{
    $cached = Get-CachedResult "Get-PromptPath"
    if( $cached ) { return $cached }

    $pwdParts, $gitParts = Get-GitPath
    if( $gitParts ) { $gitParts[0] = $gitRootColor + $gitParts[0] + $pathColor }

    $path = @($pwdParts + $gitParts) -join [io.path]::DirectorySeparatorChar
    $path = $pathColor + $path + $hostColor + " [$hostName] "

    if( $SCRIPT:isElevated )
    {
        $path += $elevatedColor + " ELEVATED"
    }

    $path += $clearColor
    $path = Update-UserAliasInPath $path
    $path += [environment]::NewLine
    $path += [char] 187 + " "

    Update-CachedResult "Get-PromptPath" $path
}

function SCRIPT:Update-CommandHistory
{
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
        $SCRIPT:lastCommandId = -1
        Add-Content $historyFile "# No history at this point of time"
    }
}

function SCRIPT:Get-TitlePath
{
    $cached = Get-CachedResult "Get-TitlePath"
    if( $cached ) { return $cached }

    if( $env:inetroot )
    {
        function replace($all, $part, $short)
        {
            $all = $all -replace [regex]::Escape($part), $short
            if( $all ) { $all } else { $short + "\" }
        }

        $title = Update-UserAliasInPath $pwd.Path
        $title = replace $title $env:inetroot ""
        $title = replace $title "\src\Client\NTP" "NTP"
        $title = replace $title "NTP\managed\Clockwork" "Clockwork"
        $title = replace $title "\data\Autopilot\NtpReferenceClock\Firmware" "Firmware"
    }
    else
    {
        $pwdParts, $gitParts = Get-GitPath
        $path =
            if( $gitParts ) { $gitParts -join [io.path]::DirectorySeparatorChar }
            else { $pwdParts -join [io.path]::DirectorySeparatorChar }
        $title = Update-UserAliasInPath $path
    }

    if( $home ) { $title = replace $title $home "home" }

    Update-CachedResult "Get-TitlePath" $path
}

function prompt
{
    $realLastExitCode = $LASTEXITCODE

    Update-CommandHistory
    if( Test-Full ) { $host.UI.RawUI.WindowTitle = Get-TitlePath }
    Get-PromptPath

    $LASTEXITCODE = $realLastExitCode
}

<#
# How to use colors when there is no ANSI like in PS5
Write-Host $path -ForegroundColor DarkYellow -NoNewline
Write-Host " [$hostName] " -ForegroundColor DarkGreen -NoNewline
if( $SCRIPT:isElevated )
{
    Write-Host " ELEVATED" -ForegroundColor DarkCyan -NoNewline
}
Write-Host ""
#>

tm (Split-Path $PSCommandPath -Leaf)