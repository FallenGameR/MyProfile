Complete-Once "Unix apps" {
    $apps = cat "$PSScriptRoot/unix-apps.txt"
    sudo apt install @apps -y
}

tm (Split-Path $PSCommandPath -Leaf)