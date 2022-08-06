fzf --preview 'pwsh -NoProfile -Command "ls"' --preview-window "cycle"

# Toggle between folders and files
# - on files can preview
# - on folders can open in code
find * | fzf --prompt 'All> ' \
             --header 'alt-D: Directories / alt-F: Files' \
             --bind 'alt-d:change-prompt(Directories> )+reload(find * -type d)' \
             --bind 'alt-f:change-prompt(Files> )+reload(find * -type f)'

& "C:\Program Files\Git\usr\bin\find.exe" . -not -path */.git/*




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

    $"$env:ript:Powershell"$env:NoProfile -NonInteractive -File \""$previewScript\""")"

    $header = "`n" + `
        "`nCTRL+R-Reload`tCTRL+A-Select All`tCTRL+D-Deselect All`tCTRL+T-Toggle All`n`n" + `
    $("{0,-8} {1,-8} {2,-8} PROCESS NAME" -f "PM(M)", "CPU", "ID") + "`n" + `
        "{0,-8} {1,-8} {2,-8} {3,-12}" -f "-----", "---", "--", "------------"

    $result = GetProcessesList | `
        -Bind """alt-r:reload($"$env:elect-all,ctrl-d:deselect-all,ctrl-t:toggle-all""" `"
        -Preview "echo {}" -PreviewWindow """down,3,wrap""" `
        -Layout reverse -Height 80
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