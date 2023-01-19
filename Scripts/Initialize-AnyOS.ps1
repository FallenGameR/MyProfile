# Modules in profile subfolder
$modules = Join-Path (Split-Path $profile) Modules
if( -not $env:PSModulePath.Contains($modules) )
{
    $env:PSModulePath += [io.path]::PathSeparator + $modules
}

# PSToolset module
Complete-Once PSToolset {
    cd $PsScriptRoot/../Modules
    git clone https://github.com/microsoft/PSToolset.git
}

# FzfBindings module
Complete-Once FzfBindings {
    cd $PsScriptRoot/../Modules
    git clone https://github.com/FallenGameR/FzfBindings.git
}

# Git setup
Complete-Once "Git setup" {
    git config --global user.name "Aleksandr Kostikov"
    git config --global user.email "Alex.Kostikov@gmail.com"

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

    git config --global alias.co checkout
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.br branch
    git config --global alias.lg "log --graph --pretty=format:'%C(reset)%C(yellow)%h%C(reset) -%C(bold yellow)%d%C(reset) %s %C(green)(%cr) %C(cyan)<%an>%C(reset)' --abbrev-commit --date=relative -n 10"
    git config --global alias.gr "grep --break --heading --line-number -iIE"
}

# Default command arguments
$PSDefaultParameterValues["Get-Command:All"] = $true

# Aliases
Set-Alias m Measure-Object
Set-Alias ls Get-ChildItem -Option AllScope

# Common tools setup
$env:LESS = "-IeFRX"
$env:RIPGREP_CONFIG_PATH = "$PSScriptRoot/../rg.config"
$env:BAT_CONFIG_PATH = "$PSScriptRoot/../bat.config"

# Colors
if( Test-Full )
{
    # For some reason they changed progress color in PS 7.1.1
    $host.PrivateData.ProgressForegroundColor = "White"
    $host.PrivateData.ProgressBackgroundColor = "DarkCyan"
}

tm (Split-Path $PSCommandPath -Leaf)