if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden'
    export FZF_DEFAULT_OPTS="-m --height 50% --layout=reverse --border --inline-info 
    --preview-window=:hidden
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
    --bind '?:toggle-preview'"
fi
