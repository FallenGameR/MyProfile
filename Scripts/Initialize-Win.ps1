# Common pwsh commands
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

# Path setup
$addToPath =
    "C:\Program Files\Git\usr\bin\",        # GNU tools
    "C:\Program Files\Python311\Scripts\",  # For httpie when python was installed from the main web site
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\Program Files (x86)\Winamp\",
    "C:\tools\chafa",                       # console picture viewer
    "C:\tools\sd",                          # sds replacer
    "C:\tools\tagger"
$env:PATH += [io.path]::PathSeparator + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join [io.path]::PathSeparator)

# Shortcut setup
Register-Shortcut "Alt+y" "y" "yazi open"

# Elevated setup

Complete-Once install-apps -elevated {
    $apps = cat "$PSScriptRoot\..\..\Data\windows-apps.txt"
    choco install -s=chocolatey @apps -y --no-progress
}

Complete-Once setup-conhost -elevated {
    # Enable ANSI escape sequences in classic console
    Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1

    cd "$PsScriptRoot\..\Bin\ColorTool\"
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

# Non elevated setup

Complete-Once setup-winget {
    copy "$PsScriptRoot\..\Tools\Winget\winget-settings.json" "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
}

Complete-Once setup-bottom {
    mkdir $env:APPDATA\bottom -ea Ignore | Out-Null
    Copy-Item "$PSScriptRoot\..\..\Tools\bottom\bottom.toml" "$env:APPDATA\bottom\bottom.toml"
}

Complete-Once setup-fd {
    mkdir "$env:APPDATA\fd" -ea Ignore | Out-Null
    cat "$PsScriptRoot/../../Modules/FzfBindings/Data/excluded_folders" > "$env:APPDATA\fd\ignore"
}

Complete-Once setup-tldr {
    tldr --update
}

Complete-Once setup-powershell-classic {
    if( $PSVersionTable.PSEdition -ne "Core" )
    {
        throw "This function must be envoked only from PowerShell Core"
    }

    $classic = "$env:USERPROFILE\Documents\WindowsPowershell"
    $modern = "$env:USERPROFILE\Documents\Powershell"

    mkdir $classic -ea Ignore | Out-Null
    ". $profile" | Add-Content "$classic\profile.ps1"

    New-Item -Type Junction -Name "$classic\Modules" -Value "$modern\Modules"
}

Complete-Once setup-junctions {
    New-Item -Type Junction -Name "c:\Program Files (x86)\_x64_" -Value "c:\Program Files"
    New-Item -Type Junction -Name "c:\programs" -Value "c:\Program Files (x86)"
    New-Item -Type Junction -Name "c:\home" -Value $home
}

Complete-Once setup-tools {
    mkdir "c:\tools" -ea Ignore | Out-Null

    foreach( $tool in ls "$env:OneDriveConsumer\Apps\tools" -Directory -ea Ignore | where Name -notmatch "^_" )
    {
        New-Junction $tool.FullName "c:\tools\$($tool.Name)"
    }

    foreach( $tool in ls "$env:OneDriveCommercial\tools" -Directory -ea Ignore | where Name -notmatch "^_" )
    {
        New-Junction $tool.FullName "c:\tools\$($tool.Name)"
    }
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

tm (Split-Path $PSCommandPath -Leaf)