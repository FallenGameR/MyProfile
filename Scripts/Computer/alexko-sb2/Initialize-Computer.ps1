Complete-Once "Computer-specific environment vars" {
    Set-EnvironmentVariable "AzCompute" "c:\src\mv\"
    Set-EnvironmentVariable "ApGold" "c:\src\gold\ap\"
    Set-EnvironmentVariable "PfGold" "c:\src\gold\pf\"
    Set-EnvironmentVariable "NTP" "C:\src\ntp\"
}

tm (Split-Path $PSCommandPath -Leaf)
