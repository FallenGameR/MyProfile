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
Set-PSReadlineOption -ContinuationPrompt ([char] 187 + " ")
Set-PSReadlineKeyHandler -Chord "Ctrl+d, Ctrl+c" -Function CaptureScreen
Set-PSReadlineKeyHandler -Chord 'Ctrl+d,Ctrl+e' -Function EnableDemoMode
Set-PSReadlineKeyHandler -Chord 'Ctrl+d,Ctrl+d' -Function DisableDemoMode
Set-PSReadlineKeyHandler -Chord "Ctrl+l" -Function ScrollDisplayToCursor
Set-PSReadlineKeyHandler -Chord "Ctrl+x" -Function DeleteCharOrExit
#Set-PSReadlineKeyHandler -Key Enter -Function AcceptLine       # Old enter behaviour

#
# Search
#
Remove-PSReadlineKeyHandler -Chord "Ctrl+r"
Remove-PSReadlineKeyHandler -Chord "Ctrl+s"
Set-PSReadlineKeyHandler -Chord "F2" -Function ReverseSearchHistory
Set-PSReadlineKeyHandler -Chord "Shift+F2" -Function ForwardSearchHistory
# Bug: Shift+Up/Down doesn't work, HistorySearch currently bound to default F8(Shift)
#Set-PSReadlineKeyHandler -Chord "Shift+UpArrow" -Function HistorySearchBackward
#Set-PSReadlineKeyHandler -Chord "Shift+DownArrow" -Function HistorySearchForward

#
# Navigation
#
Set-PSReadlineKeyHandler -Chord "Ctrl+UpArrow" -Function ScrollDisplayUpLine
Set-PSReadlineKeyHandler -Chord "Ctrl+DownArrow" -Function ScrollDisplayDownLine
Set-PSReadlineKeyHandler -Chord "Ctrl+LeftArrow" -Function ShellBackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+RightArrow" -Function ShellForwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+LeftArrow" -Function SelectShellBackwardWord
Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+RightArrow" -Function SelectShellForwardWord

#
# Deletion
#
Remove-PSReadlineKeyHandler -Chord "Ctrl+Backspace"
Remove-PSReadlineKeyHandler -Chord "Ctrl+Delete"
# Bug: Alt+Left/Right is better suited for this, but right now they wouldn't work
Set-PSReadlineKeyHandler -Chord "Alt+z" -Function ShellBackwardKillWord
Set-PSReadlineKeyHandler -Chord "Alt+c" -Function ShellKillWord
# Bug: Ctrl+End/Home should work like Shift+End/Home, but right now that's no possible to achieve
Set-PSReadlineKeyHandler -Chord "Ctrl+Home" -Function BackwardKillLine
Set-PSReadlineKeyHandler -Chord "Ctrl+End" -Function KillLine

#
# Regions
#
Set-PSReadlineKeyHandler -Chord 'Alt+`' -Function SetMark
Set-PSReadlineKeyHandler -Chord 'Alt+x' -Function KillRegion
Set-PSReadlineKeyHandler -Chord 'Ctrl+`' -Function ExchangePointAndMark

#
# Yank
#
Set-PSReadlineKeyHandler -Chord 'Alt+v' -Function Yank
Set-PSReadlineKeyHandler -Chord 'Alt+b' -Function YankPop
