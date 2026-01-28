#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo "=========================================="
echo "  Nix & Homebrew Cleanup Script"
echo "=========================================="
echo ""
warn "This will remove Nix and optionally Homebrew from your system."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# 1. Uninstall Nix using official method
log "Uninstalling Nix..."
if [ -x /nix/nix-installer ]; then
    /nix/nix-installer uninstall
elif command -v nix-installer &>/dev/null; then
    nix-installer uninstall
else
    # Fallback: use Determinate Systems uninstaller
    warn "No local uninstaller found, using Determinate Systems uninstaller..."
    curl -L https://install.determinate.systems/nix | sh -s -- uninstall
fi

# 2. Clean up user state (not always removed by uninstaller)
log "Cleaning up user Nix files..."
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels 2>/dev/null || true
rm -rf ~/.local/state/nix ~/.local/state/home-manager 2>/dev/null || true
rm -rf ~/.config/nix ~/.cache/nix 2>/dev/null || true

log "Nix has been removed."
echo ""

# 3. Optionally remove Homebrew
read -p "Also remove Homebrew? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Removing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || true
    sudo rm -rf /opt/homebrew
    rm -f ~/.zprofile
    log "Homebrew removed."
else
    # Reset .zprofile to Homebrew only
    log "Resetting ~/.zprofile to Homebrew only..."
    cat > ~/.zprofile << 'EOF'
eval "$(/opt/homebrew/bin/brew shellenv)"
EOF
fi

echo ""
echo "=========================================="
echo "  Cleanup complete!"
echo "=========================================="
echo ""
echo "Please restart your terminal or run:"
echo "  exec zsh"
echo ""
echo "Then you can re-run ./bootstrap-nix.sh"
echo ""
