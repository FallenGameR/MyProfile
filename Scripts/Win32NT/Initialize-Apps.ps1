Complete-Once "Mouse setup" {
    & "$env:OneDriveConsumer\Apps\Hardware\Deft Pro Trackball\mouse_driver_ma5111000.exe"
}

Complete-Once "Tools junction links" {
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

Complete-Once "Bottom setup" {
    if( -not (Test-Path $env:APPDATA\bottom) )
    {
        mkdir $env:APPDATA\bottom -ea Stop | Out-Null
    }
    Copy-Item $PSScriptRoot\..\..\bottom.toml $env:APPDATA\bottom\bottom.toml
}

Complete-Once fd-excludes {
    $path = $env:APPDATA
    mkdir "$path\fd" -ea Ignore | Out-Null
    cat "$PsScriptRoot/../../Modules/FzfBindings/Data/excluded_folders" > $path/fd/ignore
}

tm (Split-Path $PSCommandPath -Leaf)