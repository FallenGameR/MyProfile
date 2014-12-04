<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.
#>

function scd
{
    param
    (
        [ValidateSet("Override", "Diff", "Submit")]
        [string] $command
    )

    if( $command -eq "Override" )
    {
        APConfigTool Override -s ServiceBusNode -f ServiceConfig.ini
        $override = ls | sort LastWriteTime -Descending | select -f 1
        edit $override
    }

    if( $command -eq "Diff" )
    {
        $override = ls | sort LastWriteTime -Descending | select -f 1
        APConfigTool Diff -f $override.FullName
    }

    if( $command -eq "Submit" )
    {
        $override = ls | sort LastWriteTime -Descending | select -f 1
        sd add $override.FullName
        sd submit
    }
}

function xts
{
    & "c:\tools\xts\xts.exe"
}

filter Set-ReadOnlyFlag( [bool] $flag = $true )
{
    if( -not $psitem.PsIsContainer )
    {
        Set-ItemProperty $psitem.FullName -Name "IsReadOnly" -Value $flag
    }
}

function msdump( $path )
{
    & $PSScriptRoot\msdump\MSBuildDumpConsoleApplication.exe $path
}

# XML
filter Find-Xml( $xpath )
{
    [Xml.Xpath.Extensions]::XPathSelectElement($psitem, $xpath)

    <#
# Extract XML snippets locations from cluster.xml
$document = [Xml.Linq.XDocument]::Load($edge.ClusterFile, [Xml.Linq.LoadOptions]::SetLineInfo)
$vlan = $document | find ("//Vlan[@vlanId='{0}']" -f $edge.VlanId)
$coreSwitchSet = ($document | find ("//CoreSwitchVlan[@vlanId='{0}']" -f $edge.VlanId)).Parent.Parent
$pod = $document | find ("//Pod[@rack='{0}']" -f $edge.RackFloor)
    #>
}

function Extract-Xml( $xelement )
{
<#
$document = [Xml.Linq.XDocument]::Load((gi "cluster.xml" | % fullname), [Xml.Linq.LoadOptions]::SetLineInfo)
$switch = $document | find ("//MiniSwitch[@hostname='{0}']" -f "DM2DCFX02001AALF")
$clusterXml = $document
Extract-Xml $switch
#>
    $lineNumber = $xelement.LineNumber - 1
    $endMarker = $xelement.ToString() | parse "(\S+)$"

    do
    {
        $line = $clusterXml[$lineNumber++]
        $line
    }
    until( $line.Contains($endMarker) )
}

# Playground

filter Parse-AutopilotLog
{
    $parsed = $psitem | parse '^([^,]+),([^,]+),([^,]+),([^,]+),SrcFile="([^"]+)" SrcFunc="([^"]+)" SrcLine="(\d+)" Pid="(\d+)" Tid="(\d+)" TS="([^"]+)" String1="([^"]+)"' Type Time LocationA LocationB File Function Line Pid Tid TS Info

    if( $parsed )
    {
        $parsed
    }
    else
    {
        $psitem
    }
}

function Cluster-Check( [string] $name )
{
    if( -not $name )
    {
        $name = $pwd | parse "autopilotService\\([^\\]+)"
    }

    Write-Host "Checking cluster: $name" -fore DarkGreen

    $searchGold = (Get-Enlistment data).Root
    Push-Location "$searchGold\AutopilotService"
    & "$searchGold\tools\vlad\CheckCluster2\CheckCluster.exe" -c $name | Parse-AutopilotLog
    Pop-Location
}

function Cluster-Tool
{
    $searchGold = (Get-Enlistment data).Root
    $path = "$searchGold\AutopilotService\global\SelfServe_EnvMngmt\~AutomationSettings\Tools\ClusterTool.exe"
    #$path = "c:\Users\alexko\Downloads\ClusterTool.exe"
    & $path $args | Parse-AutopilotLog
}

function Cluster-PreattyPrint( [string] $name )
{
    if( -not $name )
    {
        $name = $pwd | parse "autopilotService\\([^\\]+)"
    }

    Write-Host "Preatty print for cluster: $name" -fore DarkGreen

    $searchGold = (Get-Enlistment data).Root
    $path = "$searchGold\autopilotService\$name"
    Cluster-Tool PrettyPrint $path
}

function clean( [switch] $force ) { if( $force ) { git clean -fdx -e sd.ini } else { git clean -ndx -e sd.ini } }

function change( $from, $to, $encoding = "ascii" )
{
    $files = git grep -iFl "$from"
    $files | foreach{ (type $psitem) -replace [regex]::Escape($from), $to | Set-Content $psitem -Encoding $encoding }
}

function srch( $text ) {git grep -iF $text}

# Invocations
function ref( $text )
{
    Push-Location "S:\data-git\autopilotService"
    git grep -iF $text `-- *.csv, *.ini, *.xml, *.txt
    Pop-Location
}

function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" (pwd) }

function edit( [string] $File, [switch] $NewEditor )
{
    $position = $file | parse ":(\d+):?"
    $file = Get-FileNameArgument ($file -replace ":\d+:?")

    if( (Get-Item $file).PSIsContainer )
    {
        Write-Warning "'$file' is a directory."
        return
    }

    $params = @()

    if( (-not $newEditor) -and (-not $position) )
    {
        # http://vim.wikia.com/wiki/Launch_files_in_new_tabs_under_Windows
        $params += "--remote-tab-silent"
    }

    $params += $file

    if( $position )
    {
        $params += "+$position"
    }

    & gvim.exe $params
}

function Get-RecentBuild
{
<#
finished.txt doesn't garantee that the build was actually successfull.
Build tracker API: https://microsoft.sharepoint.com/teams/buildtrackerv2/bt40apidocs/Pages/Home.aspx?noredirect=1
WTT API (less preferred):
    //depot/dev/autopilot/private/tools/ReleaseStatusTool/queries/...
    //depot/dev/autopilot/private/tools/ReleaseStatusTool/WttApi.ps1
#>
    $location = ls "\\BINGLAB\builds\search\autopilot\rolling\*\finished.txt" | select -last 1
    $location = Split-Path $location
    $location = Join-Path $location "retail\amd64"
    start $location
}

function cf
{
    & \\codeflow\public\cf $args
}

# Helpers
function Get-PrivateReviewInfo
{
@"
Developer folder: <description>`r`n
Author: alexko
Tested by: alexko
Buddy build by: No buddy build. This change modifies script files excluded from the build. | Change happened in privite developer folder.
Reviewed by: No code review. Change happened in privite developer folder.
Description:
"@
}

function Get-FileNameArgument( [string] $file )
{
    if( -not $file ) { return }

    if( -not (Test-Path $file) )
    {
        $repositoryRoot = git rev-parse --show-toplevel 2>$null
        if( $repositoryRoot )
        {
            $file = Join-Path $repositoryRoot $file
        }
    }

    if( Test-Path $file )
    {
        (gi $file).FullName
    }
}

function dump( [string] $str ) { for( $i=0; $i -lt $str.Length; $i += 1 ) { $char = $str[$i]; $num = [int] $char; "$char - $num" } }

function Find-VSCommand( [string] $command )
{
    $file = Join-Path (Split-Path $Profile) "vscommands.txt"
    gc $file | where{ $_ -match $command }
}
