#!/bin/bash
function macos_installation {
  echo =========== Installing package-manager (brew) ===========
  export HOMEBREW_NO_INSTALL_FROM_API=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  
  echo =========== Installing applications  =========== 
  applications=(
    git
    git-cola
    nvim
  )

  brew install -y ${applications[@]}

  echo  =========== GIT configuration ==============
  git config --global color.ui true
  git config --global push.default simple

  echo  =========== Installing Shell apps =========== 
  shell=(
    zsh
    curl
  )

  brew install -y ${shell[@]} 

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
  DOTFILES_PATH=~/.dotfiles

  #Clone repo in $HOME
  git clone https://github.com/ivanlp10n2/dotfiles $DOTFILES_PATH 

  echo =========== Installing nvim =============
  mkdir -p ~/.config/
  ln -s ~/.vim ~/.config/nvim 
  ln -s ~/.vimrc ~/.config/nvim/init.vim 

  mkdir -p ~/Personal/Projects
  mkdir -p ~/Work/Projects

  source $DOTFILES_PATH/update-local-configs
}
