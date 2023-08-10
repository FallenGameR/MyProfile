# Some commands here use sudo, but we can't demand that
# whole script is run under root. We need identity of a current
# user but root privileges here.

# Spell-checker: disable

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

Complete-Once "Install chrome" {
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
    sudo apt update
    sudo apt install google-chrome-stable
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

Complete-Once "Install bottom" {
    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.4/bottom_0.9.4_amd64.deb
    sudo dpkg -i bottom_0.9.4_amd64.deb
}

Complete-Once "Install rust" {
    sudo apt update
    sudo apt upgrade
    sudo apt install curl gcc make build-essential -y
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

Complete-Once "Rust arduino" {
    # https://blog.logrocket.com/complete-guide-running-rust-arduino/
    rustup toolchain install nightly
    sudo apt install avr-libc gcc-avr pkg-config avrdude libudev-dev build-essential -y
    cargo +stable install ravedude
    cargo install cargo-generate
}

Complete-Once "Gnome terminal colors" {
    cd "$PsScriptRoot/../../Bin/ColorTool/"
    cat ./campbell.gnome_terminal | dconf load /org/gnome/terminal/
}

Complete-Once "Bottom setup" {
    Copy-Item $PSScriptRoot\..\..\bottom.toml ~/.config/bottom/bottom.toml
}

<#

In Linux the analog of Sysinternals Suite would be:

ldd - get list of used shared libraries (.so|.dll)
strace - see what syscalls an executable makes
lsof - list of opened files and sockets per folder

#>

<#

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