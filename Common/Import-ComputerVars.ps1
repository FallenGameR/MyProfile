switch ($env:ComputerName)
{
    "ALEXKO-LS"
    {
        $azcompute = "D:\src\mv\"
        $apgold = "D:\src\golds\ap\"
        $pfgold = "D:\src\golds\pf\"
        $ntp = "D:\src\ntp\"
    }
    "ALEXKO-SB2"
    {
        $azcompute = "c:\src\mv\"
        $apgold = "c:\src\gold\ap\"
        $pfgold = "c:\src\gold\pf\"
        $ntp = "C:\src\ntp\"
    }
    "ALEXKO-11"
    {
        $azcompute = "d:\src\mv\"
        $apgold = "d:\src\golds\ap\"
        $pfgold = "d:\src\golds\pf\"
        $ntp = "d:\src\ntp\"
    }
}
$oneDrive = $env:OneDriveConsumer
$oneDriveMicrosoft = $env:OneDriveCommercial

tm (Split-Path $PSCommandPath -Leaf)