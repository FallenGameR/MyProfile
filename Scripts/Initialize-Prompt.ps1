# Init yazi - https://yazi-rs.github.io/docs/quick-start
function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}

# Preserve last command in log file
$SCRIPT:lastCommandId = -1
$SCRIPT:historyFolder = switch( Get-Platform )
{
    "Win" { "c:\automation\history\" }
    "Unix" { "~\.pwsh_history\" }
    default { "pwsh_history" }
}
$SCRIPT:historyFile = Join-Path $historyFolder ("{0}--$pid.ps1" -f [DateTime]::Now.ToString("yyyy.MM.dd--HH.mm.ss--UTCz"))

if( -not (Test-Path $historyFolder) )
{
    mkdir $historyFolder -ea Ignore | Out-Null
}

function SCRIPT:Update-CommandHistory
{
    $lastCommand = Get-History -Count 1
    if( -not $lastCommand )
    {
        $SCRIPT:lastCommandId = -1
        return
    }

    if( $lastCommand.Id -ne $SCRIPT:lastCommandId )
    {
        $SCRIPT:lastCommandId = $lastCommand.Id
        $lineNormalized = $lastCommand.CommandLine -replace "`r?`n", [environment]::NewLine
        Add-Content $historyFile $lineNormalized
    }
}

# Window titles that are cached
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

# Finds the git repo by walking up the folders, without starting git.exe
# that can be slow in large repos (VFS, fsmonitor hooks)
function SCRIPT:Get-GitRepository
{
    $folder = (Get-Location).ProviderPath
    while( $folder )
    {
        $dotGit = Join-Path $folder ".git"
        if( [IO.Directory]::Exists($dotGit) )
        {
            return [pscustomobject] @{ Root = $folder; GitDir = $dotGit }
        }
        if( [IO.File]::Exists($dotGit) )
        {
            # Worktrees and submodules have a .git file that points to the real git dir
            $line = [IO.File]::ReadAllText($dotGit).Trim()
            if( $line -match "^gitdir:\s*(.+)$" )
            {
                $gitDir = $matches[1] -replace "/", "\"
                if( -not [IO.Path]::IsPathRooted($gitDir) ) { $gitDir = Join-Path $folder $gitDir }

                # Linked worktree git dirs look like <repo>\.git\worktrees\<name>
                $worktreeRepository = $null
                if( $gitDir -match "^(.+?)(?:\\\.git)?\\worktrees\\[^\\]+\\?$" )
                {
                    $worktreeRepository = Split-Path $matches[1] -Leaf
                }

                return [pscustomobject] @{ Root = $folder; GitDir = $gitDir; WorktreeRepository = $worktreeRepository }
            }
        }
        $folder = [IO.Path]::GetDirectoryName($folder)
    }
}

function SCRIPT:Get-GitBranch
{
    $repo = Get-GitRepository
    if( -not $repo ) { return }

    $headFile = Join-Path $repo.GitDir "HEAD"
    if( -not [IO.File]::Exists($headFile) ) { return }

    $head = [IO.File]::ReadAllText($headFile).Trim()
    if( $head -match "^ref:\s*refs/heads/(.+)$" ) { $matches[1] }
    else { "HEAD" }
}

function SCRIPT:Get-RepoPath
{
    $cacheKey = "Get-RepoPath - $env:INETROOT"
    $cached = Get-CachedResult $cacheKey
    if( $cached ) { return $cached }

    $pwdPath = (Get-Location).ProviderPath
    $pwdPathParts = @($pwdPath -split "\\|/")
    $gitRoot = (Get-GitRepository).Root
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

# Use zoxide for directory navigation - can be installed only after starship
# https://github.com/ajeetdsouza/zoxide
if( Get-Command zoxide -ea Ignore )
{
    $env:_ZO_DATA_DIR = "$PSScriptRoot\..\Tools\zoxide\data"
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# No further initialization is needed if starship is used
if( $env:STARSHIP_CONFIG -and (Get-Command starship -ea Ignore) )
{
    return
}

# Elevated test
$SCRIPT:isElevated = Test-Elevated

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
$SCRIPT:prompt_state = [ordered] @{
    ps_module_path_changes = 0
    preserved_ps_module_path = $env:PSModulePath
}

function SCRIPT:Get-PromptPath
{
    # Path part, linked worktrees show repository name and the path inside it
    $location = (Get-Location).ProviderPath
    $repo = Get-GitRepository
    if( $repo -and $repo.WorktreeRepository )
    {
        Write-Host "$($repo.WorktreeRepository) " -ForegroundColor DarkBlue -NoNewline
        $relative = $location.Substring($repo.Root.Length).TrimStart("\", "/")
        if( $relative )
        {
            Write-Host "$relative " -ForegroundColor DarkYellow -NoNewline
        }
    }
    else
    {
        $path = Update-UserAliasInPath $location
        Write-Host $path -ForegroundColor DarkYellow -NoNewline
        Write-Host " " -NoNewline
    }

    # Git branch
    $branch = Get-GitBranch
    if( $branch )
    {
        Write-Host "$branch " -ForegroundColor DarkGray -NoNewline
    }

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