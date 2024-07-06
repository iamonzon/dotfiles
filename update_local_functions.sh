#!/bin/zsh

DOTFILES_PATH=~/.dotfiles
BACKUP_FOLDER=$DOTFILES_PATH-bak
ZSH_SRC_PATH=$DOTFILES_PATH/zsh

# Utility functions
function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}

function create_backup_folder() {
    mkdir -p $BACKUP_FOLDER
}

function move_to_dotfiles_quietly() {
    local from_path=$1
    local to_path_in_dotfiles=$DOTFILES_PATH$2
    mv -f $from_path $to_path_in_dotfiles 2>/dev/null
}

function copy_from_dotfiles_quietly() {
    local from_path_in_dotfiles=$DOTFILES_PATH$1
    local to_path=$2
    cp -f $from_path_in_dotfiles $to_path 2>/dev/null
}

# Config update functions
function update_vim_configs() {
    move_to_dotfiles_quietly ~/.vimrc /vim/
    move_to_dotfiles_quietly ~/.ideavimrc /vim/
    copy_from_dotfiles_quietly /vim/.vimrc ~/.vimrc
    copy_from_dotfiles_quietly /vim/.ideavimrc ~/.ideavimrc
}

function update_zsh_configs() {
    mv -f ~/.zshrc "$BACKUP_FOLDER"/.zshrc 2>/dev/null
    mv -f ~/.zsh_custom_cfg $BACKUP_FOLDER/ 2>/dev/null
    mv -f ~/.zshenv $BACKUP_FOLDER/ 2>/dev/null
    copy_from_dotfiles_quietly "$ZSH_SRC_PATH"/.zshrc ~/.zshrc
    copy_from_dotfiles_quietly "$ZSH_SRC_PATH"/.zsh_custom_cfg ~/.zsh_custom_cfg
    copy_from_dotfiles_quietly "$ZSH_SRC_PATH"/.zshenv ~/.zshenv
}

function update_powerlevel10k_theme() {
    mv -f ~/.p10k.zsh $BACKUP_FOLDER/ 2>/dev/null
    copy_from_dotfiles_quietly "$ZSH_SRC_PATH"/.p10k.zsh ~/.p10k.zsh
}

function update_aliases() {
    mv -f ~/.aliases $BACKUP_FOLDER/ 2>/dev/null
    copy_from_dotfiles_quietly "$ZSH_SRC_PATH"/.aliases ~/.aliases
}

function update_common_configs() {
    log_info "Backing up your config files to $BACKUP_FOLDER"
    update_vim_configs
    update_zsh_configs
    update_powerlevel10k_theme
    update_aliases
}

function update_tilix_configs() {
    mv -f ~/.tilix $BACKUP_FOLDER/ 2>/dev/null
    copy_from_dotfiles_quietly /tilix/.tilix ~/.tilix
    copy_from_dotfiles_quietly /profile-config ~/profile-config
    dconf load /com/gexperts/Tilix/ < $DOTFILES_PATH/tilix/tilix.dconf
}

function update_macos_configs() {
    update_common_configs
}

function update_linux_configs() {
    update_common_configs
    update_tilix_configs
}

function update_configs() {
    local os_name=$(uname)
    case $os_name in
        "Linux")
            update_linux_configs
            ;;
        "Darwin")
            update_macos_configs
            ;;
        *)
            log_error "Unknown system: $os_name"
            return 1
            ;;
    esac
}

function main() {
    create_backup_folder
    update_configs
}

# Execute main function
main