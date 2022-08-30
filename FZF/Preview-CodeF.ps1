param
(
    $Path
)

$resolved = Get-Item $path -Force -ea Ignore
$pictures = ".jpg", ".jpeg", ".bmp", ".gif", ".png", ".webp"

if( -not $resolved )
{
    "Don't know how to render $path"
    return
}

if( $resolved -is [System.IO.DirectoryInfo] )
{
    ls -LiteralPath $path | ft -auto
}
else
{
    if( $resolved.Extension -in $pictures )
    {
        chafa $path
    }
    else
    {
        bat $path --color=always --plain
    }
}
