# Starship now only works at home

# Use starship for prompt if available
if( Get-Command starship -ea Ignore )
{
    $env:STARSHIP_CONFIG = "$PSScriptRoot\..\Tools\starship\starship.toml"
    $env:STARSHIP_CACHE = "$PSScriptRoot\..\Tools\starship\logs"
    #$env:STARSHIP_LOG = "trace"
    function Invoke-Starship-PreCommand
    {
        # Track PSModulePath changes
        if( $env:PreviousPSModulePath -and ($env:PreviousPSModulePath -ne $env:PSModulePath) )
        {
            $env:ChangedPSModulePath = "PSModulePath changed"
        }
        else
        {
            $env:ChangedPSModulePath = $null
        }
        $env:PreviousPSModulePath = $env:PSModulePath

        # Fix console mode if the FzfBindings is hot-loaded
        if( Get-Module FzfBindings -ea Ignore )
        {
            # fzf seems to have a background thread that can mess up
            # the console mode even after the main thread is killed and
            # the console get control from the fzf back
            Repair-ConsoleMode
        }

        # Keep track of the command history
        Update-CommandHistory

        # Update the window title
        if( Test-Full ) { $host.UI.RawUI.WindowTitle = Get-TitlePath }
    }

    Invoke-Expression (&starship init powershell)
}

# Non elevated setup

Complete-Once setup-tldr {
    tldr --update
}

Complete-Once install-as-tree {
    cargo install -f --git https://github.com/jez/as-tree
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

Complete-Once setup-winget {
    copy "$PsScriptRoot\..\Tools\Winget\winget-settings.json" "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
}

# Elevated setup

Complete-Once install-PSToolset {
    git clone https://github.com/microsoft/PSToolset.git $PsScriptRoot/../Modules/PSToolset
}

Complete-Once install-FzfBindings {
    git clone https://github.com/FallenGameR/FzfBindings.git $PsScriptRoot/../Modules/FzfBindings
}

Complete-Once install-as-tree {
    cargo install -f --git https://github.com/jez/as-tree
}

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

tm (Split-Path $PSCommandPath -Leaf)
