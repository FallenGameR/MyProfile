# Empties the system working set as RAMMap's Empty > Empty System Working Set does. It releases
# the file system metadata cache (Metafile in RAMMap) that otherwise grows to tens of GB.
# Runs elevated from the "Empty system working set" scheduled task and appends each result to
# Data/SystemCache/clear-log.csv, which git ignores.

$ErrorActionPreference = "Stop"

$rammap = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Microsoft.Sysinternals.Suite_Microsoft.Winget.Source_8wekyb3d8bbwe\RAMMap.exe"
if( -not (Test-Path $rammap) )
{
    $rammap = (Get-Command RAMMap64, RAMMap -ea Ignore | select -First 1).Source
}
if( -not $rammap ) { throw "RAMMap not found, install Microsoft.Sysinternals.Suite with winget" }

# Task Manager's "In use" is the total minus available memory
function Get-InUseGB
{
    $total = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $available = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue / 1KB
    $total - $available
}

$before = Get-InUseGB
Start-Process $rammap "-accepteula -Es" -Wait -WindowStyle Hidden
Start-Sleep -Seconds 2
$after = Get-InUseGB

$logFolder = "$PSScriptRoot/../../Data/SystemCache"
New-Item -ItemType Directory $logFolder -Force | Out-Null
[pscustomobject] @{
    Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    InUseBeforeGB = [math]::Round($before, 2)
    InUseAfterGB = [math]::Round($after, 2)
    FreedGB = [math]::Round($before - $after, 2)
} | Export-Csv "$logFolder/clear-log.csv" -Append -NoTypeInformation
