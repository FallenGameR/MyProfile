Complete-Once "Computer-specific environment vars" {
    Set-EnvironmentVariable "AzCompute" "d:\src\mv\"
    Set-EnvironmentVariable "ApGold" "d:\src\golds\ap\"
    Set-EnvironmentVariable "PfGold" "d:\src\golds\pf\"
    Set-EnvironmentVariable "NTP" "d:\src\ntp\"
}

Complete-Once "bandwhich" {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/imsnif/bandwhich.git
    cd bandwhich

    cargo vendor

    # Apply build patch https://github.com/imsnif/bandwhich/pull/234/commits/424e96cc27aefc80d25ac883987a62fd9c93c2f9
    sds "https://nmap.org/npcap/dist/npcap-sdk-1.05.zip" "https://npcap.com/dist/npcap-sdk-1.05.zip" build.rs
    cargo install --offline --path .
}

Complete-Once "sd" {
    mkdir c:\tools\rust\
    cd c:\tools\rust\
    git clone https://github.com/chmln/sd.git
    cd sd

    cargo build -r
}

tm (Split-Path $PSCommandPath -Leaf)
