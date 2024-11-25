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

    # Git installation and configuration
    if ! check_command git; then
        log_info "Installing Git..."
        install_if_missing git
        git config --global color.ui true
        git config --global push.default simple
    else
        log_info "Git is already installed"
    fi

    # Applications installation
    log_info "Installing applications..."
    applications=(
        git-cola
        nvim
    )

    for app in "${applications[@]}"; do
        install_if_missing "$app"
    done

    # Shell apps installation
    log_info "Installing shell applications..."
    shell=(
        tilix
        zsh
        curl
    )

    for app in "${shell[@]}"; do
        install_if_missing "$app"
    done

    # Tilix compatibility setup
    if [ -f "/etc/profile.d/vte-2.91.sh" ] && [ ! -f "/etc/profile.d/vte.sh" ]; then
        log_info "Setting up Tilix compatibility..."
        sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh
    fi

    # ZSH setup
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting ZSH as default shell..."
        sudo chsh -s "$(which zsh)" "$USER" || {
            log_error "Failed to set ZSH as default shell"
            return 1
        }
    fi

    # Oh My Zsh installation
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
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

    install_if_missing autojump

    # Powerlevel10k theme installation
    if [ ! -d "$HOME/powerlevel10k" ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k" || {
            log_error "Failed to install Powerlevel10k"
            return 1
        }
    fi

    # Dotfiles setup
    DOTFILES_PATH="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES_PATH" ]; then
        log_info "Cloning dotfiles repository..."
        git clone https://github.com/ivanlp10n2/dotfiles "$DOTFILES_PATH" || {
            log_error "Failed to clone dotfiles repository"
            return 1
        }
    fi

    # Neovim configuration
    log_info "Setting up Neovim configuration..."
    mkdir -p "$HOME/.config"
    
    # Only create symlinks if they don't exist or point to different locations
    if [ ! -L "$HOME/.config/nvim" ] || [ "$(readlink "$HOME/.config/nvim")" != "$HOME/.vim" ]; then
        ln -sf "$HOME/.vim" "$HOME/.config/nvim"
    fi
    
    if [ ! -L "$HOME/.config/nvim/init.vim" ] || [ "$(readlink "$HOME/.config/nvim/init.vim")" != "$HOME/.vimrc" ]; then
        ln -sf "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
    fi

    # Create project directories
    log_info "Creating project directories..."
    mkdir -p "$HOME/Personal"
    mkdir -p "$HOME/Work"

    log_info "Linux installation completed successfully"
}

