Complete-Once env-computer {
    Set-EnvironmentVariable "mv"                "c:\src\mv\"
    Set-EnvironmentVariable "config"            "c:\src\config\"
    Set-EnvironmentVariable "investigations"    "c:\src\investigations\"
    Set-EnvironmentVariable "PfGold"            "c:\src\golds\pf\"
}

. $PSScriptRoot\..\Initialize-Work.ps1

tm (Split-Path $PSCommandPath -Leaf)
