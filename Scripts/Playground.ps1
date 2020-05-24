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


# Invocations
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

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
        (Get-Item $file).FullName
    }
}
