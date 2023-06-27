# Path setup
$addToPath =
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\Winamp\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\Program Files\Git\usr\bin\",
    "c:\tools\miniconda3\",
    "c:\tools\miniconda3\Scripts\",
    "c:\tools\miniconda3\Library\bin\",
    "C:\tools\chafa",
    "C:\tools\sd",
    "C:\tools\docfx"
$env:PATH += [io.path]::PathSeparator + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join [io.path]::PathSeparator)

# Common functions
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

# tldr database update
Complete-Once "tldr update" {
    tldr --update
}

# Default classic Powershell setup
Complete-Once "Classic Powershell" {
    $classic = "$env:USERPROFILE\Documents\WindowsPowershell"
    $modern = "$env:USERPROFILE\Documents\Powershell"
    mkdir $classic | Out-Null
    ". $modern\profile.ps1" > "$classic\Microsoft.PowerShell_profile.ps1"

    cd $classic
    New-Item -Type Junction -Name Modules -Value "$modern\Modules"
}

# Default conhost console color setup
Complete-Once "ColorTool" {
    cd "$PsScriptRoot\..\Bin\ColorTool\"
    .\ColorTool.exe -b -q campbell | Out-Null
}

# Set up environment variables
Complete-Once "Environment vars" {
    Set-EnvironmentVariable "Startup" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $homeSimplified = $env:USERPROFILE -replace "\.$($env:USERDOMAIN)$"
    if( -not (Test-Path $homeSimplified -ea Ignore) )
    {
        $homeSimplified = $env:USERPROFILE
    }
    Set-EnvironmentVariable "Home" $homeSimplified
}

tm (Split-Path $PSCommandPath -Leaf)