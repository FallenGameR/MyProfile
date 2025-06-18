# Common pwsh commands
function mkdir { New-Item -ItemType Directory @args }
function open { bash -c "doublecmd $pwd &>/dev/null & disown" } # switch to mc?

# Backward compatibility for PsToolset
Set-Alias sort Sort-Object

# Path setup
$addToPath =
    "$HOME/.git-fuzzy/bin", # Git fzf
    "$HOME/.cargo/bin",     # Rust
    "$HOME/.local/bin"      # Python
$env:PATH += [io.path]::PathSeparator + (($addToPath | where{ Test-Path $psitem -ea Ignore }) -join [io.path]::PathSeparator)

# Use bat for man
$env:MANPAGER = "sh -c 'col -bx | batcat -l man -p'"

tm (Split-Path $PSCommandPath -Leaf)