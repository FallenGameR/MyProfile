Complete-Once "Mouse setup" {
    & "$env:OneDriveConsumer\Distrib\Hardware\Deft Pro Trackball\mouse_driver_ma5111000.exe"
}

Complete-Once "tldr update" {
    tldr --update
}

Complete-Once "Tools folder" {
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

tm (Split-Path $PSCommandPath -Leaf)