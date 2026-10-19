Complete-Once env-computer {
    Set-EnvironmentVariable "mv"                "c:\src\Azure-Compute-Move\"
    Set-EnvironmentVariable "config"            "c:\src\config\"
    Set-EnvironmentVariable "docs"              "C:\src\docs\"
    Set-EnvironmentVariable "investigations"    "c:\src\ntp\investigations\"
    Set-EnvironmentVariable "PfGold"            "c:\src\golds\pf\"
}

$env:PSModulePath = "$env:PSModulePath;C:\src\mv\src\Client\NTP\scripts\modules\Clocks"
$env:PSModulePath = "$env:PSModulePath;C:\src\Azure-Time-Geneva\src\scripts\"