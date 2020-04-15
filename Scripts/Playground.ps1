<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.
#>

function Get-Song( $artist, $song )
{
    $music = "$oneDrive\music"
    $artists = ls $music -Directory | where BaseName -match $artist
    $artists | foreach{ ls $psitem.FullName -rec -file -force | where BaseName -match $song }
}

filter Set-ReadOnlyFlag( [bool] $flag = $true )
{
    if( -not $psitem.PsIsContainer )
    {
        Set-ItemProperty $psitem.FullName -Name "IsReadOnly" -Value $flag
    }
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

function change( $from, $to, $encoding = "ascii" )
{
    $files = git grep -iFl "$from"
    $files | foreach{ (type $psitem) -replace [regex]::Escape($from), $to | Set-Content $psitem -Encoding $encoding }
}

function srch( $text ) {git grep -iF $text}

# Invocations
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" (pwd) }

function edit( [string] $File, [switch] $SameEditor )
{
    $params = @()

    if( $SameEditor )
    {
        $params += "--reuse-window"
    }

    if( $File -match ":" )
    {
        $params += "--goto"
    }

    $params += $file

    # code --help | code -
    & code $params
}

# Helpers
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

function Find-VSCommand( [string] $command )
{
    $file = Join-Path (Split-Path $Profile) "vscommands.txt"
    gc $file | where{ $_ -match $command }
}
