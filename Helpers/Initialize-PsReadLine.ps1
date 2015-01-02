# TODO: ctrl+x selection/line cut/quit
# TODO: ctrl+p variable name auto suggection
# TODO: Current char casing change
# TODO: Integrate shell chords to vim
# TODO: help opens msdn on .NET methods
# TODO: normalization normalizes .NET method names
#
# Combinations that wouldn't work:
#
# Alt+[Shift+]Up/Down/Left/Right - caused by .NET handling of Alt-unicode combinations)
# [Ctrl+]Shift+Up/Down - unclear reason why this doesn't work
# Ctrl+Alt+Up/Down/Left/Right - reserved for WinAmp
#
# Combinations to remember:
#
# Ctrl+Space - menu complete
# Ctrl+a - select whole line
# F2(Shift) - command search
# F3(Shift) - char search
# F8(Shift) - history search
# Ctrl+l - clear screen
# Ctrl+d,Ctrl+c - capture screen
# Ctrl+] - matching brace
# Alt+?(Ctrl) - get binding
# Ctrl+x - close on new line
# Alt+z/c - delete shell word on left/right
# Alt+w - stash line
# Alt+n - normalize command (expand alias, fix casing)
# Alt+' - change surrounding quotation
# Alt+( - add surrounding braces
#

Import-Module PsReadLine

#
# Color scheme, the same is in 'source'
#
Set-PSReadlineOption -TokenKind Command -ForegroundColor DarkCyan
Set-PSReadlineOption -TokenKind Comment -ForegroundColor DarkGreen
Set-PSReadlineOption -TokenKind Keyword -ForegroundColor Gray
Set-PSReadlineOption -TokenKind Number -ForegroundColor DarkGray
Set-PSReadlineOption -TokenKind Member -ForegroundColor DarkCyan
Set-PSReadlineOption -TokenKind Operator -ForegroundColor DarkRed
Set-PSReadlineOption -TokenKind Parameter -ForegroundColor DarkMagenta
Set-PSReadlineOption -TokenKind String -ForegroundColor DarkYellow
Set-PSReadlineOption -TokenKind Type -ForegroundColor DarkCyan
Set-PSReadlineOption -TokenKind Variable -ForegroundColor DarkGray

#
# Other options
#
Set-PSReadlineOption -HistorySaveStyle SaveAtExit
Set-PSReadlineOption -ContinuationPrompt ([char] 187 + " ")
Set-PSReadlineKeyHandler -Chord "Ctrl+d, Ctrl+c" -Function CaptureScreen
Set-PSReadlineKeyHandler -Chord 'Ctrl+d,Ctrl+e' -Function EnableDemoMode
Set-PSReadlineKeyHandler -Chord 'Ctrl+d,Ctrl+d' -Function DisableDemoMode
Set-PSReadlineKeyHandler -Chord "Ctrl+l" -Function ScrollDisplayToCursor
Set-PSReadlineKeyHandler -Key Enter -Function AcceptLine       # Old enter behaviour

#
# Search
#
Remove-PSReadlineKeyHandler -Chord "Ctrl+r"
Remove-PSReadlineKeyHandler -Chord "Ctrl+s"
Set-PSReadlineKeyHandler -Chord "F2" -Function ReverseSearchHistory
Set-PSReadlineKeyHandler -Chord "Shift+F2" -Function ForwardSearchHistory

#
# Navigation
#
Set-PSReadlineKeyHandler -Chord "Ctrl+UpArrow" -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Chord "Ctrl+DownArrow" -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Chord "Ctrl+LeftArrow" -Function BackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+LeftArrow" -Function SelectBackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+RightArrow" -Function SelectForwardWord

#
# Deletion
#
Remove-PSReadlineKeyHandler -Chord "Ctrl+Backspace"
Remove-PSReadlineKeyHandler -Chord "Ctrl+Delete"
Set-PSReadlineKeyHandler -Chord "Alt+q" -Function ShellBackwardKillWord
Set-PSReadlineKeyHandler -Chord "Alt+e" -Function ShellKillWord
Set-PSReadlineKeyHandler -Chord "Alt+a" -Function ShellBackwardWord
Set-PSReadlineKeyHandler -Chord "Alt+d" -Function ShellForwardWord
Set-PSReadlineKeyHandler -Chord "Alt+Shift+a" -Function SelectShellBackwardWord
Set-PSReadlineKeyHandler -Chord "Alt+Shift+d" -Function SelectShellForwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Home" -Function BackwardKillLine
Set-PSReadlineKeyHandler -Chord "Ctrl+End" -Function KillLine

#
# Ctrl+X that either:
# - cuts selected text
# - cuts whole unselected text
# - exits console
#
Set-PSReadlineKeyHandler -Key Ctrl+x `
                         -BriefDescription CutOrExit `
                         -LongDescription "Cuts selection, whole input or exits console" `
                         -ScriptBlock {
    # Work as cut if text is selected
    $start = $null
    $length = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetSelectionState([ref] $start, [ref] $length)
    if( $length -gt 0 )
    {
        [PSConsoleUtilities.PSConsoleReadLine]::Cut()
        return
    }

    # Work as line cut if no text is selected, but there is input
    $string = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref] $string, [ref] $cursor)
    if( $string )
    {
        Add-Type -AssemblyName PresentationCore
        [System.Windows.Clipboard]::SetText($string)
        [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
        return
    }

    # Otherwise quicly close the console
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("exit")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

#
# Alt+g invokes gvim
#
Set-PSReadlineKeyHandler -Key Alt+g `
                         -BriefDescription GVim `
                         -LongDescription "GVim invocation" `
                         -ScriptBlock {
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("gvim")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

#
# Alt+x invokes powershell in new window
#
Set-PSReadlineKeyHandler -Key Alt+x `
                         -BriefDescription PowershellNewWindow `
                         -LongDescription "Opens powershell in new window" `
                         -ScriptBlock {
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("start powershell")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

#
# Alt+c invokes git commit
#
Set-PSReadlineKeyHandler -Key Alt+c `
                         -BriefDescription GitExtensionsCommit `
                         -LongDescription "GitExtensions commit dialog invocation" `
                         -ScriptBlock {
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("gite commit")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

#
# Alt+b invokes gite
#
Set-PSReadlineKeyHandler -Key Alt+b `
                         -BriefDescription GitExtensions `
                         -LongDescription "GitExtensions main dialog invocation" `
                         -ScriptBlock {
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("gite")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadlineKeyHandler -Key Alt+w `
                         -BriefDescription SaveInHistory `
                         -LongDescription "Save current line in history but do not execute" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [PSConsoleUtilities.PSConsoleReadLine]::AddToHistory($line)
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
}

# Insert text from the clipboard as a here string
Set-PSReadlineKeyHandler -Key Ctrl+Shift+v `
                         -BriefDescription PasteAsHereString `
                         -LongDescription "Paste the clipboard text as a here string" `
                         -ScriptBlock {
    param($key, $arg)

    Add-Type -Assembly PresentationCore
    if ([System.Windows.Clipboard]::ContainsText())
    {
        # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
        $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n","`n").TrimEnd()
        [PSConsoleUtilities.PSConsoleReadLine]::Insert("@'`n$text`n'@")
    }
    else
    {
        [PSConsoleUtilities.PSConsoleReadLine]::Ding()
    }
}

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
# Alt+(
Set-PSReadlineKeyHandler -Key 'Alt+9' `
                         -BriefDescription ParenthesizeSelection `
                         -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
                         -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1)
    {
        [PSConsoleUtilities.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
        [PSConsoleUtilities.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else
    {
        [PSConsoleUtilities.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
        [PSConsoleUtilities.PSConsoleReadLine]::EndOfLine()
    }
}

# Each time you press Alt+', this key handler will change the token
# under or before the cursor.  It will cycle through single quotes, double quotes, or
# no quotes each time it is invoked.
Set-PSReadlineKeyHandler -Key "Alt+'" `
                         -BriefDescription ToggleQuoteArgument `
                         -LongDescription "Toggle quotes on the argument under the cursor" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $tokenToChange = $null
    foreach ($token in $tokens)
    {
        $extent = $token.Extent
        if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor)
        {
            $tokenToChange = $token

            # If the cursor is at the end (it's really 1 past the end) of the previous token,
            # we only want to change the previous token if there is no token under the cursor
            if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext())
            {
                $nextToken = $foreach.Current
                if ($nextToken.Extent.StartOffset -eq $cursor)
                {
                    $tokenToChange = $nextToken
                }
            }
            break
        }
    }

    if ($tokenToChange -ne $null)
    {
        $extent = $tokenToChange.Extent
        $tokenText = $extent.Text
        if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"')
        {
            # Switch to no quotes
            $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
        }
        elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'")
        {
            # Switch to double quotes
            $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
        }
        else
        {
            # Add single quotes
            $replacement = "'" + $tokenText + "'"
        }

        [PSConsoleUtilities.PSConsoleReadLine]::Replace(
            $extent.StartOffset,
            $tokenText.Length,
            $replacement)
    }
}

# Will normalize command with the resolved commands.
Set-PSReadlineKeyHandler -Key "Alt+n" `
                         -BriefDescription ExpandAliases `
                         -LongDescription "Replace all aliases with the full command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

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
                [PSConsoleUtilities.PSConsoleReadLine]::Replace(
                    $extent.StartOffset + $startAdjustment,
                    $length,
                    $resolvedCommand)

                # Our copy of the tokens won't have been updated, so we need to
                # adjust by the difference in length
                $startAdjustment += ($resolvedCommand.Length - $length)
            }
        }
    }
}

# F1 for help on the command line - naturally
Set-PSReadlineKeyHandler -Key F1 `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    if( ($tokens.Count -eq 1) -and ($tokens.Kind -eq "EndOfInput") )
    {
        [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
        [PSConsoleUtilities.PSConsoleReadLine]::Insert("Measure-LastCommand")
        [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
        return
    }

    $commandAst = $ast.FindAll( {
        $node = $args[0]
        $node -is [System.Management.Automation.Language.CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null)
    {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [System.Management.Automation.AliasInfo])
            {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null)
            {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}
