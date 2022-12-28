Complete-Once "Unix apps" {
    $apps = cat "$PSScriptRoot/../Data/unix-apps.txt"
    sudo apt install @apps -y
}

<#

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow

#>

tm (Split-Path $PSCommandPath -Leaf)