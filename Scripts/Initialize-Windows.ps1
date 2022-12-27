# Path setup
$addToPath =
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\Winamp\",
    "C:\Program Files (x86)\LINQPad5\",
    "C:\tools\chafa"
$env:Path += ";" + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join ";")

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

# Tools folder setup and update
Complete-Once "Tools folder creation" {
    if( -not (Test-Path "c:\tools") )
    {
        mkdir "c:\tools" -ea Stop | Out-Null
    }
}

foreach( $tool in ls $env:OneDriveConsumer\Apps\tools -Directory -ea Ignore | where Name -notmatch "^_" )
{
    New-Junction $tool.FullName "c:\tools\$($tool.Name)"
}

foreach( $tool in ls $env:OneDriveCommercial\tools -Directory -ea Ignore | where Name -notmatch "^_" )
{
    New-Junction $tool.FullName "c:\tools\$($tool.Name)"
}

tm (Split-Path $PSCommandPath -Leaf)