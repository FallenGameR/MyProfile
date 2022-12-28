Complete-Once "Unix apps" {
    $apps = cat "$PSScriptRoot/../Data/unix-apps.txt"
    sudo apt install @apps -y
}

tm (Split-Path $PSCommandPath -Leaf)