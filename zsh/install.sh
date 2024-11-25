#!/bin/zsh
# USAGE: `./install.sh`. Parameters: --dry-run [optional]
# --dry-run: creates $EXPECTED_HOME folder and simulates execution

DOTFILES_PATH="$HOME/.dotfiles"
DOTFILES_ZSH_PATH="$DOTFILES_PATH/zsh"
DRY_RUN=false
EXPECTED_HOME="$HOME/expected_home/$(date +%Y%m%d_%H%M%S)"

# Parse command line arguments. expected: --dry-run
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
done

# Function to set the correct home directory
set_home_dir() {
    if $DRY_RUN; then
        HOME="$EXPECTED_HOME"
        mkdir -p "$HOME"
        echo "Dry run: Using $HOME as home directory"
    fi
}

backup_files(){
    BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$HOME/.zshenv" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$HOME/.aliases" "$BACKUP_DIR/" 2>/dev/null || true

    echo "Backup created at $BACKUP_DIR"
}

install_files(){
    local local_zsh="$HOME/.zshrc" 
    local local_zshenv="$HOME/.zshenv"
    local local_aliases="$HOME/.aliases"
    
    rm -f $local_zsh
    rm -f $local_zshenv
    rm -f $local_aliases   
    ln -sf "$DOTFILES_ZSH_PATH/.zshrc" $local_zsh
    ln -sf "$DOTFILES_ZSH_PATH/.zshenv" $local_zshenv
    ln -sf "$DOTFILES_ZSH_PATH/.aliases" $local_aliases
}

install_oh_my_zsh(){
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if $DRY_RUN; then
            echo "Would install Oh My Zsh"
        else
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        fi
    fi
}

install_powerlevel10k(){
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        if $DRY_RUN; then
            echo "Would install Powerlevel10k theme"
        else
            if command -v brew >/dev/null 2>&1; then
                brew install powerlevel10k
            else
                git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            fi
        fi
    fi
}

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y fzf ripgrep
    elif command -v brew >/dev/null 2>&1; then
        brew install fzf ripgrep
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y fzf ripgrep
    fi
}

run(){
    set_home_dir
    backup_files
    install_files
    install_oh_my_zsh
    install_powerlevel10k
    install_dependencies
    echo "Dotfiles installation complete!"
    if $DRY_RUN; then
        echo "Dry run completed. Check $EXPECTED_HOME for expected changes."
        ls -la $EXPECTED_HOME
    fi
}

run
