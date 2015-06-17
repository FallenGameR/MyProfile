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

# Default console color setup
Set-DefaultPowershellColors ".\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
Set-DefaultPowershellColors ".\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe"

# Cloud folders setup
switch ($env:ComputerName)
{
    "ALEXKO-DEV"
    {
        $dropbox = "e:\Dropbox\"
        $oneDrive = "e:\OneDrive\"
        $oneDriveMicrosoft = "e:\OneDriveMicrosoft\"
        $opensource = "d:\opensource\"
        $azcompute = "d:\autopilot\gitsd.az_compute\"
        $apgold = "d:\autopilot\apgold\"
        $root = "d:\root\"
    }
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\SkyDrive @ Microsoft\"
        $opensource = "c:\src\opensource\"
        $azcompute = "c:\src\autopilot\az_compute\"
        $apgold = "c:\src\autopilot\apgold_sd\"
        $root = "c:\src\root\"
    }
    "AUTOPILOTHUB"
    {
        $dropbox = $null
        $oneDrive = $null
        $oneDriveMicrosoft = $null
        $opensource = $null
        $azcompute = $null
        $apgold = "d:\enlistments\ApGold\"
        $root = "c:\src\root\"
    }
    "TACHIKOMA"
    {
        $dropbox = "d:\Dropbox\"
        $oneDrive = "d:\OneDrive\"
        $oneDriveMicrosoft = $null
        $opensource = $null
        $azcompute = $null
        $apgold = $null
        $root = $null
    }
    default
    {
        # No extra setup on unknown machines
        return
    }
}

# Set up environment variables
Set-EnvironmentVariable "Dropbox" $dropbox
Set-EnvironmentVariable "OneDrive" $oneDrive
Set-EnvironmentVariable "OneDriveMicrosoft" $oneDriveMicrosoft
Set-EnvironmentVariable "Opensource" $opensource
Set-EnvironmentVariable "AzCompute" $azcompute
Set-EnvironmentVariable "ApGold" $apgold
Set-EnvironmentVariable "Root" $root
Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Set-EnvironmentVariable "Home" $env:USERPROFILE

# Tools folder creation
if( -not (Test-Path "c:\tools") )
{
    # Do we need to test that we have admin rights / that current user can do anything to drive c:\ ?
    mkdir "c:\tools" -ea Stop | Out-Null
}

# Tools junction creation
foreach( $tool in ls $dropbox\tools -Directory -ea Ignore | where Name -notmatch "^_" )
{
    New-Junction $tool.FullName "c:\tools\$($tool.Name)"
}

# The rest of the commands are possible only from an elevated prompt
if( -not (Test-Elevated) )
{
    return
}

# Shortcut creation
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Windows PowerShell.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Windows PowerShell.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\OneNote 2013.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2013\OneNote 2013.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Codeflow Launcher.lnk" "C:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\CodeFlow\Codeflow Launcher.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\GVim.lnk" "C:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GVim.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\LINQPad.lnk" "C:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINQPad.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Tagger.lnk" "c:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Tagger.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\WindowPad.lnk" "c:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\WindowPad.lnk"

# Common root junctions
New-Junction "c:\Program Files" "c:\Program Files (x86)\_x64_"
New-Junction "c:\Program Files (x86)" "c:\programs"
New-Junction $home "c:\home"

# Folder hide
"c:\Intel", "c:\PerfLogs", "c:\Program Files", "c:\Program Files (x86)", "c:\Users", "c:\Windows" | Set-Visible $false
