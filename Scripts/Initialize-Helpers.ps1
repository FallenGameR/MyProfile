$SCRIPT:stopwatch = [system.diagnostics.stopwatch]::StartNew()
$SCRIPT:enableTiming = $false
$SCRIPT:verbose = $false

function SCRIPT:tm($info = "=>")
{
    if( $SCRIPT:enableTiming )
    {
        Write-Host "$($SCRIPT:stopwatch.ElapsedMilliseconds / 1000) $info"
        $SCRIPT:stopwatch.Restart()
    }
}

function SCRIPT:Test-Windows()
{
    $PSVersionTable.Platform -eq "Windows"
}

function SCRIPT:Test-Unix()
{
    $PSVersionTable.Platform -eq "Unix"
}

function SCRIPT:Test-Full()
{
    $ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"
}

function SCRIPT:Test-Constrained()
{
    $ExecutionContext.SessionState.LanguageMode -eq "Constrained"
}

function SCRIPT:Import-AsDotSource($path, $condition = $true)
{
    $exists = Test-Path $path
    if( $SCRIPT:Verbose ) { Write-Host "Import-AsDotSource $path $exists $condition" }
    if( -not ($exists -and $condition) ) { return }
    . $path
}

function SCRIPT:Import-AsInvoke($path, $condition = $true)
{
    $exists = Test-Path $path
    if( $SCRIPT:Verbose ) { Write-Host "Import-AsInvoke $path $exists $condition" }
    if( -not ($exists -and $condition) ) { return }
    & $path
}

function SCRIPT:Complete-Once( $name, $script )
{
    # Skip if one time setup was already done
    $flag = "$PSScriptRoot/../OneTime/$name"
    if( Test-Path $flag )
    {
        return
    }

    # Do one time setup
    Write-Host "Setting up $name"
    & $script
    touch $flag | Out-Null
}

function SCRIPT:New-Junction( $from, $to )
{
    if( Test-Path $to ) { return }

    $parent = Split-Path $to
    $name = Split-Path $to -Leaf
    Push-Location $parent
    New-Item -Type Junction -Name $name -Value $from
    Pop-Location
}

filter SCRIPT:Set-Visible( [bool] $makeVisible )
{
    if( -not (Test-Path $psitem ) ) { return }

    $item = Get-Item $psitem
    if( $makeVisible )
    {
        # No effect on Unix, but it doesn't fail either
        $item.Attributes = $item.Attributes -band (-bnot [Io.FileAttributes]::Hidden)
    }
    else
    {
        $item.Attributes = $item.Attributes -bor "Hidden"
    }
}

function SCRIPT:Set-EnvironmentVariable( $name, $value )
{
    if( -not $value ) { return }

    if( (Get-Item env:$name -ea Ignore).Value -ne $value )
    {
        [Environment]::SetEnvironmentVariable( $name, $value, "User" )
        Set-Item env:$name $value
    }
}

function SCRIPT:Test-Elevated
{
    switch( $PSVersionTable.Platform )
    {
        "Windows"
        {
            if( $ExecutionContext.SessionState.LanguageMode -eq "FullLanguage" )
            {
                $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
                $principal = [Security.Principal.WindowsPrincipal] $identity
                $role = [Security.Principal.WindowsBuiltInRole] "Administrator"
                return $principal.IsInRole($role)
            }
        }
        "Unix"
        {
            $userID = [int](id -u)
            return $userID -eq 0
        }
        default { return $false }
    }
}

function SCRIPT:Copy-UpdatedFile( $from, $to )
{
    $toFile = Get-Item $to -ea Ignore
    $fromFile = Get-Item $from

    $toFolder = Split-Path $to
    if( -not (Test-Path $toFolder) )
    {
        mkdir $toFolder | Out-Null
    }

    if( (-not $toFile) -or ($toFile.Length -ne $fromFile.Length) )
    {
        copy $from $to -Force
    }
}

function SCRIPT:Test-ProcessRedirected( $process )
{
    $process.StartInfo.RedirectStandardInput -or
    $process.StartInfo.RedirectStandardOutput -or
    $process.StartInfo.RedirectStandardError
}

function SCRIPT:Register-Shortcut
{
    param
    (
        [Parameter(Mandatory)]
        $Key,
        [Parameter(Mandatory)]
        $Command,
        $Description
    )

    Set-PSReadlineKeyHandler `
        -Key $Key `
        -BriefDescription $Command `
        -LongDescription $Description `
        -ScriptBlock `
        {
            [Microsoft.Powershell.PSConsoleReadLine]::RevertLine()
            [Microsoft.Powershell.PSConsoleReadLine]::Insert($Command)
            [Microsoft.Powershell.PSConsoleReadLine]::AcceptLine()
        }.GetNewClosure()
}

tm (Split-Path $PSCommandPath -Leaf)