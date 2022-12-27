# Common command names
function bat { batcat @args }
function mkdir { New-Item -ItemType Directory @args }

# Use bat for man
$env:MANPAGER = "sh -c 'col -bx | batcat -l man -p'"

# Default conhost console color setup
Complete-Once "Gnome terminal colors" {
    Push-Location "$PsScriptRoot/../Bin/ColorTool/"
    cat ./campbell.gnome_terminal | dconf load /org/gnome/terminal/
    Pop-Location
}

tm (Split-Path $PSCommandPath -Leaf)