
# GNome terminal colors
# dconf dump /org/gnome/terminal/ # dump
# cat /home/fallengamer/.config/powershell/Bin/ColorTool/campbell.gnome_terminal | dconf load /org/gnome/terminal/

# Campbell colors

$a = bat /home/fallengamer/.config/powershell/convert -p |
    %{ $_ -match ".+?(\d+),(\d+),(\d+)\s*$" } |
    %{ @{R=[int]$matches[1];G=[int]$matches[2];B=[int]$matches[3]} }
function convert($clr)
{
    "#{0:X2}{1:X2}{2:X2}" -f $clr.R, $clr.G, $clr.B
}
$a | %{ convert $_ }

<#

DARK_BLACK      = 12,12,12      = #0C0C0C
DARK_RED        = 197,15,31     = #C50F1F
DARK_GREEN      = 19,161,14     = #13A10E
DARK_YELLOW     = 193,156,0     = #C19C00
DARK_BLUE       = 0,55,218      = #0037DA
DARK_MAGENTA    = 136,23,152    = #881798
DARK_CYAN       = 58,150,221    = #3A96DD
DARK_WHITE      = 204,204,204   = #CCCCCC
BRIGHT_BLACK    = 118,118,118   = #767676
BRIGHT_RED      = 231,72,86     = #E74856
BRIGHT_GREEN    = 22,198,12     = #16C60C
BRIGHT_YELLOW   = 249,241,165   = #F9F1A5
BRIGHT_BLUE     = 59,120,255    = #3B78FF
BRIGHT_MAGENTA  = 180,0,158     = #B4009E
BRIGHT_CYAN     = 97,214,214    = #61D6D6
BRIGHT_WHITE    = 242,242,242   = #F2F2F2

#>