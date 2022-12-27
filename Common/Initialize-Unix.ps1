function bat
{
    batcat @args
}

function mkdir
{
    New-Item -ItemType Directory @args
}

tm (Split-Path $PSCommandPath -Leaf)