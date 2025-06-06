function capp( $url, [switch] $Music )
{
    $chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"

    if( (-not $url) -or $Music )
    {
        $url = "https://music.youtube.com"
    }

    & $chrome "--app=$url"
}

function dcm
{
    & "C:\tools\dcm\Dcm.Explorer.exe"
}

function ignore( $path )
{
    git update-index --assume-unchanged $path
}

tm (Split-Path $PSCommandPath -Leaf)
