# Winget

Functionality was added in 1.11 (needs Win preview)

```ps1
# Winget search
winget search remark

# New dependencies
winget settings
winget install starship zoxide

# Manual sync of winget settings
copy C:\Users\alexko.REDMOND\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json C:\Users\alexko\Documents\Powershell\winget.settings.json

copy C:\Users\alexko\Documents\Powershell\winget.settings.json C:\Users\alexko.REDMOND\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json 

# Configuration
winget configure export --all -o C:\Users\alexk\Documents\Powershell\Data\configure-alexko11.winget  --verbose-logs --logs
winget configure export --all -o C:\Users\alexko\Documents\Powershell\Data\Winget\configure-alexko11.winget --verbose-logs --logs
winget configure C:\Users\alexk\Documents\Powershell\Data\configure-ranma.winget
```
