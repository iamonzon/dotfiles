#!/bin/bash

# make aliases sudo-able
alias sudo="sudo "

# delete directories
alias rmd="rm -rf"

alias cls="clear"

# directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# list aliases
alias ls="ls --color=auto"
alias lf="ls -AhF"
alias ll="ls -AghF"
alias ld="ls -dghF .*/ */"

# git shortcuts
alias gs="git status"
alias ga="git add"
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

# git utilities
alias gff="git flow feature"
alias gfh="git flow hotfix"
alias gfr="git flow release"
alias g-c="git cola"

alias grep="grep --color=auto"


alias workspace="cd ~/Work/Projects/"
alias personalspace="cd ~/Personal/Projects/"

#Tools
#run in background command
bkgrnd='</dev/null &>/dev/null &'

alias eclipse="~/Tools/eclipse/eclipse $bkgrnd"
alias spotify="spotify $bkgrnd"

function firefoxcmd {
  firefox "$@"; 
}
function firefoxpcmd {
  firefox -private "$@"; 
}

