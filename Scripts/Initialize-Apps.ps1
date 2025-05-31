
Complete-Once install-PSToolset {
    cd $PsScriptRoot/../Modules
    git clone https://github.com/microsoft/PSToolset.git
}

Complete-Once install-FzfBindings {
    cd $PsScriptRoot/../Modules
    git clone https://github.com/FallenGameR/FzfBindings.git
}

Complete-Once install-as-tree {
    cargo install -f --git https://github.com/jez/as-tree
}

Complete-Once setup-winget {
    copy $PsScriptRoot\..\Tools\Winget\winget-settings.json $env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json
}

Complete-Once setup-git {
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

tm (Split-Path $PSCommandPath -Leaf)