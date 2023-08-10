# Path setup
$addToPath =
    "$HOME/.cargo/bin",
    "$HOME/.git-fuzzy/bin",
    "$HOME/.local/bin"
$env:PATH += [io.path]::PathSeparator + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join [io.path]::PathSeparator)

# Common command names
function mkdir { New-Item -ItemType Directory @args }
function open { bash -c "doublecmd $pwd &>/dev/null & disown" }

# Use bat for man
$env:MANPAGER = "sh -c 'col -bx | batcat -l man -p'"


tm (Split-Path $PSCommandPath -Leaf)