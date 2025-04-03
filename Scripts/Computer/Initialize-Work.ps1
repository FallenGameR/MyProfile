# Tools availability
$env:Path += ";C:\tools\FcShell"
$env:Path += ";C:\tools\dcm.explorer"
$env:Path += ";C:\tools\xts"
$env:Path += ";C:\tools\drop"
$env:Path += ";C:\tools\lens"
$env:Path += ";C:\tools\prorab"
$env:Path += ";C:\tools\oneAccess"
$env:Path += ";C:\tools\sd"

# Modules availability
$env:PSModulePath = "$env:PSModulePath;C:\tools\DriScripts"
$env:PSModulePath = "C:\tools\JitShell;$env:PSModulePath"
$env:PSModulePath = "C:\tools\TipNodeServiceAME;$env:PSModulePath"

# Line endings mitigation
#$env:FZF_BINDINGS_GIT_LINE_ENDINGS_MITIGATION =
#    "src/Services/rwf/bootstrap/ComponentBootstrap/Test/TestContent/Rdm/Decom/Inventory.xml;" +
#    "src/Services/NeMo/NetMgr/ConfigPolicyVerifier/ConfigArchiveServiceMain/files/SecretConfigBleu.json;" +
#    "src/Services/NeMo/NetMgr/ConfigPolicyVerifier/ConfigQueryServiceMain/files/SecretConfigBleu.json;" +
#    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/ControlPlaneGraph.xml;" +
#    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/DataPlaneGraph.xml;" +
#    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/DeviceMetadata.xml;" +
#    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/PhysicalNetworkGraph.xml"
# Update-GitLineEndingsMitigation
# Nowadays 'git reset --hard' and 'git checkout --force' seem to work instead

# FZF quick paths
$env:FZF_QUICK_PATHS =
    "$env:mv\src\Client\NTP\;" +
    "$env:docs\Products\Autopilot\Autopilot\;" +
    "$env:PfGold\data\Autopilot\NtpReferenceClock\Firmware\"

# Reload DriScripts module
function reload( [string] $Path, [switch] $FromTools )
{
    if( $Path -and $FromTools )
    {
        throw "Either -Path or -FromTools can be specified"
    }

    Get-Module DriScripts | Remove-Module

    if( $FromTools )
    {
        Import-Module C:\tools\DriScripts\DriScripts\DriScripts.psd1 -Force
    }
    elseif( $Path )
    {
        Import-Module $Path -Force
    }
    else
    {
        Import-Module DriScripts -Force
    }

    Get-Module DriScripts | select name, version, path
}

# Stratum1 tools
function s1( $name ) { & $env:mv\src\Client\NTP\scripts\s1-tools\Initialize-Stratum1.ps1 $name | code - }

# Settings sync
function Sync-Settings
{
    # Sync-Settings ADO PC Powershell
    # Sync-Settings ADO PC
    # Sync-Settings PC ADO
    # Sync-Settings ADO PC -AdoRoot V:\src\ntp\investigations

    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("ADO", "PC")]
        [string] $From,

        [Parameter(Mandatory=$true)]
        [ValidateSet("ADO", "PC")]
        [string] $To,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Terminal", "GitConfig", "VSCode", "Powershell")]
        [string[]] $Settings,

        [string] $AdoRoot = "C:\src\investigations",

        [switch] $IsSaw = ($env:USERDOMAIN -eq "AME")
    )

    # Sanity check
    if( $From -eq $To )
    {
        throw "From and To should be different"
    }

    $AdoRoot = $AdoRoot.TrimEnd("\")

    if( $IsSaw )
    {
        $sawSuffix = "-saw"
    }

    # By default sync all settings
    if( -not $Settings )
    {
        $Settings = @("Terminal", "GitConfig", "VSCode", "Powershell")
    }

    # Process each setting
    switch( $Settings ) {
        "Terminal" {
            $wtRoot = Get-Item $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*
            $params = switch( $From, $To ) {
                "ADO" { "$adoRoot\Work\SAW\Settings\wt-config$sawSuffix.json" }
                "PC"  { "$wtRoot\LocalState\settings.json" }
            }
            copy @params -Force
        }
        "GitConfig" {
            $params = switch( $From, $To ) {
                "ADO" { "$adoRoot\Work\SAW\Settings\.gitconfig" }
                "PC"  { "$env:USERPROFILE\.gitconfig" }
            }
            copy @params -Force
        }
        "VSCode"
        {
            $params = switch( $From, $To ) {
                "ADO" { "$adoRoot\Work\SAW\Settings\vscode-config.json" }
                "PC"  { "$env:APPDATA\Code\User\settings.json" }
            }
            copy @params -Force
        }
        "Powershell"
        {
            $docsRoot = Split-Path (Split-Path $profile)

            function Copy-Folder( $src, $dst )
            {
                ls $src -Recurse | where FullName -notmatch "\b(Modules|Bin|Completed|clixml)\b" | foreach {
                    $dstPath = $psitem.FullName `
                        -replace [regex]::Escape($src), [regex]::Escape($dst) `
                        -replace "\\+", "\" `
                        -replace "\\ ", " " `
                        -replace "\\\.", "."

                    if ($psitem.PSIsContainer) {
                        New-Item -ItemType Directory -Path $dstPath -Force | Out-Null
                    } else {
                        Copy-Item $psitem.FullName $dstPath -Force -Verbose
                    }
                }
            }

            $params = switch( $From, $To ) {
                "ADO" { "$adoRoot\Work\SAW\Profile\Powershell" }
                "PC"  { "$docsRoot\Powershell" }
            }
            Copy-Folder @params

            $params = switch( $From, $To ) {
                "ADO" { "$adoRoot\Work\SAW\Profile\WindowsPowershell" }
                "PC"  { "$docsRoot\WindowsPowershell" }
            }
            Copy-Folder @params
        }
    }
}

#$env:PSModulePath = "C:\src\mv\src\Client\NTP\scripts\modules;$env:PSModulePath"

tm (Split-Path $PSCommandPath -Leaf)

