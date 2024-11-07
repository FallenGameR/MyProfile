Complete-Once "Computer-specific environment vars" {
    Set-EnvironmentVariable "AzCompute" "D:\src\mv\"
    Set-EnvironmentVariable "ApGold" "D:\src\golds\ap\"
    Set-EnvironmentVariable "PfGold" "D:\src\golds\pf\"
    Set-EnvironmentVariable "NTP" "D:\src\ntp\"
}

tm (Split-Path $PSCommandPath -Leaf)
