Complete-Once env-computer {
    Set-EnvironmentVariable "mv"                "v:\src\mv\"
    Set-EnvironmentVariable "config"            "v:\src\config\"
    Set-EnvironmentVariable "docs"              "v:\src\docs\"
    Set-EnvironmentVariable "investigations"    "v:\src\ntp\"
    Set-EnvironmentVariable "PfGold"            "v:\src\golds\pf\"
}

. $PSScriptRoot\..\Initialize-Work.ps1

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

    # cargo install bandwhich
    # winget install npcap
    # $env:path += ";c:\Windows\System32\Npcap\"
}

Complete-Once install-sds {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/chmln/sd.git
    cd sd

    cargo build -r

    # cargo install -f --git https://github.com/chmln/sd.git
}

Complete-Once junction-one-drive-ms {
    New-Item -ItemType Junction -Name "D:\OneDrive.MS" -Target $env:OneDriveCommercial -ea Ignore
    Set-EnvironmentVariable "OneDriveCommercial" "D:\OneDrive.MS"
}

# Use starship for prompt
if( Get-Command starship -ea Ignore )
{
    $env:STARSHIP_CONFIG = "$PSScriptRoot\..\..\Tools\starship\starship.toml"
    $env:STARSHIP_CACHE = "$PSScriptRoot\..\..\Tools\starship\logs"
    #$env:STARSHIP_LOG = "trace"
    Invoke-Expression (&starship init powershell)
}

# Use zoxide for directory navigation
if( Get-Command zoxide -ea Ignore )
{
    $env:ZOXIDE_DATA_DIR = "$PSScriptRoot\..\..\Tools\zoxide\data"
    $env:ZOXIDE_CACHE_DIR = "$PSScriptRoot\..\..\Tools\zoxide\cache"
    $env:ZOXIDE_CONFIG_DIR = "$PSScriptRoot\..\..\Tools\zoxide\config"
    #Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

tm (Split-Path $PSCommandPath -Leaf)
