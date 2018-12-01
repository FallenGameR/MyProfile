# Helper functions
$SCRIPT:Profiling = get-date
$SCRIPT:ProfilingCounter = 1

function SCRIPT:Complete-Once( $name, $script )
{
    if( -not (Get-Item "HKCU:\Console\ProfileSetup").GetValue($name) )
    {
        Write-Host "Setting up $name"

        & $script

        New-Item "HKCU:\Console\ProfileSetup" -ea Ignore
        Set-ItemProperty "HKCU:\Console\ProfileSetup" -Name $name -Value "1"
    }
}

function SCRIPT:Get-Elapsed
{
    $now = Get-Date
    $message = "{0:00} #{1}" -f $profilingCounter, ($now - $profiling)
    Write-Host $message -fore darkgreen
    $SCRIPT:Profiling = $now
    $SCRIPT:ProfilingCounter +=1
}

function SCRIPT:New-Junction( $from, $to )
{
    # Set-junction is needed instead
    if( -not (Test-Path $to) )
    {
        cmd /c "mklink /J ""$To"" ""$From"""
    }
}

filter SCRIPT:Set-Visible( [bool] $makeVisible )
{
    if( -not (Test-Path $psitem ) )
    {
        return
    }

    $attributes = (Get-ItemProperty $psitem).Attributes
    $hidden = $attributes -band [Io.Fileattributes]::Hidden

    if( -not ($hidden -xor $makeVisible) )
    {
        $attributes = $attributes -bxor [Io.Fileattributes]::Hidden
        $attributes = $attributes -band (-bnot [Io.Fileattributes]::Directory)
        Set-ItemProperty `
            -Path $psitem `
            -Name Attributes `
            -Value $attributes
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
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $role = [Security.Principal.WindowsBuiltInRole] "Administrator"
    $principal.IsInRole($role)
}

# NOTE: http://www.leeholmes.com/blog/2008/06/01/powershells-noble-blue/
# Override defaults in registry
function SCRIPT:Set-DefaultPowershellColors( $path )
{
    Push-Location
    Set-Location HKCU:\Console

    New-Item $path -Force -ea Ignore | Out-Null
    Set-Location $path

    New-ItemProperty . ColorTable05 -type DWORD -value 0x560080 -Force -ea Ignore | Out-Null
    New-ItemProperty . FaceName -type STRING -value "Lucida Console" -Force -ea Ignore | Out-Null
    New-ItemProperty . FontFamily -type DWORD -value 0x36 -Force -ea Ignore | Out-Null
    New-ItemProperty . FontSize -type DWORD -value 0x140000 -Force -ea Ignore | Out-Null
    New-ItemProperty . FontWeight -type DWORD -value 0x190 -Force -ea Ignore | Out-Null
    New-ItemProperty . PopupColors -type DWORD -value 0xf3 -Force -ea Ignore | Out-Null
    New-ItemProperty . QuickEdit -type DWORD -value 0x1 -Force -ea Ignore | Out-Null
    New-ItemProperty . ScreenBufferSize -type DWORD -value 0x270f0078 -Force -ea Ignore | Out-Null

    if( $env:COMPUTERNAME -eq "ALEXKO-X1")
    {
        # Height - 38 lines
        New-ItemProperty . WindowSize -type DWORD -value 0x260078 -Force -ea Ignore | Out-Null
    }
    else
    {
        # Height - 40 lines
        New-ItemProperty . WindowSize -type DWORD -value 0x290078 -Force -ea Ignore | Out-Null
    }

    Pop-Location
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
