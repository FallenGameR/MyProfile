# Winget

Functionality was added in 1.11 (needs Win preview)

```ps1
# Winget search
winget search remark
winget show -q reMarkable.reMarkableCompanionApp
```

C:\Users\alexk\AppData\Local\lf\lfrc

```
set previewer C:\\Users\\alexk\\Documents\\Powershell\\Data\\Winget\\preview.bat
set sixel
```

C:\Users\alexk\.config\starship.toml
`Stow` that creates symlinks for whole folders on Linux
https://www.chezmoi.io/install/#__tabbed_4_3

```ps1
# New dependencies
winget settings
winget install starship zoxide

copy C:\Users\alexko.REDMOND\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json C:\Users\alexko\Documents\Powershell\winget.settings.json

copy C:\Users\alexko\Documents\Powershell\winget.settings.json C:\Users\alexko.REDMOND\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json 

# Configuration
winget configure export --all -o C:\Users\alexk\Documents\Powershell\Data\configure-alexko11.winget  --verbose-logs --logs
winget configure export --all -o C:\Users\alexko\Documents\Powershell\Data\Winget\configure-alexko11.winget --verbose-logs --logs
winget configure C:\Users\alexk\Documents\Powershell\Data\configure-ranma.winget

```
