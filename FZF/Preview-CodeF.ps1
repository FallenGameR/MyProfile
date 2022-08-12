param
(
    $Path
)

$resolved = Get-Item $path -Force -ea Ignore

if( -not $resolved )
{
    "Don't know how to render $path"
    return
}

if( $resolved -is [System.IO.DirectoryInfo] )
{
    ls $path | ft -auto
}
else
{
    bat $path --color=always --plain
}
