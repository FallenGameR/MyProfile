# Common command names
function bat { batcat @args }
function mkdir { New-Item -ItemType Directory @args }

# Default conhost console color setup
Complete-Once "Gnome terminal colors" {
    Push-Location "$PsScriptRoot/../Bin/ColorTool/"
    cat ./campbell.gnome_terminal | dconf load /org/gnome/terminal/
    Pop-Location
}

tm (Split-Path $PSCommandPath -Leaf)