# Some commands here use sudo, but we can't demand that
# whole script is run under root. We need identity of a current
# user but root privileges here.

Complete-Once "Unix apps" {
    $apps = cat "$PSScriptRoot/../../Data/unix-apps.txt"
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

Complete-Once "Arduino fix" {
    # see https://bugs.launchpad.net/ubuntu/+source/arduino/+bug/1916278
    sudo apt install libserialport0 patchelf
    sudo patchelf --add-needed /usr/lib/x86_64-linux-gnu/libserialport.so.0 /usr/lib/x86_64-linux-gnu/liblistSerialsj.so.1.4.0
}

<#

Spell-checker: disable

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow


https://rustup.rs
rustup toolchain install nightly
sudo apt install avr-libc gcc-avr pkg-config avrdude libudev-dev build-essential

dialout group can upload firmware to arduino board
#>

tm (Split-Path $PSCommandPath -Leaf)