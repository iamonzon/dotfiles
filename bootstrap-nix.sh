#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is for macOS only"
fi

log "Starting Nix bootstrap for macOS..."

# 1. Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    log "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after Xcode CLI tools installation completes..."
    read -n 1
else
    log "Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to current session only (home-manager will manage .zprofile)
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log "Homebrew already installed"
    # Ensure brew is in current session
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

# 3. Backup shell dotfiles (Homebrew may have modified them, home-manager will manage them)
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
CONFLICTING_FILES=(.zprofile .zshrc .zshenv)
BACKED_UP=false

for file in "${CONFLICTING_FILES[@]}"; do
    # Back up regular files (not symlinks)
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        if [ "$BACKED_UP" = false ]; then
            log "Backing up existing dotfiles to $BACKUP_DIR..."
            mkdir -p "$BACKUP_DIR"
            BACKED_UP=true
        fi
        mv "$HOME/$file" "$BACKUP_DIR/"
        log "Backed up $file"
    fi
    # Remove broken symlinks pointing to /nix (from failed previous runs)
    if [ -L "$HOME/$file" ] && [[ "$(readlink "$HOME/$file")" == /nix/* ]] && [ ! -e "$HOME/$file" ]; then
        warn "Removing broken symlink: $HOME/$file"
        rm "$HOME/$file"
    fi
done

# 4. Install Nix
# Check for Nix installation by looking for the store, not the command
# (command check fails if nix-daemon.sh isn't sourced yet)
if [ ! -d "/nix" ]; then
    # Clean up any leftover backup files from previous failed installs
    for backup in /etc/bashrc.backup-before-nix /etc/zshrc.backup-before-nix /etc/bash.bashrc.backup-before-nix; do
        if [ -f "$backup" ]; then
            warn "Found leftover backup from failed Nix install: $backup"
            original="${backup%.backup-before-nix}"
            log "Restoring $original from backup..."
            sudo mv "$backup" "$original"
        fi
    done

    log "Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-modify-profile
else
    log "Nix already installed"
fi

# Source Nix for current session (needed whether fresh install or existing)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# 5. Enable Flakes
log "Enabling Nix flakes..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# 6. Clone dotfiles (if not already present)
DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/iamonzon/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
    log "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    log "Dotfiles directory already exists at $DOTFILES_DIR"
    log "Pulling latest changes..."
    cd "$DOTFILES_DIR" && git pull
fi

# 7. Run home-manager switch
log "Running home-manager switch..."
cd "$DOTFILES_DIR/nix"

# Dry run first
log "Performing dry-run to check for errors..."
if nix run home-manager -- switch --flake .#ivan --dry-run; then
    log "Dry-run successful! Applying configuration..."
    nix run home-manager -- switch --flake .#ivan
else
    error "Dry-run failed. Please check the errors above."
fi

# 8. Final setup
log "Bootstrap complete!"
echo ""
echo "=========================================="
echo "  Nix Home Manager setup complete!"
echo "=========================================="
echo ""
echo "Please restart your terminal or run:"
echo "  exec zsh"
echo ""
echo "To verify, check these commands:"
echo "  nvim --version"
echo "  rg --version"
echo "  z --help"
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Your old dotfiles were backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
fi
