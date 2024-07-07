#!/bin/bash
#
#USAGE ./

DOTFILES_PATH=~/.dotfiles
DOTFILES_ZSH_PATH="$DOTFILES_PATH/zsh"
DRY_RUN=true
EXPECTED_HOME="$HOME/expected_home/$(date +%Y%m%d_%H%M%S)"

function log_info() {
    echo "[INFO] $1"
}

function log_error() {
    echo "[ERROR] $1" >&2
}
function set_home_dir() {
    if $DRY_RUN; then
        HOME="$EXPECTED_HOME"
        mkdir -p "$HOME"
        log_info "Dry run: Using $HOME as home directory"
    fi
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
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if $DRY_RUN; then
            log_info "Would install Oh My Zsh"
        else
            sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        fi
    fi
}

function install_powerlevel10k() {
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        if $DRY_RUN; then
            log_info "Would install Powerlevel10k theme"
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        fi
    fi
}

function setup_dotfiles() {
    log_info "Setting up dotfiles"
    git clone https://github.com/ivanlp10n2/dotfiles $DOTFILES_PATH
    # Change to the zsh directory and run the install script
    cd "$DOTFILES_PATH/zsh"
    if $DRY_RUN; then
        log_info "Would run ./install.sh --dry-run"
    else
        ./install.sh
    fi
    
    cd - # Return to the previous directory
}

function create_project_folders() {
    log_info "Creating project folders"
    mkdir -p ~/Personal/Projects
    mkdir -p ~/Work/Projects
}

function macos_installation() {
    set_home_dir
    install_homebrew
    install_applications
    configure_git
    set_zsh_as_default_shell
    install_oh_my_zsh
    install_powerlevel10k
    setup_dotfiles
    create_project_folders
    
    log_info "macOS setup complete!"
    if $DRY_RUN; then
        log_info "Dry run completed. Check $EXPECTED_HOME for expected changes."
        ls -la $EXPECTED_HOME
    fi
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
done

# Execute main function
macos_installation
