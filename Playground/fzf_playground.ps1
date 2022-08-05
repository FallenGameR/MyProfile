fzf --margin 1% --padding 1% --border --preview 'bat {} --color=always --plain' --color preview-bg:#222222
fzf --preview 'pwsh -NoProfile -Command "ls"' --preview-window "cycle"

# Preview for opening file
fzf --margin 1% --padding 1% --border --preview 'bat {} --color=always --plain' --color preview-bg:#222222  --preview-window=55%

# Toggle between folders and files
# - on files can preview
# - on folders can open in code
find * | fzf --prompt 'All> ' \
             --header 'alt-D: Directories / alt-F: Files' \
             --bind 'alt-d:change-prompt(Directories> )+reload(find * -type d)' \
             --bind 'alt-f:change-prompt(Files> )+reload(find * -type f)'


fzf --preview 'pwsh -NoProfile -Command "ls"' --preview-window "down,3,wrap"


#!/usr/bin/env bash

# 1. Search for text in files using Ripgrep
# 2. Interactively narrow down the list using fzf
# 3. Open the file in Vim
IFS=: read -ra selected < <(
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
)
[ -n "${selected[0]}" ] && vim "${selected[0]}" "+${selected[1]}"