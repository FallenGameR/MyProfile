Complete-Once env-computer {
    Set-EnvironmentVariable "AzCompute" "d:\src\mv\"
    Set-EnvironmentVariable "ApGold" "d:\src\golds\ap\"
    Set-EnvironmentVariable "PfGold" "d:\src\golds\pf\"
    Set-EnvironmentVariable "NTP" "d:\src\ntp\"
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

tm (Split-Path $PSCommandPath -Leaf)
