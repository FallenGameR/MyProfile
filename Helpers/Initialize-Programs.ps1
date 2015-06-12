#Requires -RunAsAdministrator

Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install gitextensions -y
choco install kdiff3 -y
choco install firefox -y

# Setting up git
git config --global user.name "Aleksandr Kostikov"
git config --global user.email "Alex.Kostikov@gmail.com"

# Tooling defaults - use colored grep and diff output, use TeamHub-compatible line endings notation, limit memory consumption for pack operation
# Also useful: git config --global color.diff.whitespace "blue reverse" - excluded since by default powershell console is blue
git config --global core.autocrlf true
git config --global core.pager 'less -q'
git config --global pack.threads 4
git config --global pack.windowMemory 256m

git config --global --replace-all color.grep auto
git config --global --replace-all color.grep.filename "green"
git config --global --replace-all color.grep.linenumber "cyan"
git config --global --replace-all color.grep.match "magenta"
git config --global --replace-all color.grep.separator "black"
git config --global --replace-all grep.lineNumber true
git config --global --replace-all grep.extendedRegexp true

git config --global --replace-all color.diff.meta "yellow"
git config --global --replace-all color.diff.frag "cyan"
git config --global --replace-all color.diff.func "cyan bold"
git config --global --replace-all color.diff.commit "yellow bold"

# Aliases for the most used commands
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.lg "log --graph --pretty=format:'%C(reset)%C(yellow)%h%C(reset) -%C(bold yellow)%d%C(reset) %s %C(green)(%cr) %C(cyan)<%an>%C(reset)' --abbrev-commit --date=relative -n 10"
git config --global alias.gr "grep --break --heading --line-number -iIE"
git config --global alias.df "diff head~1..head --word-diff-regex=[\.a-z]+"
