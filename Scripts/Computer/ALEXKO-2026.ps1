Complete-Once env-computer {
    Set-EnvironmentVariable "mv"                "v:\src\mv\"
    Set-EnvironmentVariable "config"            "v:\src\config\"
    Set-EnvironmentVariable "docs"              "v:\src\docs\"
    Set-EnvironmentVariable "investigations"    "v:\src\ntp\"
    Set-EnvironmentVariable "PfGold"            "v:\src\golds\pf\"
}

$env:PSModulePath = "$env:PSModulePath;v:\src\Azure-Time-Geneva\src\scripts\"

function gitex
{
    & V:\src\github\gitextensions\artifacts\Release\bin\GitExtensions\net10.0-windows\GitExtensions.exe
}