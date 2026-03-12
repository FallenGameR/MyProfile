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

tm (Split-Path $PSCommandPath -Leaf)