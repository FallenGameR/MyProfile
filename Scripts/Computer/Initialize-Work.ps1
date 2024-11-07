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
$env:FZF_BINDINGS_GIT_LINE_ENDINGS_MITIGATION =
    "src/Services/rwf/bootstrap/ComponentBootstrap/Test/TestContent/Rdm/Decom/Inventory.xml;" +
    "src/Services/NeMo/NetMgr/ConfigPolicyVerifier/ConfigArchiveServiceMain/files/SecretConfigBleu.json;" +
    "src/Services/NeMo/NetMgr/ConfigPolicyVerifier/ConfigQueryServiceMain/files/SecretConfigBleu.json;" +
    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/ControlPlaneGraph.xml;" +
    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/DataPlaneGraph.xml;" +
    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/DeviceMetadata.xml;" +
    "src/Services/NeMo/NetMgr/Test/ComponentTest/NDM.Test.Common/Files/TestGraphs/PortChannelPort_DefaultMtu_CheckMtuValue/PhysicalNetworkGraph.xml"
# Update-GitLineEndingsMitigation

# FZF quick paths
$env:FZF_QUICK_PATHS =
    "$env:mv\src\Client\NTP\;" +
    "$env:mv\src\Client\NTP\scripts\s1-tools\;" +
    "$env:mv\src\Client\NTP\scripts\modules\DriScripts\;" +
    "$env:PfGold\data\Autopilot\NtpReferenceClock\Firmware\"

# Reload DriScripts module
function reload( [switch] $Official )
{
    Get-Module DriScripts | Remove-Module

    if( $Official )
    {
        Import-Module C:\tools\DriScripts\DriScripts\DriScripts.psd1 -Force
    }
    else
    {
        Import-Module DriScripts -Force
    }

    Get-Module DriScripts | select name, version, path
}

# Stratum1 tools
function s1( $name ) { & $env:mv\src\Client\NTP\scripts\s1-tools\Initialize-Stratum1.ps1 $name | code - }

#$env:PSModulePath = "C:\src\mv\src\Client\NTP\scripts\modules;$env:PSModulePath"
#Set-DsSetting -CockpitQueryFolder "c:\tools\DriScripts\CockpitQuery\"

tm (Split-Path $PSCommandPath -Leaf)

