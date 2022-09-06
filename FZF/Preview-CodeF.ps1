param
(
    $Path
)

$resolved = Get-Item $path -Force -ea Ignore
$pictures = ".jpg", ".jpeg", ".bmp", ".gif", ".png", ".webp"
$markdown = ".md"

if( -not $resolved )
{
    "Don't know how to render $path"
    return
}

if( $resolved -is [System.IO.DirectoryInfo] )
{
    ls -LiteralPath $path | ft -auto
    return
}

if( $resolved.Extension -in $pictures )
{
    chafa $path
    return
}

if( $resolved.Extension -in $markdown )
{
    glow -s dark $path
    return
}

bat $path --color=always --plain
