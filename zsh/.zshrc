source_if_exists() {
    if [[ ! -f "$1" ]]; then
        echo "File $1 does not exist. Omitting."
        return
    fi
    source "$1"
}
enable_oh_my_zsh(){
    echo "Enabling Oh My Zsh"
    source_if_exists ~/.oh-my-zsh/oh-my-zsh.sh
}
enable_powerlevel10k(){
    echo "Enabling Powerlevel10k"
    source_if_exists /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
    source_if_exists "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
}

export TERM="xterm-256color"
export DOTFILES_PATH=~/.dotfiles
export ZSH_SRC_PATH=$DOTFILES_PATH/zsh
export PATH="~/.zshrc:$PATH"

load_config_files() {
  local zsh_configs="$ZSH_SRC_PATH/configs/zsh"

  local files=(
      "$ZSH_SRC_PATH/.aliases"
      "$zsh_configs/env.zsh"
      "$zsh_configs/options.zsh"
      "$zsh_configs/plugins.zsh"
      "$zsh_configs/functions.zsh"
      "$zsh_configs/fzf.zsh"
      "$zsh_configs/conda.zsh"
      "$zsh_configs/python.zsh"
      "$zsh_configs/nvm.zsh"
      "$zsh_configs/sdkman.zsh"
      #"$DOTFILES_PATH/tilix/.tilix"
      "$HOME/.p10k.zsh"
  )

  for file in "${files[@]}"; do
      source_if_exists "$file"
  done
}

run(){
    load_config_files
    enable_oh_my_zsh
    enable_powerlevel10k
}

# Main execution
run