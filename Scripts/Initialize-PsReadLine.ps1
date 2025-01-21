# Make sure to call only for interactive Powershell sessions.
# Build scripts may open bunch of powershell short lived processes
# that import profile and Set-PSReadlineKeyHandler can randomly fail
# https://github.com/lzybkr/PSReadLine/issues/182

# If there is no PsReadLine module there is nothing to setup here
if( -not (Get-Module PsReadLine) )
{
    Import-Module PsReadLine

    # PsReadline is updated outside of windows
    if( (Get-Module psreadline | % version) -lt [version]::Parse("2.2.6") )
    {
        Install-Module -Name PSReadLine -Force
    }
}

# Useful default things, turns out this is a Unix default, need to get them on Windows =)
#
# Unix-only:
# - Alt+a - highlight arguments, SelectCommandArgument
# - F2 - prediction view, SwitchPredictionView

Set-PSReadlineKeyHandler -Chord "Ctrl+d" -Function CaptureScreen # Windows

<#

ListView
https://github.com/PowerShell/PSReadLine/pull/1909
set-PSReadLineOption -PredictionViewStyle ListView
set-PSReadLineOption -PredictionSource HistoryAndPlugin

Also it implements dynamic help for parameters by showing it below the current command line like MenuComplete.
https://github.com/PowerShell/PSReadLine/pull/1777


# Trying out if this will work
Set-PSReadlineKeyHandler `
-Key "Enter" `
-BriefDescription "Accept line custom" `
-LongDescription "Mitigation for not line-feeding default AcceptLine" `
-ScriptBlock `
{
    [Microsoft.Powershell.PSConsoleReadLine]::SetCursorPosition(0)
    [Microsoft.Powershell.PSConsoleReadLine]::AcceptLine()
}
#>

# Code editors
Register-Shortcut "Alt+g" "code" "Code open"

switch( Get-Platform )
{
    "Win32NT"
    {
        Register-Shortcut "Alt+c" "gite commit" "Git commit dialog"
        Register-Shortcut "Alt+b" "gite" "Git commit browser"
        Register-Shortcut "Alt+i" "Start-AiShell" "Open AI Shell"
        Register-Shortcut "Alt+a" "Start-AiShell" "Open AI Shell"
    }
    "Unix"
    {
        Register-Shortcut "Alt+c" "git commit -a" "Git commit dialog"
        Register-Shortcut "Alt+b" "git lg" "Git commit browser"
    }
}

# Fancy formatting was added only in 7.2
if( ($PSVersionTable.PSVersion -ge 7.2) -and (-not (Test-Constrained)) )
{
    # https://devblogs.microsoft.com/powershell/general-availability-of-powershell-7-2/
    $PSStyle.Formatting.TableHeader = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Cyan
    $PSStyle.FileInfo.Directory = $PSStyle.Bold + $PSStyle.Foreground.Blue
}

# History command prediction was added in 2.1.0 and this feature
# should have been included by default in PS 7.2 but there
# could be some weird combinations
if( (Get-Module psreadline).Version -ge 2.1 )
{
    # https://devblogs.microsoft.com/powershell/general-availability-of-powershell-7-2/
    # Errors are ignored since in polyglot notebooks the output is redirected and this command fails
    try { Set-PSReadLineOption -PredictionSource History }
    catch { }
}

# Since PS 5.1 console beeps on backspace while on empty prompt
# https://superuser.com/questions/1113429/disable-powershell-beep-on-backspace
Set-PSReadlineOption -BellStyle None

# RS5 and after use this API
$colors = @{}
$colors["Command"] = [ConsoleColor]::DarkCyan
$colors["Comment"] = [ConsoleColor]::DarkGreen
$colors["Keyword"] = [ConsoleColor]::Gray
$colors["Number"] = [ConsoleColor]::DarkGray
$colors["Member"] = [ConsoleColor]::DarkCyan
$colors["Operator"] = [ConsoleColor]::DarkRed
$colors["Parameter"] = [ConsoleColor]::DarkMagenta
$colors["String"] = [ConsoleColor]::DarkYellow
$colors["Type"] = [ConsoleColor]::DarkCyan
$colors["Variable"] = [ConsoleColor]::DarkGray
Set-PSReadlineOption -Colors $colors

# Console behavior
Set-PSReadlineOption -HistorySaveStyle SaveAtExit # SaveNothing if it is buggy
Set-PSReadlineOption -ContinuationPrompt ([char] 187 + " ")

# Command edits
Set-PSReadlineKeyHandler -Chord "Ctrl+LeftArrow" -Function BackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadlineKeyHandler -Chord "Shift+UpArrow" -Function SelectBackwardsLine
Set-PSReadlineKeyHandler -Chord "Shift+DownArrow" -Function SelectLine

# Doesn't work on Linux
#Set-PSReadlineKeyHandler -Chord "Shift+Home" -Function SelectBackwardsLine
#Set-PSReadlineKeyHandler -Chord "Shift+End" -Function SelectLine

# shell word is defined by tokens
Set-PSReadlineKeyHandler -Chord "Alt+Delete" -Function ShellKillWord
Set-PSReadlineKeyHandler -Chord "Alt+Backspace" -Function ShellBackwardKillWord

Set-PSReadlineKeyHandler -Chord "Alt+q" -Function ShellBackwardKillWord
Set-PSReadlineKeyHandler -Chord "Alt+e" -Function ShellKillWord
Set-PSReadlineKeyHandler -Chord "Alt+a" -Function ShellBackwardWord
Set-PSReadlineKeyHandler -Chord "Alt+d" -Function ShellForwardWord

# These don't work in VS code integrated terminal on Unix though
# Something intercepts these chords and PSReadLine doesn't get to process them
# https://stackoverflow.com/questions/59074722/how-to-ctrlshift%E2%86%90-%E2%86%92-to-select-previous-or-next-word-at-the-vscode-integrated-t
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+LeftArrow" -Function SelectBackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+RightArrow" -Function SelectForwardWord

if( Test-Windows )
{
    # Doesn't work in unix terminals
    Set-PSReadlineKeyHandler -Chord "Ctrl+UpArrow" -Function ScrollDisplayUpLine
    Set-PSReadlineKeyHandler -Chord "Ctrl+DownArrow" -Function ScrollDisplayDownLine
}

Set-PSReadlineKeyHandler -Chord "Ctrl+a" -Function SelectAll

Set-PSReadlineKeyHandler `
    -Key "Ctrl+UpArrow" `
    -BriefDescription GoToBegin `
    -LongDescription "Set cursor to the start of the line" `
    -ScriptBlock `
{
    [Microsoft.Powershell.PSConsoleReadLine]::SetCursorPosition(0)
}

Set-PSReadlineKeyHandler `
    -Key "Ctrl+DownArrow" `
    -BriefDescription GoToEnd `
    -LongDescription "Set cursor to the end of the line" `
    -ScriptBlock `
{
    $string = $null
    $cursor = $null
    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref] $string, [ref] $cursor)
    [Microsoft.Powershell.PSConsoleReadLine]::SetCursorPosition($string.Length)
}

Set-PSReadlineKeyHandler `
    -Key "Ctrl+z" `
    -BriefDescription Abort `
    -LongDescription "Abort current operation" `
    -ScriptBlock `
{
    [Microsoft.Powershell.PSConsoleReadLine]::CancelLine()
}

#
# Ctrl+X that either:
# - cuts selected text
# - cuts whole unselected line
# - exits console
#
Set-PSReadlineKeyHandler `
    -Key Ctrl+x `
    -BriefDescription CutOrExit `
    -LongDescription "Cuts selection, whole input or exits console" `
    -ScriptBlock `
{
    $start = $null
    $length = $null
    $string = $null
    $cursor = $null

    # Work as cut if text is selected
    [Microsoft.Powershell.PSConsoleReadLine]::GetSelectionState([ref] $start, [ref] $length)
    if( $length -gt 0 )
    {
        switch( $PSVersionTable.Platform )
        {
            ""        { [Microsoft.Powershell.PSConsoleReadLine]::Cut() }
            "Win32NT" { [Microsoft.Powershell.PSConsoleReadLine]::Cut() }
            "Unix"
            {
                [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref] $string, [ref] $cursor)
                [Microsoft.Powershell.PSConsoleReadLine]::RevertLine()
                $string.Substring($start, $length) | xsel --input -b
                [Microsoft.Powershell.PSConsoleReadLine]::Insert($string.Remove($start, $length))
            }
        }
        return
    }

    # Work as line cut if no text is selected, but there is input
    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref] $string, [ref] $cursor)
    if( $string )
    {
        switch( $PSVersionTable.Platform )
        {
            ""          { $string | clip }
            "Win32NT"   { $string | clip }
            "Unix"      { $string | xsel --input -b }
            default     { return }
        }
        [Microsoft.Powershell.PSConsoleReadLine]::RevertLine()
        return
    }

    # Otherwise just close the terminal
    [Microsoft.Powershell.PSConsoleReadLine]::RevertLine()
    [Microsoft.Powershell.PSConsoleReadLine]::Insert("exit")
    [Microsoft.Powershell.PSConsoleReadLine]::AcceptLine()
}

if( Test-Unix )
{
    # Ctrl+c is buggy in linux, it hangs the current console and only another
    # console with the same Ctrl+c can mke the first one unstuck. Plus if we
    # select another line with a mouse then selection state returns -1 -1
    Set-PSReadlineKeyHandler `
        -Key Ctrl+c `
        -BriefDescription CopyOrCancel `
        -LongDescription "Copies selected text or does cancellation" `
        -ScriptBlock `
    {
        $start = $null
        $length = $null
        $string = $null
        $cursor = $null

        [Microsoft.Powershell.PSConsoleReadLine]::GetSelectionState([ref] $start, [ref] $length)

        # Cancel if there is no selection
        if( $length -le 0 )
        {
            [Microsoft.Powershell.PSConsoleReadLine]::CancelLine()
            return
        }

        # Copy selection (from the current line only)
        [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref] $string, [ref] $cursor)
        $string.Substring($start, $length) | xsel --input -b
    }

    # While we are at it, let's by default use clipboard on unix as well on ctrl+v
    Set-PSReadlineKeyHandler `
        -Key Ctrl+v `
        -BriefDescription PasteFromClipboard `
        -LongDescription "Paste test from clipboard" `
        -ScriptBlock `
    {
        $clipboard = xsel --output -b
        $clipboard = $clipboard -join [environment]::NewLine
        [Microsoft.Powershell.PSConsoleReadLine]::Insert($clipboard)
    }
}

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadlineKeyHandler `
    -Key Alt+w `
    -BriefDescription SaveInHistory `
    -LongDescription "Save current line in history but do not execute" `
    -ScriptBlock `
{
    param($key, $arg)

    $line = $null
    $cursor = $null

    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.Powershell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.Powershell.PSConsoleReadLine]::RevertLine()
}

# Will normalize command with the resolved commands.
Set-PSReadlineKeyHandler `
    -Key "Alt+n" `
    -BriefDescription ExpandAliases `
    -LongDescription "Replace aliases with the full command" `
    -ScriptBlock `
{
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null

    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $startAdjustment = 0
    foreach ($token in $tokens)
    {
        if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'All')

            $resolvedCommand = if ($command -is [System.Management.Automation.AliasInfo])
            {
                $command.ResolvedCommandName.ToString()
            }
            elseif ($command -is [System.Management.Automation.FunctionInfo])
            {
                $command.ToString()
            }
            elseif ($command -is [System.Management.Automation.CmdletInfo])
            {
                $command.ToString()
            }

            $resolvedCommand = switch ($resolvedCommand)
            {
                "ForEach-Object"    {"foreach"}
                "Where-Object"      {"where"}
                "Measure-Object"    {"measure"}
                "Select-Object"     {"select"}
                "Sort-Object"       {"sort"}
                "Get-ChildItem"     {"ls"}
                default             {$psitem}
            }

            if ($resolvedCommand)
            {
                $extent = $token.Extent
                $length = $extent.EndOffset - $extent.StartOffset
                $startOfModifiedToken = $extent.StartOffset + $startAdjustment
                [Microsoft.Powershell.PSConsoleReadLine]::Replace(
                    $extent.StartOffset + $startAdjustment,
                    $length,
                    $resolvedCommand)

                # Our copy of the tokens won't have been updated, so we need to
                # adjust by the difference in length
                $startAdjustment += ($resolvedCommand.Length - $length)

                # Fixing the cursor position but only for the beginning of the string
                if( $startOfModifiedToken -lt $cursor )
                {
                    $cursor += ($resolvedCommand.Length - $length)
                }
            }
        }
    }

    # Fix the cursor position
    [Microsoft.Powershell.PSConsoleReadLine]::SetCursorPosition($cursor)
}

tm (Split-Path $PSCommandPath -Leaf)