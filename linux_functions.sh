#!/bin/bash
function linux_installation {
  echo =========== Updating packages ===========
  sudo apt update

  echo Installing and configuring GIT
  sudo apt install -y git
  git config --global color.ui true
  git config --global push.default simple

  echo =========== Installing applications  =========== 
  applications=(
    git-cola
    nvim
  )

  sudo apt install -y ${applications[@]}

  echo  =========== NVIM configuration ==============

  echo  =========== Installing Shell apps =========== 
  shell=(
    tilix
    zsh
    curl
  )

  sudo apt install -y ${shell[@]} 

  #Tilix compatiblity (https://gnunn1.github.io/tilix-web/manual/vteconfig/)
  #sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh 

  echo Setting ZSH as SHELL
  #Set zsh as default SHELL
  chsh -s $(which zsh)

  #Install oh-my-shell
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  echo =========== Installing plugins for Zsh ===========
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

  sudo apt install -y autojump

  echo =========== Cloning Theme for ZSH ===========
  #Theme
  git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

  DOTFILES_PATH=~/.dotfiles

  #Clone repo in $HOME
  git clone https://github.com/ivanlp10n2/dotfiles $DOTFILES_PATH 

  echo =========== Installing nvim =============
  mkdir -p ~/.config/
  ln -s ~/.vim ~/.config/nvim 
  ln -s ~/.vimrc ~/.config/nvim/init.vim 

  mkdir ~/Personal
  mkdir ~/Work
}

