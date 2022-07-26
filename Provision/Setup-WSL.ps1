#Requires -RunAsAdministrator

# This command can forcefully reboot machine, don't excecute if something else is running
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
https://aka.ms/wsl2kernel
wsl --set-default-version 2

# All distribs
sudo apt update && sudo apt upgrade -y
sudo apt install fortune cowsay lolcat htop mc tmux cmatrix bat -y

# Doesn't work, ~/.local/bin is not added by default to path
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Kali only
sudo apt install -y kali-linux-default kali-win-kex zsh zsh-syntax-highlighting zsh-autosuggestions

cp /etc/skel/.zshrc ~/
chsh -s /bin/zsh
