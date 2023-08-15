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

Complete-Once setup-trackball {
    & "$env:OneDriveConsumer\Apps\Hardware\Deft Pro Trackball\mouse_driver_ma5111000.exe"
}

Complete-Once setup-bottom {
    if( -not (Test-Path $env:APPDATA\bottom) )
    {
        mkdir $env:APPDATA\bottom -ea Stop | Out-Null
    }
    Copy-Item $PSScriptRoot\..\..\bottom.toml $env:APPDATA\bottom\bottom.toml
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
    cd "$PsScriptRoot\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
}

Complete-Once setup-environment-permanent {
    Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $homeSimplified = $env:USERPROFILE -replace "\.$($env:USERDOMAIN)$"
    if( -not (Test-Path $homeSimplified -ea Ignore) )
    {
        $homeSimplified = $env:USERPROFILE
    }
    Set-EnvironmentVariable "Home" $homeSimplified
}

tm (Split-Path $PSCommandPath -Leaf)