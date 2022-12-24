# Path setup
$addToPath =
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\Winamp\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\tools\chafa"
$env:Path += ";" + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join ";")