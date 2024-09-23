source_if_exists() {
    if [[ ! -f "$1" ]]; then
        echo "File $1 does not exist. Omitting."
        return
    fi
    source "$1"
}

bm() {
  python -u ~/.dotfiles/tooling/bookmarks_cli.py "$@" | while IFS= read -r line; do
    echo "$line"
    if [[ "$line" == cd* ]]; then
      cd_command="$line"
    fi
  done
  if [[ -n "$cd_command" ]]; then
    eval "$cd_command"
  fi
}

enable_oh_my_zsh(){
    echo "Enabling Oh My Zsh"
    source_if_exists ~/.oh-my-zsh/oh-my-zsh.sh
}
enable_p10k_instant_prompt(){
    local INSTANT_PROMPT_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    source_if_exists "$INSTANT_PROMPT_PATH"
}
enable_p10k_theme(){
    local USER_V1="opt"
    local USER_V2="Cellar/powerlevel10k/1.20.0/share"
    local PATH_V1="/opt/homebrew/$USER_V1/powerlevel10k/powerlevel10k.zsh-theme"
    local PATH_V2="/opt/homebrew/$USER_V2/powerlevel10k/powerlevel10k.zsh-theme"

    if [[ -f "$PATH_V1" ]]; then
        source "$PATH_V1"
    elif [[ -f "$PATH_V2" ]]; then
        source "$PATH_V2"
    else
        echo "Error: Powerlevel10k theme not found in either path."
        return 1
    fi
}
enable_powerlevel10k(){
    echo "Enabling Powerlevel10k"
    source_if_exists "$HOME/.p10k.zsh" # created after p10k configure
    enable_p10k_theme
    enable_p10k_instant_prompt
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
