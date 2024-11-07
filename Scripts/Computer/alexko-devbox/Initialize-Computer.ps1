Complete-Once env-computer {
    Set-EnvironmentVariable "mv"                "c:\src\Azure-Compute-Move\"
    Set-EnvironmentVariable "config"            "c:\src\config\"
    Set-EnvironmentVariable "docs"              "C:\src\docs\"
    Set-EnvironmentVariable "investigations"    "c:\src\ntp\investigations\"
    Set-EnvironmentVariable "PfGold"            "c:\src\golds\pf\"
}

. $PSScriptRoot\..\Initialize-Work.ps1

Complete-Once junction-one-drive-ms {
    New-Item -ItemType Junction -Name "D:\OneDrive.MS" -Target $env:OneDriveCommercial -ea Ignore
    Set-EnvironmentVariable "OneDriveCommercial" "D:\OneDrive.MS"
}

tm (Split-Path $PSCommandPath -Leaf)
