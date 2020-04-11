#!/bin/bash

## Run this script with sudo ##
sudo apt-get update

sudo apt-get install -y git
git config --global color.ui true
git config --global push.default simple

application (
  git-cola
  vim
  vim-gnome
)
sudo apt-get install -y application{$@}

# Zsh. Oh-my-shell. Tilix. Configure all the properties and themes and plugins. copy this files. Change global variables to $DOTFILES


