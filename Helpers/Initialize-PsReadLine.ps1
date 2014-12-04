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
Set-PSReadlineKeyHandler -Chord "Ctrl+D, Ctrl+C" -Function CaptureScreen
