. $PSScriptRoot\Initialize-Work.ps1

# Run the "Empty system working set" task now and show what it freed, see Tools\rammap
function Clear-SystemCache
{
    $taskName = "Empty system working set"
    if( -not (Get-ScheduledTask -TaskName $taskName -ea Ignore) )
    {
        throw "Task '$taskName' is not registered yet: open an elevated pwsh once so setup-clear-system-cache runs"
    }

    Start-ScheduledTask -TaskName $taskName
    do { Start-Sleep -Milliseconds 500 } while( (Get-ScheduledTask -TaskName $taskName).State -eq "Running" )
    Import-Csv "$PSScriptRoot\..\..\Data\SystemCache\clear-log.csv" | select -Last 1
}

Complete-Once setup-tldr {
    tldr --update
}

Complete-Once setup-env {
    Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $homeSimplified = $env:USERPROFILE -replace "\.$($env:USERDOMAIN)$"
    if( -not (Test-Path $homeSimplified -ea Ignore) )
    {
        $homeSimplified = $env:USERPROFILE
    }
    Set-EnvironmentVariable "Home" $homeSimplified
}

Complete-Once install-bandwhich {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/imsnif/bandwhich.git
    cd bandwhich

    cargo install bandwhich
    cargo vendor

    # Apply build patch https://github.com/imsnif/bandwhich/pull/234/commits/424e96cc27aefc80d25ac883987a62fd9c93c2f9
    sds "https://nmap.org/npcap/dist/npcap-sdk-1.05.zip" "https://npcap.com/dist/npcap-sdk-1.05.zip" build.rs
    cargo build -r
    cargo install --offline --path .

    # cargo install bandwhich
    # winget install npcap
    # $env:path += ";c:\Windows\System32\Npcap\"
}

Complete-Once install-sds {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/chmln/sd.git
    cd sd

    cargo build -r

    # cargo install -f --git https://github.com/chmln/sd.git
}

Complete-Once junction-one-drive-ms {
    if( $env:OneDriveCommercial )
    {
        New-Item -ItemType Junction -Name "D:\OneDrive.MS" -Target $env:OneDriveCommercial -ea Ignore
        Set-EnvironmentVariable "OneDriveCommercial" "D:\OneDrive.MS"
    }
}

# Elevated setup

Complete-Once install-apps -elevated {
    $apps = cat "$PSScriptRoot\..\..\Data\windows-apps.txt"
    choco install -s=chocolatey @apps -y --no-progress
}

Complete-Once setup-conhost -elevated {
    # Enable ANSI escape sequences in classic console
    Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1

    cd "$PsScriptRoot\..\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
}

Complete-Once hide-folders -elevated {
    $noisyFolders =
        "c:\Intel",
        "c:\PerfLogs",
        "c:\Program Files",
        "c:\Program Files (x86)",
        "c:\Users",
        "c:\Windows",
        "c:\inetpub",
        "$home\3D Objects",
        "$home\Contacts",
        "$home\Favorites",
        "$home\Links",
        "$home\Pictures",
        "$home\Saved Games",
        "$home\Searches",
        "$home\Videos"
    $noisyFolders | where{ gi $psitem -ea ignore } | Set-Visible $false
}

Complete-Once install-wsl -elevated {
    # This command can forcefully reboot machine, don't execute if something else is running
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    wsl --set-default-version 2
}

Complete-Once setup-trackball -elevated {
    & "$env:OneDriveConsumer\Apps\Hardware\Deft Pro Trackball\mouse_driver_ma5111000.exe"
}

Complete-Once setup-clear-system-cache -elevated {
    # Every 2 hours empty the system working set that Defender and indexing bloat, see the script
    $script = Resolve-Path "$PSScriptRoot\..\..\Tools\rammap\Clear-SystemCache.ps1"
    # The Store pwsh lives in a versioned folder, its execution alias survives updates
    $pwsh = "$env:LOCALAPPDATA\Microsoft\WindowsApps\pwsh.exe"
    if( -not (Test-Path $pwsh) ) { $pwsh = (Get-Process -Id $PID).Path }

    # conhost --headless never creates a console window, -WindowStyle Hidden still flashes one
    $action = New-ScheduledTaskAction -Execute "$env:windir\System32\conhost.exe" -Argument "--headless `"$pwsh`" -NoProfile -NonInteractive -File `"$script`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 2)
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName "Empty system working set" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force |
        select TaskName, State
}
