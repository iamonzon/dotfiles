# make aliases sudo-able
alias sudo="sudo "

# directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# view aliases
alias ls ="ls --color=auto"
alias lf="ls -A"
alias ll="ls -Ag"
alias ld="ls -dg .*/ */"

# git shortcuts
alias gs="git status"
alias ga="git add -A ."
alias gc="git commit"
alias gb="git branch"
alias gd="git diff"
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"
alias gt="git tag"
alias gm="git merge"
alias gg="git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gcp="git cherry-pick"
alias gbg="git bisect good"
alias gbb="git bisect bad"

alias grep="grep --color=auto"
