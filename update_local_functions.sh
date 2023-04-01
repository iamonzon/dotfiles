#!/bin/zsh
# usage: backups to BKUP_FOLDER and loads all configs from DOTFILES_PATH
DOTFILES_PATH=~/.dotfiles
BKUP_FOLDER=$DOTFILES_PATH-bak
mkdir -p $BKUP_FOLDER

function update_common_configs {
  ZSH_SRC_PATH=$DOTFILES_PATH/zsh
  function update_vimrc {
    mv -f ~/.vimrc "$DOTFILES_PATH"/vim/.vimrc 2>/dev/null
    mv -f ~/.ideavimrc "$DOTFILES_PATH"/vim/.vimrc 2>/dev/null
    cp "$DOTFILES_PATH"/vim/.vimrc ~/.vimrc 2>/dev/null
    cp "$DOTFILES_PATH"/vim/.vimrc ~/.ideavimrc 2>/dev/null
  }
  function update_zshrc {
    mv -f ~/.zshrc "$BKUP_FOLDER"/.zshrc 2>/dev/null
    mv -f ~/.zsh_custom_cfg $BKUP_FOLDER/ 2>/dev/null
    mv -f ~/.zshenv $BKUP_FOLDER/ 2>/dev/null
    cp "$ZSH_SRC_PATH"/.zshrc ~/.zshrc 2>/dev/null
    cp "$ZSH_SRC_PATH"/.zsh_custom_cfg ~/.zsh_custom_cfg 2>/dev/null
    cp "$ZSH_SRC_PATH"/.zshenv ~/.zshenv 2>/dev/null
  }
  function update_power_10_k_theme {
    mv -f ~/.p10k.zsh $BKUP_FOLDER/ 2>/dev/null
    cp "$ZSH_SRC_PATH"/.p10k.zsh ~/.p10k.zsh 2>/dev/null
  }
  function update_aliases {
    mv -f ~/.aliases $BKUP_FOLDER/ 2>/dev/null
    cp "$ZSH_SRC_PATH"/.aliases ~/.aliases 2>/dev/null
  }

  echo ====== Backing up your cfg files to $(echo $BKUP_FOLDER) =======
  update_vimrc
  update_zshrc
  update_power_10_k_theme
  update_aliases
}

function update_tilix_configs {
  mv -f ~/.tilix $BKUP_FOLDER/ 2>/dev/null

  cp "$DOTFILES_PATH"/tilix/.tilix ~/.tilix 2>/dev/null
  cp "$DOTFILES_PATH"/profile-config ~/profile-config 2>/dev/null

  dconf load /com/gexperts/Tilix/ < $DOTFILES_PATH/tilix/tilix.dconf
}

function update_macos_configs {
  update_common_configs
}

function update_linux_configs {
  update_common_configs
  update_tilix_configs
}

function update_configs {
  os_name=$(uname)
  if [ "$os_name" = "Linux" ]; then
    update_linux_configs
  elif [ "$os_name" = "Darwin" ]; then
    update_macos_configs
  else
    echo "Unknown system."
  fi
}


