#!/bin/bash

# Error handling
set -e  # Exit on error
trap 'echo "Error occurred at line $LINENO"' ERR

# Utility functions
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

install_if_missing() {
    local package=$1
    if ! dpkg -l | grep -q "^ii  $package "; then
        log_info "Installing $package..."
        sudo apt install -y "$package" || {
            log_error "Failed to install $package"
            return 1
        }
    else
        log_info "$package is already installed"
    fi
}

function setup_zsh_config() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Install Powerlevel10k theme properly
    if [ ! -d "$zsh_custom/themes/powerlevel10k" ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone https://github.com/romkatv/powerlevel10k.git "$zsh_custom/themes/powerlevel10k" || {
            log_error "Failed to install Powerlevel10k"
            return 1
        }
    fi

    # Link ZSH configurations
    log_info "Setting up ZSH configuration files..."
    ln -sf "$DOTFILES_PATH/zsh/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_PATH/zsh/.zshenv" "$HOME/.zshenv"
    ln -sf "$DOTFILES_PATH/zsh/.aliases" "$HOME/.aliases"
}

function setup_neovim_config() {
    log_info "Setting up Neovim configuration..."
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.vim"

    # Setup Vim configuration
    ln -sf "$DOTFILES_PATH/vim/.vimrc" "$HOME/.vimrc"
    ln -sf "$DOTFILES_PATH/vim/.vim" "$HOME/.vim"

    # Setup Neovim configuration
    ln -sf "$HOME/.vim" "$HOME/.config/nvim"
    ln -sf "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
    
    # Setup Lua configuration
    mkdir -p "$HOME/.config/nvim/lua"
    ln -sf "$DOTFILES_PATH/lua" "$HOME/.config/nvim/lua"
}

function linux_installation() {
    # Check if we're on a Debian-based system
    if ! command -v apt >/dev/null 2>&1; then
        log_error "This script requires apt package manager"
        return 1
    fi

    log_info "Updating package lists..."
    sudo apt update || {
        log_error "Failed to update package lists"
        return 1
    }

    # First, clone dotfiles repository
    DOTFILES_PATH="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES_PATH" ]; then
        log_info "Cloning dotfiles repository..."
        git clone https://github.com/ivanlp10n2/dotfiles "$DOTFILES_PATH" || {
            log_error "Failed to clone dotfiles repository"
            return 1
        }
    fi

    # Install basic dependencies
    log_info "Installing basic dependencies..."
    dependencies=(
        git
        curl
        zsh
        tilix
        neovim
        git-cola
        autojump
    )

    for dep in "${dependencies[@]}"; do
        install_if_missing "$dep"
    done

    # ZSH setup
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting ZSH as default shell..."
        sudo chsh -s "$(which zsh)" "$USER" || {
            log_error "Failed to set ZSH as default shell"
            return 1
        }
    fi

    # Oh My Zsh installation (with backup of existing .zshrc)
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        # Backup existing zsh config if it exists
        [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.pre-oh-my-zsh"
        
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended || {
            log_error "Failed to install Oh My Zsh"
            return 1
        }
    fi

    # ZSH plugins installation
    log_info "Installing ZSH plugins..."
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi

    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    fi

    # Setup ZSH configuration (including powerlevel10k)
    setup_zsh_config || {
        log_error "Failed to setup ZSH configuration"
        return 1
    }

    # Verify Neovim configuration files exist
    if [ ! -f "$DOTFILES_PATH/vim/.vimrc" ]; then
        log_error "Vim configuration file not found in dotfiles"
        return 1
    fi

    # Setup Neovim configuration
    setup_neovim_config || {
        log_error "Failed to setup Neovim configuration"
        return 1
    }

    # Create project directories
    log_info "Creating project directories..."
    mkdir -p "$HOME/Personal"
    mkdir -p "$HOME/Work"

    log_info "Linux installation completed successfully"
    log_info "Please log out and log back in for ZSH changes to take effect"
    log_info "After logging back in, run 'p10k configure' to setup your Powerlevel10k theme"
}

