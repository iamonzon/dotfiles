#!/bin/bash

## Run this script with sudo ##
sudo apt-get update

sudo apt-get install -y git
git config --global color.ui true
git config --global push.default simple

applications=(
  git-cola
  vim
  vim-gnome
)
sudo apt-get install -y ${applications[@]}

shell=(
  zsh
  tilix
)

sudo apt-get install -y ${shell[@]} 

#Set zsh as default SHELL
chsh -s $(which zsh)

#Install oh-my-shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#Theme
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

DOTFILES_PATH=~/.dotfiles

#Clone repo in $HOME
git clone https://github.com/ivanlp10n2/environment-configurations $DOTFILES_PATH 

mkdir ~/Personal
mkdir ~/Work

source $DOTFILES_PATH/.profile
