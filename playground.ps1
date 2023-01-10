# New: dust, btm, tldr, tokei, bandwhich
# Unix: exa, sd

function capp( $url, [switch] $Music )
{
    if( $music )
    {
        & "C:\Program Files\Google\Chrome\Application\chrome.exe" "--app=https://music.youtube.com"
    }
    else
    {
        & "C:\Program Files\Google\Chrome\Application\chrome.exe" "--app=$url"
    }
}

tm (Split-Path $PSCommandPath -Leaf)
