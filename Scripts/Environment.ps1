$addToPath =
    "C:\Program Files\Beyond Compare 4\",
    "C:\Program Files (x86)\WinDirStat\",
    "C:\Program Files (x86)\LINQPad5\"
$env:Path += ";" + ($addToPath -join ";")

$env:LESS = "-IeFRX"
$env:RIPGREP_CONFIG_PATH = "$PSScriptRoot\..\rg.config"
$env:BAT_CONFIG_PATH = "$PSScriptRoot\..\bat.config"
#$env:DELTA_PAGER = "0" # By default it uses less with -R incompatible switch set - but this breaks git

# FZF
$options = @(
    "--layout=reverse",
    "--height 60%",
    "--tabstop=4",
    "--multi",
    "--cycle",
    "--tiebreak='length,index'",
    "--color=bg:#0C0C0C",             # Background (current line) = Black
    "--color=bg+:#0C0C0C",            # Background (current line) = Black
    "--color=fg+:#F2F2F2",            # Text (current line) = White
    "--color=hl+:#13A10E",            # Highlighted substrings (current line) = DarkGreen
    "--color=pointer:#3A96DD",        # Pointer to the current line = DarkCyan
    "--color=preview-bg:#0C0C0C",     # Preview window background = Black
    "--color=prompt:#CCCCCC",         # Prompt = Gray
    "--info=hidden"
)

<#
"--color=bg:#RRGGBB",             # Background
"--color=bg+:#RRGGBB",            # Background (current line)
"--color=border:#RRGGBB",         # Border of the preview window and horizontal separators (--border)
"--color=fg:#RRGGBB",             # Text
"--color=fg+:#RRGGBB",            # Text (current line)
"--color=gutter:#RRGGBB",         # Gutter on the left (defaults to bg+)
"--color=header:#RRGGBB",         # Header
"--color=hl:#RRGGBB",             # Highlighted substrings
"--color=hl+:#RRGGBB",            # Highlighted substrings (current line)
"--color=info:#RRGGBB",           # Info
"--color=marker:#RRGGBB",         # Multi-select marker
"--color=pointer:#RRGGBB",        # Pointer to the current line
"--color=preview-bg:#RRGGBB",     # Preview window background
"--color=preview-fg:#RRGGBB",     # Preview window text
"--color=prompt:#RRGGBB",         # Prompt
"--color=spinner:#RRGGBB",        # Streaming input indicator
#>

$env:FZF_DEFAULT_OPTS = $options -join " "