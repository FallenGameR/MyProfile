<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.
#>
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

Register-Shortcut "Alt+h" "hf" "History search"
Register-Shortcut "Alt+o" "startf" "Open file"
Register-Shortcut "Alt+r" "rgf" "Ripgrep search"
Register-Shortcut "Alt+k" "killf" "Kill process"
Register-Shortcut "Alt+f" "codef" "Code to open file"
Register-Shortcut "Alt+v" "codef -d" "Code to open directory"
Register-Shortcut "Alt+d" "cdf -q" "Change directory"

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
        $accumulator | bat -pl help --theme=
    }
}

function startf
{
    param
    (
        $Path
    )

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

function codef
{
    param
    (
        # Collection of file paths. Each one in the form:
        # 1) path
        # 2) path:line
        # 3) path:line:char
        #
        # If there are many paths their line and char info is removed (VS code can't open several files each in specific places)
        # If not specified fzf with preview is used
        $Paths,
        [switch] $Directory
    )

    # Select paths
    if( -not $paths )
    {
        if( $Directory )
        {
            function list
            {
                $pwd | gi
                Get-ChildItem -Directory -Recurse -ErrorAction Ignore
            }

            $paths =
                list |
                foreach fullname |
                fzf `
                    --margin "1%" `
                    --padding "1%" `
                    --border
        }
        else
        {
            $paths = fzf `
                --margin "1%" `
                --padding "1%" `
                --border `
                --preview "bat {} --color=always --plain" `
                --color "preview-bg:#222222" `
                --preview-window=55%
        }
    }

    if( -not $paths )
    {
        return
    }

    # Prepare code args
    $editor = 'code'
    $editorOptions = ''
    $paths = @($paths | foreach{'"{0}"' -f $psitem})
    if( $paths.Length -gt 1 )
    {
        $paths = $paths -replace ":\d+(:\d+)?\""$", '"'
    }

    # Invoke code
    $invoke = "$editor $editorOptions --goto {0}" -f ($paths -join " ")
    $invoke
    Invoke-Expression $invoke
}

function rgf
{
    # this function is adapted from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    param
    (
        [Parameter(Mandatory)] $Query
    )

    $preservedFzfCommand = $env:FZF_DEFAULT_COMMAND
    $rg = "rg --column --line-number --no-heading --color=always --smart-case "

    try
    {
        $env:FZF_DEFAULT_COMMAND = "$rg ""$Query"""

        $result = fzf `
            --ansi `
            --height "99%" `
            --color "hl:-1:bold,hl+:-1:bold:reverse" `
            --disabled --query "$Query" `
            --bind "change:reload: $rg {q} || cd ." `
            --bind "alt-f:unbind(change,alt-f)+change-prompt(fzf> )+enable-search+clear-query+rebind(alt-r)" `
            --bind "alt-r:unbind(alt-r)+change-prompt(rg> )+disable-search+reload($rg {q} || cd .)+rebind(change,alt-f)" `
            --prompt "rg> " `
            --delimiter ":" `
            "--info=default" `  # We want to see progress on large amounts of files
            --tiebreak "begin,length" `
            --header '<ALT-R: rg> <ALT-F: fzf>' `
            --preview 'bat --plain --color=always {1} --highlight-line {2}' `
            --preview-window 'up,72%,border-bottom,+{2}+3/3,~3'

        $paths = $result |
            foreach{ ($psitem -split ":" | select -f 3) -join ":" } |
            foreach{ $psitem -replace '\x1b\[[0-9;]*[a-z]' }

        if( $paths )
        {
            $paths
            codef $paths
        }
    }
    finally
    {
        $env:FZF_DEFAULT_COMMAND = $preservedFzfCommand
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

function cdf( $Path, [switch] $Quick )
{
    function quick
    {
        "$env:HOME\Documents"
        "$env:HOME\Downloads"
        "$env:OneDriveConsumer"
        "$env:OneDriveCommercial"
        $GLOBAL:PROFILE_FastPaths
    }

    function pipe
    {
        if( $Quick )
        {
            quick | where{ Test-Path $psitem -ea Ignore } | foreach{ [System.IO.Path]::GetFullPath($psitem) }
        }

        Get-ChildItem -Directory -Recurse -ErrorAction Ignore | % FullName
    }

    $fzfArgs = @()
    if( $path )
    {
        $fzfArgs += "-q"
        $fzfArgs += $path
    }

    $destination = pipe | fzf @fzfArgs
    $destination
    if( $destination )
    {
        cd $destination
    }
}

function killf( $name )
{
    $fzfArgs = @()
    $fzfArgs += "--header-lines=3"  # PS output table header
    $fzfArgs += "--ansi"            # Use coloring from PS output
    $fzfArgs += "--height"          # To see few lines of previous input in case we want to kill pwsh
    $fzfArgs += "90%"               #   and we dumped $pid to the console just before the killf

    if( $name )
    {
        $fzfArgs += "-q"
        $fzfArgs += $name
    }

    $lines = gps | fzf --ansi @fzfArgs
    if( -not $lines ) {return}

    $lines | foreach{
        $split = $psitem -split "\s+" | where{ $psitem }
        $id = $split[4]
        Stop-Process -Id $id -Verbose
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
