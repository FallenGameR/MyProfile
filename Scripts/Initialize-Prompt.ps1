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
$SCRIPT:gitRootColor = e 0 33 # e 38 5 58 # 100 # 214 # 172 # 208 # e 4 33
$SCRIPT:hostColor = e 0 32
$SCRIPT:clearColor = e 0
$SCRIPT:elevatedColor = e 0 36

$SCRIPT:cachedForPath = $null
$SCRIPT:pathParts = $null
$SCRIPT:promptPath = $null
$SCRIPT:titlePath = $null

$SCRIPT:prompt_state = [ordered] @{
    ps_module_path_changes = 0
    preserved_ps_module_path = $env:PSModulePath
}

# If user redefines $cache we have a problem
# For some reason prompt is not private
$SCRIPT:cache = @{}

function SCRIPT:Get-CachedResult( $functionName )
{
    $cached = $SCRIPT:cache[$functionName]
    if( -not $cached ) { return }

    $path, $value = $cached
    if( $path -eq (Get-Location).ProviderPath ) { return $value }
}

function SCRIPT:Update-CachedResult( $functionName, $value )
{
    $SCRIPT:cache[$functionName] = (Get-Location).ProviderPath, $value
    $value
}

function SCRIPT:Get-RepoPath
{
    $cacheKey = "Get-RepoPath - $env:INETROOT"
    $cached = Get-CachedResult $cacheKey
    if( $cached ) { return $cached }

    $pwdPath = (Get-Location).ProviderPath
    $pwdPathParts = @($pwdPath -split "\\|/")
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if( -not $gitRoot ) { $gitRoot = $env:INETROOT }
    $gitRootParts = @($gitRoot -split "\\|/")

    $gitPathStartIndex = $gitRootParts.Length - 1
    $result = if( (-not $gitPathStartIndex) -or ($gitPathStartIndex -eq -1) )
    {
        $pwdPathParts, @()
    }
    else
    {
        @($pwdPathParts[0..($gitPathStartIndex-1)]), $pwdPathParts[$gitPathStartIndex..($pwdPathParts.Length - 1)]
    }

    Update-CachedResult $cacheKey $result
}

function SCRIPT:Update-UserAliasInPath( $path )
{
    if( $env:USERDOMAIN )
    {
        $path -replace [regex]::Escape("$($env:USERNAME).$($env:USERDOMAIN)"), $env:USERNAME
    }
    else
    {
        $path
    }
}

function SCRIPT:Get-PromptPathAnsi
{
    $cached = Get-CachedResult "Get-PromptPath"
    if( $cached ) { return $cached }

    $pwdParts, $gitParts = Get-RepoPath
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
    function annotate( $result )
    {
        if( $env:inetroot -and (Get-Location).ProviderPath.StartsWith($env:inetroot) ) { "$result  ." }
        else { $result }
    }

    $cached = Get-CachedResult "Get-TitlePath"
    if( $cached ) { return annotate $cached }

    $pwdParts, $gitParts = Get-RepoPath
    $path =
        if( $gitParts ) { $gitParts -join [io.path]::DirectorySeparatorChar }
        else { $pwdParts -join [io.path]::DirectorySeparatorChar }

    $title = $path
    if( $home ) { $title = $title -replace ([regex]::Escape($home)), "home" }
    $title = Update-UserAliasInPath $path

    $title = $title -replace ".+?\\NTP\b", "NTP"
    $title = $title -replace "NTP\\managed\\Clockwork", "Clockwork"
    $title = $title -replace "NTP\\managed\\NtpClient", "NtpClient"
    $title = $title -replace "NTP\\managed\\NtpWatchdog", "NtpWatchdog"
    $title = $title -replace "NTP\\managed\\W32TimeLogParser", "W32TimeLogParser"
    $title = $title -replace "NTP\\scripts\\modules", "Modules"
    $title = $title -replace ".+\\data\\Autopilot\\NtpReferenceClock\\Firmware", "Firmware"

    annotate (Update-CachedResult "Get-TitlePath" $title)
}

function SCRIPT:Get-PromptPath
{
    # Path part
    $path = Update-UserAliasInPath ((Get-Location).ProviderPath)
    Write-Host $path -ForegroundColor DarkYellow -NoNewline
    Write-Host " " -NoNewline

    # Git branch, ErrorActionPreference magic is needed to not populate $error when we are outside of git
    $preservedExitCode = $LASTEXITCODE
    $preserved, $ErrorActionPreference = $ErrorActionPreference, "Ignore"
    $branch = git rev-parse --abbrev-ref HEAD
    if( -not $LASTEXITCODE )
    {
        Write-Host "$branch " -ForegroundColor DarkGray -NoNewline
    }
    $ErrorActionPreference = $preserved
    Set-Variable LASTEXITCODE -Scope Global -Force -Value $preservedExitCode

    # Host name
    Write-Host "[$hostName] " -ForegroundColor DarkGreen -NoNewline

    # Elevation
    if( $SCRIPT:isElevated )
    {
        Write-Host "ELEVATED " -ForegroundColor DarkCyan -NoNewline
    }

    # Tracking PSModulePath changes
    if( $SCRIPT:prompt_state.preserved_ps_module_path -ne $env:PSModulePath )
    {
        $SCRIPT:prompt_state.ps_module_path_changes += 1
        if( $SCRIPT:prompt_state.ps_module_path_changes -gt 1 )
        {
            Write-Host "PSModulePath changed " -ForegroundColor DarkMagenta -NoNewline
        }
        $SCRIPT:prompt_state.preserved_ps_module_path = $env:PSModulePath
    }

    # New line prompt
    Write-Host ""
    [char] 187 + " "
}

function prompt
{
    $realLastExitCode = $LASTEXITCODE

    Update-CommandHistory
    if( Test-Full ) { $host.UI.RawUI.WindowTitle = Get-TitlePath }
    Get-PromptPath

    $LASTEXITCODE = $realLastExitCode
}

tm (Split-Path $PSCommandPath -Leaf)