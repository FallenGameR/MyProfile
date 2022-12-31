# Some commands here use sudo, but we can't demand that
# whole script is run under root. We need identity of a current
# user but root privileges here.

Complete-Once "Unix apps" {
    $apps = cat "$PSScriptRoot/../Data/unix-apps.txt"
    sudo apt install @apps -y
}

Complete-Once "Fzf git install" {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

Complete-Once "Git-fuzzy git install" {
    git clone https://github.com/bigH/git-fuzzy.git ~/.git-fuzzy
    # It is added to PATH elsewhere
}

Complete-Once "Bat proper name" {
    cd /usr/bin
    sudo ln -s batcat bat
}

Complete-Once "Fzf link" {
    cd /usr/bin
    sudo ln -s ~/.fzf/bin/fzf fzf
    sudo ln -s ~/.fzf/bin/fzf-tmux fzf-tmux
}

<#

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow

#>

tm (Split-Path $PSCommandPath -Leaf)