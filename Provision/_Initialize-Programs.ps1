#Requires -RunAsAdministrator


#Find-Package ack -Provider chocolatey | Install-Package -Force -ForceBootstrap -Verbose
#Install-package –ProviderName chocolatey –Force –FirceBootStrap –Verbose –Name <package>


# powershell admin
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Add windows exclusion folder (during installations)?
C:\ProgramData\chocolatey\lib, C:\src as well

# new admin console
choco install powershell-core -y
choco install googlechrome -y
choco install firacode -y
choco install less -y
choco install gimp -y
choco install mp3tag -y

choco install vscode git gitextensions kdiff3 -y
choco install microsoft-teams microsoft-windows-terminal visualstudio2019enterprise -y
choco install miniconda3 --params="'/AddToPath:1'" -y

#Clone PSToolbox


choco install beyondcompare -y
choco install ilspy -y
choco install sysinternals -y
choco install windirstat -y
choco install linqpad5 -y

# Conda installation
conda install ipython jupyter -y

# Also for visual studio update with .NET templates is needed
choco install visualstudio2019-workload-azure -y
choco install visualstudio2019-workload-manageddesktop -y
choco install visualstudio2019-workload-nativedesktop -y
choco install visualstudio2019-workload-netcoretools -y
