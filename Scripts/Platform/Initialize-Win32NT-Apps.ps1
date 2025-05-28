# Elevated setup

Complete-Once install-apps -elevated {
    $apps = cat "$PSScriptRoot/../../Data/windows-apps.txt"
    choco install -s=chocolatey @apps -y --no-progress
}

Complete-Once setup-conhost-ansi -elevated {
    Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1
}

Complete-Once junction-system -elevated {
    New-Junction "c:\Program Files" "c:\Program Files (x86)\_x64_"
    New-Junction "c:\Program Files (x86)" "c:\programs"
    New-Junction $home "c:\home"
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
    $noisyFolders | where{gi $psitem -ea ignore} | Set-Visible $false
}

Complete-Once install-wsl -elevated {
    # This command can forcefully reboot machine, don't execute if something else is running
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    wsl --set-default-version 2
}

Complete-Once setup-trackball -elevated {
    # May need this fix as well: [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    & "$env:OneDriveConsumer\Apps\Hardware\Deft Pro Trackball\mouse_driver_ma5111000.exe"
}

# Non elevated setup

Complete-Once setup-windows-powershell-profile {
    $shouldBeDocumentsFolder = Split-Path (Split-Path $profile)
    $windowsPowershellFolder = Join-Path $shouldBeDocumentsFolder WindowsPowerShell
    mkdir $windowsPowershellFolder -ea Ignore | Out-Null
    ". $profile" | Add-Content "$windowsPowershellFolder\profile.ps1"
}

Complete-Once junction-tools {
    if( -not (Test-Path "c:\tools") )
    {
        mkdir "c:\tools" -ea Stop | Out-Null
    }

    foreach( $tool in ls $env:OneDriveConsumer\Apps\tools -Directory -ea Ignore | where Name -notmatch "^_" )
    {
        New-Junction $tool.FullName "c:\tools\$($tool.Name)"
    }

    foreach( $tool in ls $env:OneDriveCommercial\tools -Directory -ea Ignore | where Name -notmatch "^_" )
    {
        New-Junction $tool.FullName "c:\tools\$($tool.Name)"
    }
}

Complete-Once setup-bottom {
    if( -not (Test-Path $env:APPDATA\bottom) )
    {
        mkdir $env:APPDATA\bottom -ea Stop | Out-Null
    }
    Copy-Item $PSScriptRoot\..\..\Tools\bottom\bottom.toml $env:APPDATA\bottom\bottom.toml
}

Complete-Once setup-fd {
    $path = $env:APPDATA
    mkdir "$path\fd" -ea Ignore | Out-Null
    cat "$PsScriptRoot/../../Modules/FzfBindings/Data/excluded_folders" > $path/fd/ignore
}

Complete-Once setup-tldr {
    tldr --update
}

Complete-Once setup-powershell-classic {
    $classic = "$env:USERPROFILE\Documents\WindowsPowershell"
    $modern = "$env:USERPROFILE\Documents\Powershell"
    mkdir $classic | Out-Null
    ". $modern\profile.ps1" > "$classic\Microsoft.PowerShell_profile.ps1"

    cd $classic
    New-Item -Type Junction -Name Modules -Value "$modern\Modules"
}

Complete-Once setup-conhost {
    cd "$PsScriptRoot\..\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
}

Complete-Once env-common {
    Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $homeSimplified = $env:USERPROFILE -replace "\.$($env:USERDOMAIN)$"
    if( -not (Test-Path $homeSimplified -ea Ignore) )
    {
        $homeSimplified = $env:USERPROFILE
    }
    Set-EnvironmentVariable "Home" $homeSimplified
}

tm (Split-Path $PSCommandPath -Leaf)