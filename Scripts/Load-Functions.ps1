# Helper functions
function New-Junction( $from, $to )
{
    # Set-junction is needed instead
    if( -not (Test-Path $to) )
    {
        cmd /c "mklink /J ""$To"" ""$From"""
    }
}

filter Set-Visible( [bool] $makeVisible )
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

function Set-EnvironmentVariable( $name, $value )
{
    if( (Get-Item env:$name -ea Ignore).Value -ne $value )
    {
        [Environment]::SetEnvironmentVariable( $name, $value, "User" )
        Set-Item env:$name $value
    }
}

function Test-Elevated
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $role = [Security.Principal.WindowsBuiltInRole] "Administrator"
    $principal.IsInRole($role)
}

# NOTE: http://www.leeholmes.com/blog/2008/06/01/powershells-noble-blue/
function Set-DefaultPowershellColors( $path )
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
    New-ItemProperty . WindowSize -type DWORD -value 0x290078 -Force -ea Ignore | Out-Null

    Pop-Location
}

function Copy-UpdatedFile( $from, $to )
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

function Test-ProcessRedirected( $process )
{
    $process.StartInfo.RedirectStandardInput -or
    $process.StartInfo.RedirectStandardOutput -or
    $process.StartInfo.RedirectStandardError
}