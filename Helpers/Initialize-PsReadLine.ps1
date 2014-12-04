Import-Module PsReadLine

# Color scheme, the same is in 'source'
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

# Other options
Set-PSReadlineOption -ContinuationPrompt ([char] 187 + " ")
Set-PSReadlineKeyHandler -Chord "Ctrl+D, Ctrl+C" -Function CaptureScreen

# Remap search
Remove-PSReadlineKeyHandler -Chord "Ctrl+r"
Remove-PSReadlineKeyHandler -Chord "Ctrl+s"
Set-PSReadlineKeyHandler -Chord "F2" -Function ReverseSearchHistory
Set-PSReadlineKeyHandler -Chord "Shift+F2" -Function ForwardSearchHistory

Remove-PSReadlineKeyHandler -Chord "F8"
Remove-PSReadlineKeyHandler -Chord "Shift+F8"

#Shift+Up/Down should be for line select on multiline edit
#Set-PSReadlineKeyHandler -Chord "Shift+UpArrow" -Function HistorySearchBackward
#Set-PSReadlineKeyHandler -Chord "Shift+DownArrow" -Function HistorySearchForward
