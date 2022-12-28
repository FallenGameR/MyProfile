Complete-Once "Computer-specific environment vars" {
    Set-EnvironmentVariable "AzCompute" "d:\src\mv\"
    Set-EnvironmentVariable "ApGold" "d:\src\golds\ap\"
    Set-EnvironmentVariable "PfGold" "d:\src\golds\pf\"
    Set-EnvironmentVariable "NTP" "d:\src\ntp\"
}

tm (Split-Path $PSCommandPath -Leaf)
