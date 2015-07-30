<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.
#>

function Set-WindowStyle
{
    # NOTE: https://gist.github.com/jakeballard/11240204
    param
    (
        [ValidateSet(
            'FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
            'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
            'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
        $Style = 'SHOW',
        $MainWindowHandle
    )

    if( -not $MainWindowHandle )
    {
        $MainWindowHandle = Get-Process -id $pid | % MainWindowHandle
    }

    $WindowStates = @{
        'FORCEMINIMIZE'   = 11
        'HIDE'            = 0
        'MAXIMIZE'        = 3
        'MINIMIZE'        = 6
        'RESTORE'         = 9
        'SHOW'            = 5
        'SHOWDEFAULT'     = 10
        'SHOWMAXIMIZED'   = 3
        'SHOWMINIMIZED'   = 2
        'SHOWMINNOACTIVE' = 7
        'SHOWNA'          = 8
        'SHOWNOACTIVATE'  = 4
        'SHOWNORMAL'      = 1
    }

    $definition =
@"
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@

    $Win32ShowWindowAsync = Add-Type `
        -memberDefinition $definition `
        -name "Win32ShowWindowAsync" `
        -namespace "Win32Functions" `
        -passThru
    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
    Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $Style)
}

function Disable-Oacr
{
    $env:USE_OACR = 0
    oacr stop
    oacr clean
    oacr set off
}

function Send-Tool( $session, $tool )
{
    $toolPaths = @(ls c:\tools | where name -match $tool | % fullname)
    if( -not $toolPaths )
    {
        Write-Warning "Can't find tool $tool in c:\tools"
    }
    if( $toolPaths.Count -gt 1 )
    {
        Write-Warning "Note that mutiple tools were matched: $($toolPaths.BaseName -join ", ")"
    }

    Send-File $session $toolPaths "~\..\Desktop" -Compress
}

function Get-Song( $artist, $song )
{
    $music = "$oneDrive\music"
    $artists = ls $music -Directory | where BaseName -match $artist
    $artists | foreach{ ls $psitem.FullName -rec -file -force | where BaseName -match $song }
}

function Receive-FromBuildDrop( $phxShare, $path, $session = $(s (rnd) -cred) )
{
    icm $session {cd ~}
    icm $session {ls | del}
    icm $session {copy $USING:phxShare\retail\amd64\$path\* .}
    receive-file $session C:\Users\alexko\Documents c:\Users\alexko\Downloads\builddrop
}

function devenv
{
    if( $args )
    {
        & "c:\programs\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe" $args
    }
    else
    {
        $file = @(ls | where Name -match "\.(sln|csproj)")
        if( $file.Count -eq 1 )
        {
            & "c:\programs\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe" $file[0]
        }
        else
        {
            throw "Can't auto resolve solution or project to open, pass file to open in arguments"
        }
    }
}

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
        $override = ls | where name -match Replacement | sort LastWriteTime -Descending | select -f 1
        APConfigTool Diff -f $override.FullName
    }

    if( $command -eq "Submit" )
    {
        $override = ls | sort LastWriteTime -Descending | select -f 1
        sd add $override.FullName
        sd submit
    }
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

function Invoke-CheckCluster( [string] $name )
{
    if( -not $name )
    {
        $name = $pwd | parse "autopilotService\\([^\\]+)"
    }

    Write-Host "Checking cluster: $name" -fore DarkGreen

    $searchGold = (Get-Enlistment data).Root
    Push-Location "$searchGold\AutopilotService"
    & "$searchGold\tools\vlad\CheckCluster2\CheckCluster.exe" -c $name | ConvertFrom-ApLogs
    Pop-Location
}

function Invoke-ClusterTool
{
    $searchGold = (Get-Enlistment data).Root
    $path = "$searchGold\data\Ironman\InternalTools\ClusterTool.exe"
    #$path = "c:\Users\alexko\Downloads\ClusterTool.exe"
    & $path $args | ConvertFrom-ApLogs
}

function Invoke-ClusterPreattyPrint( [string] $name )
{
    if( -not $name )
    {
        $name = $pwd | parse "autopilotService\\([^\\]+)"
    }

    Write-Host "Preatty print for cluster: $name" -fore DarkGreen

    $searchGold = (Get-Enlistment data).Root
    $path = "$searchGold\autopilotService\$name"
    Invoke-ClusterTool PrettyPrint $path
}

function change( $from, $to, $encoding = "ascii" )
{
    $files = git grep -iFl "$from"
    $files | foreach{ (type $psitem) -replace [regex]::Escape($from), $to | Set-Content $psitem -Encoding $encoding }
}

function srch( $text ) {git grep -iF $text}

# Invocations
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
