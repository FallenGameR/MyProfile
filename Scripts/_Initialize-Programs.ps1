#Requires -RunAsAdministrator


Find-Package ack -Provider chocolatey | Install-Package -Force -ForceBootstrap -Verbose
Install-package –ProviderName chocolatey –Force –FirceBootStrap –Verbose –Name <package>



Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install git -y
choco install gitextensions -y
choco install kdiff3 -y
choco install code -y
choco install ilspy -y
choco install sysinternals -y

Clone PSToolbox
Run git setup from PSToolbox

Create junction to the tools?