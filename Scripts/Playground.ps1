<#
.SYNOPSIS
    Experimental playground with unstable or hardcoded stuff.
#>
function open { & "c:\tools\totalcmd\TOTALCMD64.EXE" ($pwd) }

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
            $paths = & "C:\Program Files\Git\usr\bin\find.exe" * -type d | fzf `
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
            --tiebreak "begin,length" `
            --header '<ALT-R: rg> <ALT-F: fzf>' `
            --preview 'bat --plain --color=always {1} --highlight-line {2}' `
            --preview-window 'up,72%,border-bottom,+{2}+3/3,~3'

        $paths = $result |
            foreach{ ($psitem -split ":" | select -f 3) -join ":" } |
            foreach{ $psitem -replace '\x1b\[[0-9;]*[a-z]' }

        if( $paths )
        {
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
        Invoke-Expression $command
    }
}

function edit( [string] $File, [switch] $SameEditor )
{
    $params = @()

    if( $SameEditor )
    {
        $params += "--reuse-window"
    }

    if( $File -match ":" )
    {
        $params += "--goto"
    }

    $params += $file

    # code --help | code -
    & code $params
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
