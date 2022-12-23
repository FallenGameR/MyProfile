[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Helper functions
$SCRIPT:Profiling = get-date
$SCRIPT:ProfilingCounter = 1

function SCRIPT:Complete-Once( $name, $script )
{
    # Skip if one time setup was already done
    $flag = "$PSScriptRoot/OneTime/$name"
    if( Test-Path $flag )
    {
        return
    }

    # Do one time setup
    Write-Host "Setting up $name"
    & $script
    touch $flag | Out-Null
}

function SCRIPT:Get-Elapsed
{
    $now = Get-Date
    $message = "{0:00} #{1}" -f $profilingCounter, ($now - $profiling)
    Write-Host $message -fore DarkGreen
    $SCRIPT:Profiling = $now
    $SCRIPT:ProfilingCounter +=1
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
