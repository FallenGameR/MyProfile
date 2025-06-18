# Common pwsh commands
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

# Path setup
$addToPath =
    "C:\Program Files\Git\usr\bin\",        # GNU tools
    "C:\Program Files\Python311\Scripts\",  # For httpie when python was installed from the main web site
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\Program Files (x86)\Winamp\",
    "C:\tools\chafa",                       # console picture viewer
    "C:\tools\sd",                          # sds replacer
    "C:\tools\tagger"
$env:PATH += [io.path]::PathSeparator + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join [io.path]::PathSeparator)

tm (Split-Path $PSCommandPath -Leaf)