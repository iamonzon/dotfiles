#!/bin/bash

DOTFILES_PATH=~/.dotfiles

function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}

function install_homebrew() {
    log_info "Installing Homebrew package manager"
    export HOMEBREW_NO_INSTALL_FROM_API=1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

function install_applications() {
    log_info "Installing applications with Homebrew"
    local applications=(
        git
        nvim
        curl
        zsh
    )
    brew install -y ${applications[@]}
}

function configure_git() {
    log_info "Configuring Git"
    git config --global color.ui true
    git config --global push.default simple
}

function set_zsh_as_default_shell() {
    log_info "Setting Zsh as default shell"
    chsh -s $(which zsh)
}

function install_oh_my_zsh() {
    log_info "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

function install_zsh_plugins() {
    log_info "Installing Zsh plugins"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    brew install autojump
}

function setup_dotfiles() {
    log_info "Setting up dotfiles"
    git clone https://github.com/ivanlp10n2/dotfiles $DOTFILES_PATH

    log_info "Creating backups of existing configuration files"
    mv ~/.zshrc ~/.bak.zshrc
    mv ~/.vimrc ~/.bak.vimrc
    mv ~/.vim ~/.bak.vim
    mv ~/.config/nvim ~/.config/.bak.nvim

    log_info "Linking configuration files"
    mkdir -p ~/.config/
    ln -s $DOTFILES_PATH/zsh/zshrc ~/.zshrc
    ln -s $DOTFILES_PATH/vim/.vimrc ~/.vimrc
    ln -s $DOTFILES_PATH/vim/.vim/ ~/.vim/

    log_info "Setting up Git pre-commit hook"
    cp $DOTFILES_PATH/git-pre-commit-sample .git/hooks/pre-commit 
    chmod +x $DOTFILES_PATH/.git/hooks/pre-commit
}

function create_project_folders() {
    log_info "Creating project folders"
    mkdir -p ~/Personal/Projects
    mkdir -p ~/Work/Projects
}

function macos_installation() {
    install_homebrew
    install_applications
    configure_git
    set_zsh_as_default_shell
    install_oh_my_zsh
    install_zsh_plugins
    setup_dotfiles
    create_project_folders
}

# Execute main function
macos_installation