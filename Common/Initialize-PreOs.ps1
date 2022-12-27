# Modules in profile subfolder
$modules = Join-Path (Split-Path $profile) Modules
if( -not $env:PSModulePath.Contains($modules) )
{
    $env:PSModulePath += [io.path]::PathSeparator + $modules
}

# PSToolset module
Complete-Once PSToolset {
    pushd $PsScriptRoot/../Modules
    git clone https://github.com/microsoft/PSToolset.git
    popd
}

# Default command arguments
$PSDefaultParameterValues["Get-Command:All"] = $true

# Aliases
Set-Alias m Measure-Object
Set-Alias ls Get-ChildItem

# Common tools setup
$env:LESS = "-IeFRX"
$env:RIPGREP_CONFIG_PATH = "$PSScriptRoot\..\rg.config"
$env:BAT_CONFIG_PATH = "$PSScriptRoot\..\bat.config"
$fzfOptions = @(
    "--layout=reverse",             # Grow list down, not upwards
    "--tabstop=4",                  # Standard tab size
    "--multi",                      # Multi select possible
    "--bind",                       # Shortcuts:
    "alt-t:toggle-all",             # Alt+t toggles selection
    "--cycle",                      # Cycle the list
    "--ansi",                       # Use Powershell colors
    "--no-mouse",                   # We need terminal mouse behavior, not custom one
    "--tiebreak='length,index'",    # Priorities to resolve ties (index comes last always)
    "--color=bg:#0C0C0C",           # Background (current line) = Black
    "--color=bg+:#0C0C0C",          # Background (current line) = Black
    "--color=fg+:#F2F2F2",          # Text (current line) = White
    "--color=hl+:#13A10E",          # Highlighted substrings (current line) = DarkGreen
    "--color=pointer:#3A96DD",      # Pointer to the current line = DarkCyan
    "--color=preview-bg:#0C0C0C",   # Preview window background = Black
    "--color=prompt:#CCCCCC"        # Prompt = Gray

    #"--height 60%"                 # Leave some space intact - breaks cyrillic typing, bug created
    #"--color=bg:#RRGGBB",          # Background
    #"--color=bg+:#RRGGBB",         # Background (current line)
    #"--color=border:#RRGGBB",      # Border of the preview window and horizontal separators (--border)
    #"--color=fg:#RRGGBB",          # Text
    #"--color=fg+:#RRGGBB",         # Text (current line)
    #"--color=gutter:#RRGGBB",      # Gutter on the left (defaults to bg+)
    #"--color=header:#RRGGBB",      # Header
    #"--color=hl:#RRGGBB",          # Highlighted substrings
    #"--color=hl+:#RRGGBB",         # Highlighted substrings (current line)
    #"--color=info:#RRGGBB",        # Info
    #"--color=marker:#RRGGBB",      # Multi-select marker
    #"--color=pointer:#RRGGBB",     # Pointer to the current line
    #"--color=preview-bg:#RRGGBB",  # Preview window background
    #"--color=preview-fg:#RRGGBB",  # Preview window text
    #"--color=prompt:#RRGGBB",      # Prompt
    #"--color=spinner:#RRGGBB",     # Streaming input indicator
)
$env:FZF_DEFAULT_OPTS = $fzfOptions -join " "

tm (Split-Path $PSCommandPath -Leaf)