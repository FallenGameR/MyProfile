fzf --preview 'pwsh -NoProfile -Command "ls"' --preview-window "cycle"

# Toggle between folders and files
# - on files can preview
# - on folders can open in code
find * | fzf --prompt 'All> ' \
             --header 'alt-D: Directories / alt-F: Files' \
             --bind 'alt-d:change-prompt(Directories> )+reload(find * -type d)' \
             --bind 'alt-f:change-prompt(Files> )+reload(find * -type f)'

& "C:\Program Files\Git\usr\bin\find.exe" . -not -path */.git/*