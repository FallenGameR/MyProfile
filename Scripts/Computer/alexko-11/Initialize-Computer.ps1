Complete-Once env-computer {
    Set-EnvironmentVariable "mv" "v:\src\mv\"
    Set-EnvironmentVariable "ApGold" "v:\src\golds\ap\"
    Set-EnvironmentVariable "PfGold" "v:\src\golds\pf\"
    Set-EnvironmentVariable "ConfigGold" "v:\src\config\"
    Set-EnvironmentVariable "NTP" "v:\src\ntp\"
}

Complete-Once install-bandwhich {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/imsnif/bandwhich.git
    cd bandwhich

    cargo install bandwhich
    cargo vendor

    # Apply build patch https://github.com/imsnif/bandwhich/pull/234/commits/424e96cc27aefc80d25ac883987a62fd9c93c2f9
    sds "https://nmap.org/npcap/dist/npcap-sdk-1.05.zip" "https://npcap.com/dist/npcap-sdk-1.05.zip" build.rs
    cargo build -r
    cargo install --offline --path .
}

Complete-Once install-sds {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/chmln/sd.git
    cd sd

    cargo build -r
}

Complete-Once junction-one-drive-ms {
    New-Item -ItemType Junction -Name "D:\OneDrive.MS" -Target $env:OneDriveCommercial -ea Ignore
    Set-EnvironmentVariable "OneDriveCommercial" "D:\OneDrive.MS"
}

$env:Path = "$env:Path;C:\tools\FcShell"
$env:Path = "$env:Path;C:\tools\dcm.explorer"
$env:Path = "$env:Path;C:\tools\xts"
$env:Path = "$env:Path;C:\tools\drop"
$env:Path = "$env:Path;C:\tools\lens"
$env:Path = "$env:Path;C:\tools\prorab"
$env:Path = "$env:Path;C:\tools\oneAccess"

$env:PSModulePath = "$env:NTP\scripts\modules;$env:PSModulePath"
$env:PSModulePath = "C:\tools\JitShell;$env:PSModulePath"
$env:PSModulePath = "C:\tools\TipNodeServiceAME;$env:PSModulePath"
$env:PSModulePath = "$env:PSModulePath;C:\tools\DriScripts"

$env:FZF_BINDINGS_GIT_LINE_ENDINGS_MITIGATION =
    "src/Services/rwf/bootstrap/ComponentBootstrap/Test/TestContent/Rdm/Decom/Inventory.xml" # ;" +
# Update-GitLineEndingsMitigation

$env:FZF_QUICK_PATHS =
    "$env:mv\src\Client\NTP\;" +
    "$env:mv\src\Client\NTP\scripts\s1-tools\;" +
    "$env:mv\src\Client\NTP\scripts\modules\DriScripts\;" +
    "$env:PfGold\data\Autopilot\NtpReferenceClock\Firmware\"

function reload( [switch] $Official )
{
    Get-Module DriScripts | Remove-Module

    if( $Official )
    {
        Import-Module C:\tools\DriScripts\DriScripts\DriScripts.psd1 -Force
    }
    else
    {
        Import-Module DriScripts -Force
    }

    Get-Module DriScripts | select name, version, path
}

function s1( $name ) { & $env:mv\src\Client\NTP\scripts\s1-tools\Initialize-Stratum1.ps1 $name | code - }

tm (Split-Path $PSCommandPath -Leaf)
