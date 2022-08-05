# rgf

class FzfDefaultCmd {
	[string]$PrevEnv

	FzfDefaultCmd([string]$overrideVal) {
		$this.PrevEnv = $env:FZF_DEFAULT_COMMAND
		$env:FZF_DEFAULT_COMMAND = $overrideVal
	}

	[void]Restore() {
		$env:FZF_DEFAULT_COMMAND = $this.PrevEnv
	}
}
function rgf2() {
    # this function is adapted from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    param([Parameter(Mandatory)]$SearchString, [switch]$NoEditor)

    $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case "
    $INITIAL_QUERY = $SearchString

    $script:OverrideFzfDefaultCommand = [FzfDefaultCmd]::new('')
    try {
        $sleepCmd = ''
        $trueCmd = 'cd .'
        $env:FZF_DEFAULT_COMMAND = "$RG_PREFIX ""$INITIAL_QUERY"""

        & fzf --ansi `
            --color "hl:-1:underline,hl+:-1:underline:reverse" `
            --disabled --query "$INITIAL_QUERY" `
            --bind "change:reload: $RG_PREFIX {q} || cd ." `
            --bind "alt-f:unbind(change,alt-f)+change-prompt(2. fzf> )+enable-search+clear-query+rebind(alt-r)" `
            --bind "alt-r:unbind(alt-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || cd .)+rebind(change,alt-f)" `
            --prompt '1. Ripgrep> ' `
            --delimiter : `
            --header '╱ alt-r (Ripgrep mode) ╱ alt-f (fzf mode) ╱' `
            --preview 'bat --color=always {1} --highlight-line {2}' `
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' | `
            ForEach-Object { $results += $_ }

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
    }
    catch {
        Write-Error "Error occurred: $_"
    }
    finally {
        if ($script:OverrideFzfDefaultCommand) {
            $script:OverrideFzfDefaultCommand.Restore()
            $script:OverrideFzfDefaultCommand = $null
        }
    }
}