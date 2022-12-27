# Conhost should draw ANSI escape sequences
Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1

# Common root junctions
New-Junction "c:\Program Files" "c:\Program Files (x86)\_x64_"
New-Junction "c:\Program Files (x86)" "c:\programs"
New-Junction $home "c:\home"

# Folder hide
"c:\Intel", "c:\PerfLogs", "c:\Program Files", "c:\Program Files (x86)", "c:\Users", "c:\Windows", "c:\inetpub" | where{gi $psitem -ea ignore} | Set-Visible $false
"$home\3D Objects", "$home\Contacts", "$home\Favorites", "$home\Links", "$home\Pictures", "$home\Saved Games", "$home\Searches" , "$home\Videos" | where{gi $psitem -ea ignore} | Set-Visible $false

# WSL setup
Complete-Once "WSL setup" {
    # This command can forcefully reboot machine, don't execute if something else is running
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    wsl --set-default-version 2
}

tm (Split-Path $PSCommandPath -Leaf)