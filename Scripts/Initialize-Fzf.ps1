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


<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.

.NOTES
    fzf issues:
    - bug in cyrillic typing https://github.com/junegunn/fzf/issues/2921
    - bug in cyrillic output https://github.com/junegunn/fzf/issues/2922
    - bug in cyrillic FZF_DEFAULT_COMMAND https://github.com/junegunn/fzf/issues/2923
    - bug in passing escaped query to rg https://github.com/junegunn/fzf/issues/2947
    - fzf can't exit until piped input will be handled (by design)

    fzf unused features:
    - it can use SHELL env variable to call different commands using -command switch for pwsh

    find "C:\Program Files\Git\usr\bin\find.exe" issues:
    - downloads all that it finds in OneDrive

    ANSI Escape sequences - https://duffney.io/usingansiescapesequencespowershell/
    -"`e[2A" + "test" # mouse move
    -"`e[2S" + "test" # viewport move
#>
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

Register-Shortcut "Alt+h" "hf" "History search"
Register-Shortcut "Alt+o" "startf" "Open file"
Register-Shortcut "Alt+r" "rgf" "Ripgrep search"
Register-Shortcut "Alt+k" "killf" "Kill process"
Register-Shortcut "Alt+f" "codef" "Code to open file or directory"
Register-Shortcut "Alt+v" "codef" "Code to open file or directory"
Register-Shortcut "Alt+d" "cdf" "Change directory"
Register-Shortcut "Alt+u" "pushf" "Go up fuzzy"


# fzf by default can work with cyrillic files - so we want to preserve that until fixed
# but we want custom behaviour on codef/cdf commands
# and we want to be able to exit fzf fast before it finish reading input on large folders
# so we need fzf to call a command to get input, not pipe it in (although that would be more convinient)
function Invoke-ScriptedFzf( $newCommand, $invokeFzf )
{
    $oldCommand = $env:FZF_DEFAULT_COMMAND
    $env:FZF_DEFAULT_COMMAND = $newCommand
    try
    {
        $invokeFzf.Invoke()
    }
    finally
    {
        $env:FZF_DEFAULT_COMMAND = $oldCommand
    }
}

function hlp($exe)
{
    begin
    {
        if( $exe )
        {
            & $exe --help | hlp
            return
        }
        $accumulator = @()
    }
    process { $accumulator += $psitem }
    end
    {
        $accumulator | bat -pl help
    }
}

function startf($path)
{
    $fzfArgs = @()
    if( $path )
    {
        $fzfArgs += "-q"
        $fzfArgs += $path
    }

    $destination = fzf @fzfArgs

    $destination
    if( $destination )
    {
        start $destination
    }
}

function cdf( $Path )
{
    $fzfArgs = Get-PreviewFzfArgs $path
    $cdf = "$PSScriptRoot\..\FZF\Invoke-Cdf.ps1"
    $destination = @(& $cdf | fzf @fzfArgs)

    $destination

    if( $destination.Length -eq 1 )
    {
        cd $destination[0]
    }
}

function killf( $name )
{
    $fzfArgs = @()
    $fzfArgs += "--header-lines=3"  # PS output table header
    $fzfArgs += "--height"          # To see few lines of previous input in case we want to kill pwsh
    $fzfArgs += "90%"               #   and we dumped $pid to the console just before the killf

    if( $name )
    {
        $fzfArgs += "-q"
        $fzfArgs += $name
    }

    $lines = gps | fzf @fzfArgs
    if( -not $lines ) {return}

    $lines | foreach{
        $split = $psitem -split "\s+" | where{ $psitem }
        $id = $split[4]
        Stop-Process -Id $id -Verbose -ea Ignore
    }
}

function Get-DirectoryStack
{
    $parts = $pwd -split "\\"
    $path = $parts | select -f 1
    $paths = @()
    foreach( $part in $parts[1..($parts.Length-2)] )
    {
        $path += "\" + $part
        $path
    }
}

function pushf
{
    $path = Get-DirectoryStack | sort -desc | pf
    if( $path )
    {
        pushd $path
    }
}

function Get-PreviewFzfArgs( $path )
{
    $fzfArgs =
        "--margin", "1%",
        "--padding", "1%",
        "--border",
        "--keep-right",
        "--preview", "pwsh.exe -nop -f $PSScriptRoot\..\FZF\Preview-CodeF.ps1 {}",
        "--preview-window=55%"

    $executedFromCode = (gps -id $pid | % parent | % name) -eq "Code"
    if( -not $executedFromCode )
    {
        # For some reason in VS code terminal background color remains
        $fzfArgs += "--color", "preview-bg:#222222"
    }

    if( $path )
    {
        $fzfArgs += "-q"
        $fzfArgs += $path
    }

    $fzfArgs
}

# Preview with fzf
# Note that it will not pipe in input to fzf until all the input will be collected
# If you want to call fzf immediately call it directly
function pf
{
    $fzfArgs = Get-PreviewFzfArgs
    $input | fzf @fzfArgs
}

function codef
{
    param
    (
        # Collection of file paths. Each one in the form:
        # 1) path
        # 2) path:line
        # 3) path:line:char
        #
        # If not specified fzf with preview is used
        $Paths
    )

    # Select paths
    if( -not $paths )
    {
        $fzfArgs = Get-PreviewFzfArgs
        $paths = Invoke-ScriptedFzf "pwsh.exe -nop -f $PSScriptRoot\..\FZF\Invoke-Codef.ps1" { fzf @fzfArgs }
    }

    if( -not $paths )
    {
        return
    }

    # Invoke code
    foreach( $path in $paths )
    {
        $invoke = "code --goto ""{0}""" -f $path
        $invoke
        Invoke-Expression $invoke
    }
}

function rgf
{
    # original: https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    # example: rgf regex -tps
    param
    (
        [Parameter(Mandatory)] $Query,
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)] $Options,
        [switch] $NoEditor
    )

    $rgArgs =
        "rg",
        "--column",
        "--line-number",
        "--no-heading",
        "--color=always",
        "--colors ""path:fg:0x3A,0x96,0xDD""",      # cyan
        "--colors ""line:fg:0x13,0xA1,0x0E""",      # green
        "--colors ""column:fg:0xF9,0xF1,0xA5""",    # bright yellow
        "--colors ""match:fg:0xE7,0x48,0x56""",     # bright red
        "--colors ""match:style:underline""",
        "--smart-case"

    $rg = ($rgArgs -join " ") + " "

    if( $options )
    {
        $rg += ($options -join " ") + " "
    }

    $oldFzfCommand = $env:FZF_DEFAULT_COMMAND
    $env:FZF_DEFAULT_COMMAND = "$rg ""$Query"""

    $result = try
    {
        # 'command || cd .' is used as analog of 'command || true' in linux samples
        # it makes sure that on rg find failure the command  would still return non error exit code
        # and thus would not terminate fzf
        #--height "99%" `
        fzf `
            --ansi `
            --color "hl:-1:bold,hl+:-1:bold:reverse" `
            --disabled `
            --query $Query `
            --bind "change:reload: $rg ""{q}"" || cd ." `
            --bind "alt-f:unbind(change,alt-f)+change-prompt(fzf> )+enable-search+clear-query+rebind(alt-r)" `
            --bind "alt-r:unbind(alt-r)+change-prompt(rg> )+disable-search+reload($rg ""{q}"" || cd .)+rebind(change,alt-f)" `
            --prompt "rg> " `
            --delimiter ":" `
            --tiebreak "begin,length" `
            --header '<ALT-R: rg> <ALT-F: fzf>' `
            --preview 'bat --color=always {1} --highlight-line {2}' `
            --preview-window 'up,72%,border-bottom,+{2}/3,~3'
            # +{2} - place in bat output, base offset to use for scrolling bat output to the highlighted line, from {2} token
            # /3   - place in viewport to place the highlighted line, in fraction of the preview window height - near the middle of the screen but a bit higher
            # ,~3  - pin top 3 lines from the bat output as the header, it would show the name of the file
    }
    finally
    {
        $env:FZF_DEFAULT_COMMAND = $oldFzfCommand
    }

    $paths = $result |
        foreach{ ($psitem -split ":" | select -f 3) -join ":" } |
        foreach{ $psitem -replace '\x1b\[[0-9;]*[a-z]' }

    if( -not $paths ) { return }
    $paths

    if( -not $NoEditor )
    {
        codef $paths
    }
}

function hf
{
    $result = Get-History | foreach CommandLine | fzf

    if( $result )
    {
        $command = $result -join ";"
        $command
        Invoke-Expression $command
    }
}

function capp( $url, [switch] $Music )
{
    if( $music )
    {
        & "C:\Program Files\Google\Chrome\Application\chrome.exe" "--app=https://music.youtube.com"
    }
    else
    {
        & "C:\Program Files\Google\Chrome\Application\chrome.exe" "--app=$url"
    }
}

tm (Split-Path $PSCommandPath -Leaf)
