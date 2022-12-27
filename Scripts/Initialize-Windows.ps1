# Path setup
$addToPath =
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\Winamp\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\tools\chafa"
$env:Path += ";" + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join ";")

# Common functions
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

# Default classic Powershell setup
Complete-Once "Classic Powershell" {
    $classic = "$env:USERPROFILE\Documents\WindowsPowershell"
    $modern = "$env:USERPROFILE\Documents\Powershell"
    mkdir $classic | Out-Null
    ". $modern\profile.ps1" > "$classic\Microsoft.PowerShell_profile.ps1"

    pushd $classic
    New-Item -Type Junction -Name Modules -Value "$modern\Modules"
    popd
}

# Default conhost console color setup
Complete-Once "ColorTool" {
    Push-Location "$PsScriptRoot\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
    Pop-Location
}

# Set up environment variables
Complete-Once "Environment vars" {
    Set-EnvironmentVariable "AzCompute" $azcompute
    Set-EnvironmentVariable "ApGold" $apgold
    Set-EnvironmentVariable "PfGold" $pfgold
    Set-EnvironmentVariable "NTP" $ntp
    Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $homeSimplified = $env:USERPROFILE -replace "\.$($env:USERDOMAIN)$"
    if( -not (Test-Path $homeSimplified -ea Ignore) )
    {
        $homeSimplified = $env:USERPROFILE
    }
    Set-EnvironmentVariable "Home" $homeSimplified
}

tm (Split-Path $PSCommandPath -Leaf)