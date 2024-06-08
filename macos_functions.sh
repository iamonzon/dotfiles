#!/bin/bash
function macos_installation {
  echo =========== Installing brew-package-manager (brew) ===========
  export HOMEBREW_NO_INSTALL_FROM_API=1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  
  echo =========== Installing applications with brew  =========== 
  applications=(
    git
    nvim
    curl
    zsh
  )

  brew install -y ${applications[@]}

  echo  =========== GIT configuration ==============
  git config --global color.ui true
  git config --global push.default simple

  echo =========== Setting ZSH as SHELL ===========
  chsh -s $(which zsh)

  echo =========== Installing oh-my-shell ===========
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  echo =========== Installing plugins for Zsh ===========
  echo =========== Installing zsh-autosuggestions ===========
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  echo =========== Installing zsh-syntax-highlighting ===========
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

  echo =========== Installing autojump ===========
  sudo apt install -y autojump

  DOTFILES_PATH=~/.dotfiles
  echo =========== Cloning dotfiles in $DOTFILES_PATH to make safe links ============
  git clone https://github.com/ivanlp10n2/dotfiles $DOTFILES_PATH 

  echo =========== Making safe copies of the files =============
  #Make safe copies of the files
  echo =========== Creating backups '.bak' of the files '~/.zshrc, ~/.vimrc, ~/.vim ~/.nvim' =============
  mv ~/.zshrc ~/.bak.zshrc
  mv ~/.vimrc ~/.bak.vimrc
  mv ~/.vim ~/.bak.vim
  mv ~/.config/nvim ~/.config/.bak.nvim

  echo =========== Linking files ===========
  mkdir -p ~/.config/

  ln -s $DOTFILES_PATH/zsh/zshrc ~/.zshrc
  ln -s $DOTFILES_PATH/vim/.vimrc ~/.vimrc
  ln -s $DOTFILES_PATH/vim/.vim/ ~/.vim/

  echo =========== Copying git-pre-commit in this repo to prevent commiting with errors ============
  cp $DOTFILES_PATH/git-pre-commit-sample .git/hooks/pre-commit 
  chmod +x $DOTFILES_PATH/.git/hooks/pre-commit

  echo =========== Creating folders ===========
  mkdir -p ~/Personal/Projects
  mkdir -p ~/Work/Projects
}
