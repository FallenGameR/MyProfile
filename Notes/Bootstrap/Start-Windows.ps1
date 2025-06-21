# Get the repo
winget install Git.Git
git clone https://github.com/FallenGameR/MyProfile.git "$home/Documents/Powershell"

# Install apps, winget
cd "$home/Documents/Powershell"
Get-Content "Data\winget-apps.txt" | foreach{ winget install $psitem --accept-package-agreements }

# Install apps, choco has still two apps missing from winget
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
gsudo choco install -s=chocolatey firacode geforce-game-ready-driver -y

# Notes
"If defender is slow maybe exclude C:\src from scanning"
