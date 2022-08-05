# rgf

function Get-EditorLaunch() {
    param($FileList, $LineNum = 0)
    # HACK to check to see if we're running under Visual Studio Code.
    # If so, reuse Visual Studio Code currently open windows:
    $editorOptions = ''
    if (-not [string]::IsNullOrEmpty($env:PSFZF_EDITOR_OPTIONS)) {
        $editorOptions += ' ' + $env:PSFZF_EDITOR_OPTIONS
    }
    if ($null -ne $env:VSCODE_PID) {
        $editor = 'code'
        $editorOptions += ' --reuse-window'
    }
    else {
        $editor = if ($ENV:VISUAL) { $ENV:VISUAL }elseif ($ENV:EDITOR) { $ENV:EDITOR }
        if ($null -eq $editor) {
            if (!$IsWindows) {
                $editor = 'vim'
            }
            else {
                $editor = 'code'
            }
        }
    }

    if ($editor -eq 'code') {
        if ($FileList -is [array] -and $FileList.length -gt 1) {
            for ($i = 0; $i -lt $FileList.Count; $i++) {
                $FileList[$i] = '"{0}"' -f $(Resolve-Path $FileList[$i].Trim('"'))
            }
            "$editor$editorOptions {0}" -f ($FileList -join ' ')
        }
        else {
            "$editor$editorOptions --goto ""{0}:{1}""" -f $(Resolve-Path $FileList.Trim('"')), $LineNum
        }
    }
    elseif ($editor -match '[gn]?vi[m]?') {
        if ($FileList -is [array] -and $FileList.length -gt 1) {
            for ($i = 0; $i -lt $FileList.Count; $i++) {
                $FileList[$i] = '"{0}"' -f $(Resolve-Path $FileList[$i].Trim('"'))
            }
            "$editor$editorOptions {0}" -f ($FileList -join ' ')
        }
        else {
            "$editor$editorOptions ""{0}"" +{1}" -f $(Resolve-Path $FileList.Trim('"')), $LineNum
        }
    }
    elseif ($editor -eq 'nano') {
        if ($FileList -is [array] -and $FileList.length -gt 1) {
            for ($i = 0; $i -lt $FileList.Count; $i++) {
                $FileList[$i] = '"{0}"' -f $(Resolve-Path $FileList[$i].Trim('"'))
            }
            "$editor$editorOptions {0}" -f ($FileList -join ' ')
        }
        else {
            "$editor$editorOptions  +{1} {0}" -f $(Resolve-Path $FileList.Trim('"')), $LineNum
        }
    }
}


function rgf2() {
    # this function is adapted from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    param([Parameter(Mandatory)]$Query, [switch]$NoEditor)

    $preservedFzfCommand = $env:FZF_DEFAULT_COMMAND
    $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case "

    try {
        $env:FZF_DEFAULT_COMMAND = "$RG_PREFIX ""$QUERY"""

        $result = & fzf --ansi `
            --color "hl:-1:bold,hl+:-1:bold:reverse" `
            --disabled --query "$QUERY" `
            --bind "change:reload: $RG_PREFIX {q} || cd ." `
            --bind "alt-f:unbind(change,alt-f)+change-prompt(fzf> )+enable-search+clear-query+rebind(alt-r)" `
            --bind "alt-r:unbind(alt-r)+change-prompt(rg> )+disable-search+reload($RG_PREFIX {q} || cd .)+rebind(change,alt-f)" `
            --prompt 'rg> ' `
            --delimiter : `
            --header '<ALT-R: rg> <ALT-F: fzf>' `
            --preview 'bat --plain --color=always {1} --highlight-line {2}' `
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'

        $result
<#
if (-not [string]::IsNullOrEmpty($results)) {
    $split = $results.Split(':')
    $fileList = $split[0]
    $lineNum = $split[1]
    if ($NoEditor) {
        Resolve-Path $fileList
    }
    else {
        $cmd = codef -FileList $fileList -LineNum $lineNum
        Write-Host "Executing '$cmd'..."
        Invoke-Expression -Command $cmd
    }
}
#>
    }
    finally {
        $env:FZF_DEFAULT_COMMAND = $preservedFzfCommand
    }
}

rgf2 alex