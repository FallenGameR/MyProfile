#Requires -RunAsAdministrator

# Install chocolatey, winget as of now doesn't have all the packages
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# For bootstrap we need just git and this module
choco install -s=chocolatey git -y
$destination = "$home/Documents/Powershell"
git clone https://github.com/FallenGameR/MyProfile.git $destination

"To speed things up make sure defender ignores folders like C:\src"
# C:\ProgramData\chocolatey\lib may be another candidate