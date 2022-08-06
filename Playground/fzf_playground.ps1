fzf --preview 'pwsh -NoProfile -Command "ls"' --preview-window "cycle"

# Toggle between folders and files
# - on files can preview
# - on folders can open in code
find * | fzf --prompt 'All> ' \
             --header 'alt-D: Directories / alt-F: Files' \
             --bind 'alt-d:change-prompt(Directories> )+reload(find * -type d)' \
             --bind 'alt-f:change-prompt(Files> )+reload(find * -type f)'

& "C:\Program Files\Git\usr\bin\find.exe" . -not -path */.git/*


# TODO: rgf uses dull colors now. used to work fine

function rgf2
{
    # this function is adapted from https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
    param([Parameter(Mandatory)]$SearchString, [switch]$NoEditor)
    $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case "
    $INITIAL_QUERY = $SearchString
    $script:OverrideFzfDefaultCommand = [FzfDefaultCmd]::new('')
    try {
        if ($script:IsWindows) {
            $sleepCmd = ''
            $trueCmd = 'cd .'
            $env:FZF_DEFAULT_COMMAND = "$RG_PREFIX ""$INITIAL_QUERY"""
        }
        else {
            $sleepCmd = 'sleep 0.1;'
            $trueCmd = 'true'
            $env:FZF_DEFAULT_COMMAND = '{0} $(printf %q "{1}")' -f $RG_PREFIX, $INITIAL_QUERY
        }
        & $script:FzfLocation --ansi
            --color "hl:-1:underline,hl+:-1:underline:reverse"
            --disabled --query "$INITIAL_QUERY"
            --bind "change:reload:$sleepCmd $RG_PREFIX {q} || $trueCmd"
            --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+clear-query+rebind(ctrl-r)"
            --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || $trueCmd)+rebind(change,ctrl-f)"
            --prompt '1. Ripgrep> '
            --delimiter :
            --header '╱ CTRL-R (Ripgrep mode) ╱ CTRL-F (fzf mode) ╱'
            --preview 'bat --color=always {1} --highlight-line {2}'
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' |
            ForEach-Object { $results += $_ }
        if (-not [string]::IsNullOrEmpty($results)) {
            $split = $results.Split(':')
            $fileList = $split[0]
            $lineNum = $split[1]
            if ($NoEditor) {
                Resolve-Path $fileList
            }
            else {
                $cmd = Get-EditorLaunch -FileList $fileList -LineNum $lineNum
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


function cdf2
{
    # TODO: add common folders here on switch

    <#
menu1=Documents
cmd1=cd %HOME%\Documents
menu2=Downloads
cmd2=cd %HOME%\Downloads
menu3=OneDrive
cmd3=cd %OneDriveConsumer%
menu4=OneDrive Microsoft
cmd4=cd %OneDriveCommercial%
menu5=-Code
menu6=NTP Managed
cmd6=cd %AzCompute%\src\Client\NTP\managed\
menu7=NTP Investigations
cmd7=cd %NTP%\investigations
menu8=NTPD Reference
cmd8=cd %NTP%\udel
menu9=Time Wiki
cmd9=cd %NTP%\TimeWiki
menu10=[Firmware]
cmd10=cd d:\src\golds\pf\data\Autopilot\NtpReferenceClock\Firmware
menu11=[Secrets]
cmd11=cd D:\src\golds\pf\AutopilotService\Global\VirtualEnvironments\Autopilot
menu12=--
menu13=Startup
cmd13=cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    #>

    param($Directory = $null)

    if ($null -eq $Directory) { $Directory = $PWD.ProviderPath }
    $result = $null
    try {
        if ([string]::IsNullOrWhiteSpace($env:FZF_DEFAULT_COMMAND)) {
            Get-ChildItem $Directory -Recurse -ErrorAction Ignore | Where-Object { $_.PSIsContainer } | Invoke-Fzf | ForEach-Object { $result = $_ }
        }
        else {
            Invoke-Fzf | ForEach-Object { $result = $_ }
        }
    }
    catch {

    }

    if ($null -ne $result) {
        Set-Location $result
    }
}
function GetProcessesList() {
    Get-Process | `
        Where-Object { ![string]::IsNullOrEmpty($_.ProcessName) } | `
        ForEach-Object {
        $pmSize = $_.PM / 1MB
        $cpu = $_.CPU
        # make sure we display a value so we can correctly parse selections:
        if ($null -eq $cpu) {
            $cpu = 0.0
        }
        "{0,-8:n2} {1,-8:n2} {2,-8} {3}" -f $pmSize, $cpu, $_.Id, $_.ProcessName }
}
function GetProcessSelection() {
    param(
        [scriptblock]
        $ResultAction
    )

    $previewScript = $(Join-Path $PsScriptRoot 'helpers/GetProcessesList.ps1')
    $cmd = $($script:PowershellCmd + " -NoProfile -NonInteractive -File \""$previewScript\""")

    $header = "`n" + `
        "`nCTRL+R-Reload`tCTRL+A-Select All`tCTRL+D-Deselect All`tCTRL+T-Toggle All`n`n" + `
    $("{0,-8} {1,-8} {2,-8} PROCESS NAME" -f "PM(M)", "CPU", "ID") + "`n" + `
        "{0,-8} {1,-8} {2,-8} {3,-12}" -f "-----", "---", "--", "------------"

    $result = GetProcessesList | `
        Invoke-Fzf -Multi -Header $header `
        -Bind """alt-r:reload($cmd),ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all""" `
        -Preview "echo {}" -PreviewWindow """down,3,wrap""" `
        -Layout reverse -Height 80%
    $result | ForEach-Object {
        &$ResultAction $_
    }
}

function killf2
{
    GetProcessSelection -ResultAction {
        param($result)
        $resultSplit = $result.split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        $processIdIdx = 2
        $id = $resultSplit[$processIdIdx]
        Stop-Process -Id $id -Verbose
    }
}