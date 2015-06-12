# Test if initialization is needed
$initializedFile = Join-Path (Split-Path $PROFILE) "initialized"
$initialized = Test-Path $initializedFile
if( $initialized )
{
    return
}

# Helper functions
function New-Junction( $from, $to )
{
    # Set-junction is needed instead
    cmd /c "mklink /J ""$To"" ""$From"""
}

filter Set-Visible( [bool] $makeVisible )
{
    # TODO: debug
    $attributes = (Get-ItemProperty $psitem).Attributes
    $hidden = $attributes -band [Io.Fileattributes]::Hidden
    if( $hidden -xor $makeVisible )
    {
        Set-ItemProperty `
            -Path $psitem `
            -Name Attributes `
            -Value ($attributes -bxor [Io.Fileattributes]::Hidden)
    }
}

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
}

# Set up environment variables
function Set-EnvironmentVariable( $name, $value )
{
    if( (Get-Item env:$name -ea Ignore).Value -ne $value )
    {
        [Environment]::SetEnvironmentVariable( $name, $value, "User" )
        Set-Item env:$name $value
    }
}
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
    $to = "c:\tools\$($tool.Name)"
    if( -not (Test-Path $to) )
    {
        New-Junction $tool.FullName $to
    }
}

# folder hide
# program files function




# Default console color setup
# NOTE: http://www.leeholmes.com/blog/2008/06/01/powershells-noble-blue/
function Set-DefaultPowershellColors( $path )
{
    Push-Location
    Set-Location HKCU:\Console

    New-Item $path -Force -ea Ignore | Out-Null
    Set-Location $path

    New-ItemProperty . ColorTable05 -type DWORD -value 0x560080 -Force -ea Ignore | Out-Null
    New-ItemProperty . PopupColors -type DWORD -value 0xf3 -Force -ea Ignore | Out-Null
    New-ItemProperty . ScreenBufferSize -type DWORD -value 0x270f0078 -Force -ea Ignore | Out-Null
    New-ItemProperty . WindowSize -type DWORD -value 0x290078 -Force -ea Ignore | Out-Null
    New-ItemProperty . FontSize -type DWORD -value 0x140000 -Force -ea Ignore | Out-Null
    New-ItemProperty . FaceName -type STRING -value "Lucida Console" -Force -ea Ignore | Out-Null
    New-ItemProperty . QuickEdit -type DWORD -value 0x1 -Force -ea Ignore | Out-Null

    Pop-Location
}

Set-DefaultPowershellColors ".\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
Set-DefaultPowershellColors ".\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe"


# The rest of the commands are possible only from an elevated prompt
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal] $identity
$role = [Security.Principal.WindowsBuiltInRole] "Administrator"
$elevated = $principal.IsInRole($role)
if( -not $elevated )
{
    return
}

# Shortcut creation
$existingShortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Windows PowerShell.lnk"
$existingShortcut = Get-Item $existingShortcutPath -ea Ignore
$correctShortcutPath = "$PsScriptRoot\..\Shortcuts\Windows PowerShell.lnk"
$correctShortcut = Get-Item $correctShortcutPath
if( (-not $existingShortcut) -or ($existingShortcut.Length -ne $correctShortcut.Length) )
{
    copy $correctShortcutPath $existingShortcutPath -Force
}

# Installing tools
return


Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install gitextensions -y
choco install kdiff3 -y

# Setting up git
git config --global user.name "Aleksandr Kostikov"
git config --global user.email "Alex.Kostikov@gmail.com"

# Tooling defaults - use colored grep and diff output, use TeamHub-compatible line endings notation, limit memory consumption for pack operation
# Also useful: git config --global color.diff.whitespace "blue reverse" - excluded since by default powershell console is blue
git config --global core.autocrlf true
git config --global core.pager 'less -q'
git config --global pack.threads 4
git config --global pack.windowMemory 256m

git config --global --replace-all color.grep auto
git config --global --replace-all color.grep.filename "green"
git config --global --replace-all color.grep.linenumber "cyan"
git config --global --replace-all color.grep.match "magenta"
git config --global --replace-all color.grep.separator "black"
git config --global --replace-all grep.lineNumber true
git config --global --replace-all grep.extendedRegexp true

git config --global --replace-all color.diff.meta "yellow"
git config --global --replace-all color.diff.frag "cyan"
git config --global --replace-all color.diff.func "cyan bold"
git config --global --replace-all color.diff.commit "yellow bold"

# Aliases for the most used commands
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.lg "log --graph --pretty=format:'%C(reset)%C(yellow)%h%C(reset) -%C(bold yellow)%d%C(reset) %s %C(green)(%cr) %C(cyan)<%an>%C(reset)' --abbrev-commit --date=relative -n 10"
git config --global alias.gr "grep --break --heading --line-number -iIE"
git config --global alias.df "diff head~1..head --word-diff-regex=[\.a-z]+"

# Don't run computer configuration anymore
Get-Date | Set-Content $initializedFile
