#!/bin/bash
#
# Bootstrap script for Nix + home-manager setup
# Run: ~/.dotfiles/nix-migration/bootstrap.sh
#
# This script is idempotent - safe to run multiple times
#

set -e

DOTFILES_DIR="$HOME/.dotfiles"
NIX_CONFIG_DIR="$DOTFILES_DIR/nix-migration"
HOME_MANAGER_DIR="$HOME/.config/home-manager"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================
# STEP 1: Install Nix
# ============================================
install_nix() {
    if command -v nix &> /dev/null; then
        info "Nix already installed: $(nix --version)"
        return 0
    fi

    info "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install)

    warn "Nix installed. Please restart your terminal and run this script again."
    warn "Run: exec \$SHELL"
    exit 0
}

# ============================================
# STEP 2: Configure Nix (enable flakes)
# ============================================
configure_nix() {
    local nix_conf_dir="$HOME/.config/nix"
    local nix_conf="$nix_conf_dir/nix.conf"

    mkdir -p "$nix_conf_dir"

    if [[ -f "$nix_conf" ]] && grep -q "experimental-features" "$nix_conf"; then
        info "Nix flakes already enabled"
        return 0
    fi

    info "Enabling Nix flakes..."
    echo "experimental-features = nix-command flakes" >> "$nix_conf"
}

# ============================================
# STEP 3: Install home-manager
# ============================================
install_home_manager() {
    if command -v home-manager &> /dev/null; then
        info "home-manager already installed: $(home-manager --version)"
        return 0
    fi

    info "Adding home-manager channel..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update

    info "Installing home-manager..."
    # Use nix-shell to install home-manager
    nix-shell '<home-manager>' -A install

    info "home-manager installed"
}

# ============================================
# STEP 4: Link configuration
# ============================================
link_config() {
    local source_config="$NIX_CONFIG_DIR/home.nix"
    local target_dir="$HOME_MANAGER_DIR"
    local target_config="$target_dir/home.nix"

    if [[ ! -f "$source_config" ]]; then
        error "home.nix not found at $source_config"
        exit 1
    fi

    mkdir -p "$target_dir"

    # Backup existing config if it's not a symlink to our config
    if [[ -f "$target_config" ]] && [[ ! -L "$target_config" ]]; then
        warn "Backing up existing home.nix to home.nix.backup"
        mv "$target_config" "$target_config.backup"
    fi

    # Remove existing symlink if it points somewhere else
    if [[ -L "$target_config" ]]; then
        local current_target=$(readlink "$target_config")
        if [[ "$current_target" == "$source_config" ]]; then
            info "Config already linked correctly"
            return 0
        else
            rm "$target_config"
        fi
    fi

    info "Linking $source_config -> $target_config"
    ln -s "$source_config" "$target_config"
}

# ============================================
# STEP 5: Apply configuration
# ============================================
apply_config() {
    info "Applying home-manager configuration..."

    if home-manager switch; then
        info "Configuration applied successfully!"
    else
        error "home-manager switch failed"
        warn "Check the error above and fix home.nix"
        exit 1
    fi
}

# ============================================
# STEP 6: Verify installation
# ============================================
verify() {
    info "Verifying installation..."

    echo ""
    echo "Nix version:          $(nix --version)"
    echo "home-manager version: $(home-manager --version)"
    echo "Config location:      $(readlink $HOME_MANAGER_DIR/home.nix)"
    echo ""

    info "Testing a nix-installed package..."
    if command -v bat &> /dev/null; then
        echo "bat version:          $(bat --version | head -1)"
        info "Everything looks good!"
    else
        warn "bat not found - you may need to restart your shell"
        warn "Run: exec \$SHELL"
    fi
}

# ============================================
# Main
# ============================================
main() {
    echo ""
    echo "========================================"
    echo "  Nix + home-manager Bootstrap"
    echo "========================================"
    echo ""

    # Check if dotfiles exist
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        error "Dotfiles directory not found at $DOTFILES_DIR"
        error "Clone your dotfiles first:"
        error "  git clone git@github.com:YOUR_USER/dotfiles.git ~/.dotfiles"
        exit 1
    fi

    install_nix
    configure_nix
    install_home_manager
    link_config
    apply_config
    verify

    echo ""
    echo "========================================"
    echo "  Bootstrap complete!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your shell: exec \$SHELL"
    echo "  2. Your tools are ready to use"
    echo "  3. Edit config: nvim ~/.dotfiles/nix-migration/home.nix"
    echo "  4. Apply changes: home-manager switch"
    echo ""
}

# Run main function
main "$@"
