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
        $playground = $null
        $root = "d:\root\"
    }
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\OneDrive - Microsoft\"
        $opensource = $null
        $azcompute = "c:\src\gitsd.az_compute.trimmed\"
        $apgold = "c:\src\apgold\"
        $playground = "c:\src\pg\"
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
        $playground = $null
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
        $playground = $null
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
Set-EnvironmentVariable "Playground" $playground
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

foreach( $tool in ls $oneDriveMicrosoft\tools -Directory -ea Ignore | where Name -notmatch "^_" )
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
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Windows PowerShell.lnk" "C:\Users\alexko\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell"
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
