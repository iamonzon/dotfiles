#!/bin/bash

## Run this script with sudo ##
echo Updating packages
sudo apt-get update

echo Installing and configuring GIT
sudo apt-get install -y git
git config --global color.ui true
git config --global push.default simple

echo Installing applications
applications=(
  git-cola
  vim
  vim-gnome
)
sudo apt-get install -y ${applications[@]}

echo Installing Shell apps
shell=(
  zsh
  tilix
)

sudo apt-get install -y ${shell[@]} 

echo Setting ZSH as SHELL
#Set zsh as default SHELL
chsh -s $(which zsh)

#Install oh-my-shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo Cloning Theme for ZSH
#Theme
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

DOTFILES_PATH=~/.dotfiles

#Clone repo in $HOME
git clone https://github.com/ivanlp10n2/environment-configurations $DOTFILES_PATH 

mkdir ~/Personal
mkdir ~/Work

source $DOTFILES_PATH/.profile
