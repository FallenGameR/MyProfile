[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

# Default console color setup
Complete-Once "Fonts" {
    Set-DefaultPowershellColors ".\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
    Set-DefaultPowershellColors ".\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe"
}

Complete-Once "ColorTool" {
    Push-Location "$PsScriptRoot\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
    Pop-Location
}

# Cloud folders setup
switch ($env:ComputerName)
{
    "ALEXKO-DEV"
    {
        $dropbox = "d:\Dropbox\"
        $oneDrive = "d:\OneDrive\"
        $oneDriveMicrosoft = "d:\OneDrive - Microsoft\"
        $opensource = "e:\external\"
        $azcompute = "e:\root\Azure\Compute-Move\"
        $apgold = "e:\autopilot\apgold\"
        $playground = "e:\git\pg"
        $root = "e:\root\"
    }
    "ALEXKO-DS"
    {
        $dropbox = "e:\Dropbox\"
        $oneDrive = "e:\OneDrive\"
        $oneDriveMicrosoft = "e:\OneDrive - Microsoft\"
        $opensource = "e:\Code\external"
        $azcompute = "e:\Code\autopilot\move\"
        $apgold = "e:\Code\autopilot\apgold\"
        $playground = $null
        $root = "e:\Code\onebranch\"
    }
    "ALEXKO-LS"
    {
        $dropbox = $null
        $oneDrive = "D:\OneDrive\"
        $oneDriveMicrosoft = "D:\OneDrive - Microsoft\"
        $opensource = "D:\Code\External"
        $azcompute = "D:\Code\Autopilot\Move\"
        $apgold = "D:\Code\Autopilot\ApGold\"
        $playground = $null
        $root = "D:\Code\Onebranch\"
    }
    "ALEXKO-X1"
    {
        $dropbox = "c:\Users\alexko\Dropbox\"
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "c:\Users\alexko\OneDrive - Microsoft\"
        $opensource = $null
        $azcompute = "d:\src\root\Azure\Compute-Move\"
        $apgold = "c:\src\apgold\"
        $playground = $null
        $root = "d:\src\root\"
    }
    "ALEXKO-SB"
    {
        $dropbox = $null
        $oneDrive = "c:\Users\alexko\OneDrive\"
        $oneDriveMicrosoft = "C:\Users\alexko\OneDrive - Microsoft\"
        $opensource = $null
        $azcompute = "c:\src\mv\"
        $apgold = "c:\src\gold\ap\"
        $playground = $null
        $root = "C:\src\one\"
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
    "Sekirei"
    {
        $dropbox = "f:\Dropbox\"
        $oneDrive = "f:\OneDrive\"
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
#00:00:00.0020009

# Current path fix
if( ($env:ComputerName -eq "ALEXKO-DS") -and ($pwd -match [regex]::Escape("C:\Users\alexko.REDMOND")) )
{
    $newLocation = $pwd -replace [regex]::Escape("C:\Users\alexko.REDMOND"), "C:\Users\alexko"
    cd $newLocation
    [Environment]::CurrentDirectory = $pwd
}

# Set up environment variables
Set-EnvironmentVariable "OneDrive" $oneDrive
Set-EnvironmentVariable "OneDriveMicrosoft" $oneDriveMicrosoft
Set-EnvironmentVariable "Opensource" $opensource
Set-EnvironmentVariable "AzCompute" $azcompute
Set-EnvironmentVariable "ApGold" $apgold
Set-EnvironmentVariable "Root" $root
Set-EnvironmentVariable "Playground" $playground
Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Set-EnvironmentVariable "Home" $env:USERPROFILE
#00:00:00.0140094

# Tools folder creation
if( -not (Test-Path "c:\tools") )
{
    # Do we need to test that we have admin rights / that current user can do anything to drive c:\ ?
    mkdir "c:\tools" -ea Stop | Out-Null
}
#00:00:00.0030026

# Tools junction creation
foreach( $tool in ls $oneDrive\Distrib\tools -Directory -ea Ignore | where Name -notmatch "^_" )
{
    New-Junction $tool.FullName "c:\tools\$($tool.Name)"
}
#00:00:00.0290176

foreach( $tool in ls $oneDriveMicrosoft\tools -Directory -ea Ignore | where Name -notmatch "^_" )
{
    New-Junction $tool.FullName "c:\tools\$($tool.Name)"
}
#00:00:00.0110072

# The rest of the commands are possible only from an elevated prompt
if( -not (Test-Elevated) )
{
    return
}

# Shortcut creation
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Windows PowerShell.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Windows PowerShell.lnk"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\Windows PowerShell.lnk" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell"
Copy-UpdatedFile "$PsScriptRoot\..\Shortcuts\LINQPad.lnk" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\LINQPad.lnk"
#00:00:00.0540369

# Common root junctions
New-Junction "c:\Program Files" "c:\Program Files (x86)\_x64_"
New-Junction "c:\Program Files (x86)" "c:\programs"
New-Junction $home "c:\home"
#00:00:00.0030027

# Folder hide
"c:\Intel", "c:\PerfLogs", "c:\Program Files", "c:\Program Files (x86)", "c:\Users", "c:\Windows", "c:\inetpub" | where{gi $psitem -ea ignore} | Set-Visible $false
"$home\3D Objects", "$home\Contacts", "$home\Favorites", "$home\Links", "$home\Pictures", "$home\Saved Games", "$home\Searches" , "$home\Videos" | where{gi $psitem -ea ignore} | Set-Visible $false
#00:00:00.0280187

#new-item -path c:\Users\alexko\Documents\WindowsPowerShell\Modules\CoreXtAutomation -ItemType Junction -Value e:\root\Compute\Core\CoreXTAutomation\src\CoreXTAutomation
#new-item -path c:\Users\alexko\Documents\WindowsPowerShell\Modules\PhxAutomation -ItemType Junction -Value e:\root\Compute\Core\PHXAutomation\src\PHXAutomation\
#New-Item -Path c:\Users\alexko\Documents\WindowsPowerShell\Modules\fabric -ItemType Junction -Value $oneDriveMicrosoft\Tools\FcShell\
