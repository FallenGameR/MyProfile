$outPath = "D:\deploy.csv"

$ipAddress = Get-NetIPAddress | where AddressFamily -eq IPv4 | where PrefixOrigin -eq Dhcp | % IPAddress

$lastBootTimeManagement = Get-WmiObject Win32_OperatingSystem | % LastBootUpTime
$lastBootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastBootTimeManagement)
$uptime = (Get-Date) - $lastBootTime

$totalSpace = (Get-WmiObject win32_logicaldisk | where DeviceID -eq "C:" | % Size) / 1gb
$freeSpace = (Get-WmiObject win32_logicaldisk | where DeviceID -eq "C:" | % FreeSpace) / 1gb

ls C:\inetpub\logs\LogFiles\W3SVC1 -ea Ignore | sort LastWriteTime -Descending | select -skip 10 | del

$freeSpaceAfterCleanup = (Get-WmiObject win32_logicaldisk | where DeviceID -eq "C:" | % FreeSpace) / 1gb

net share DiscD=D:\ /grant:atmsops,FULL

$output = [PsCustomObject] [ordered] @{
    Computer =  $env:COMPUTERNAME
    IpAddress = $ipAddress
    Uptime = $uptime
    TotalSpace = $totalSpace
    FreeSpace = $freeSpace
    FreeSpaceAfterCleanup = $freeSpaceAfterCleanup
}

$output | Export-Csv -NoTypeInformation $outPath
