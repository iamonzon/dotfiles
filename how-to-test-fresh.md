# Testing Nix Bootstrap on Fresh macOS

This guide explains how to test the `bootstrap-nix.sh` script on a fresh macOS installation using UTM virtualization.

## Prerequisites

Install UTM on your host machine:
```bash
brew install --cask utm
```

## Setting Up macOS VM in UTM

1. **Open UTM** and click "Create a New Virtual Machine"

2. **Select "Virtualize"** (not Emulate) for best performance on Apple Silicon

3. **Choose "macOS"** as the operating system

4. **Download macOS IPSW** (UTM will guide you, or get it from Apple)
   - UTM can automatically download the latest macOS
   - Or manually download from: https://ipsw.me/

5. **Configure VM resources:**
   - RAM: 8GB minimum (16GB recommended)
   - CPU: 4 cores minimum
   - Disk: 64GB minimum

6. **Start the VM** and complete the macOS setup wizard
   - Create a local user account
   - Skip Apple ID sign-in (optional)
   - Skip most optional setup steps to save time

## Running the Bootstrap Test

Once macOS is set up in the VM, open Terminal and run:

### Option A: Direct curl (if script is pushed to GitHub)
```bash
curl -fsSL https://raw.githubusercontent.com/iamonzon/dotfiles/master/bootstrap-nix.sh | bash
```

### Option B: Manual clone (recommended for testing)
```bash
# Step 1: Install Xcode CLI tools (needed for git)
xcode-select --install
# Wait for installation to complete...

# Step 2: Clone your dotfiles
git clone https://github.com/iamonzon/dotfiles ~/.dotfiles

# Step 3: Run bootstrap
~/.dotfiles/bootstrap-nix.sh
```

## Verification Checklist

After bootstrap completes, verify each component:

| Component | Test Command | Expected Result |
|-----------|--------------|-----------------|
| Shell | Open new terminal | Powerlevel10k prompt appears |
| Neovim | `nvim` | LazyVim UI loads |
| Yazi | `nix run ~/.dotfiles/nix#yazi-test` | File manager opens |
| Git aliases | `g st` | Runs `git status` |
| Zoxide | `cd ~/.dotfiles && cd ~ && z dot` | Returns to dotfiles |
| Environment | `echo $EDITOR` | Shows `nvim` |
| FZF | Press `Ctrl+R` | History search appears |
| Ripgrep | `rg --version` | Version number shown |
| Kitty | Open Kitty.app | Catppuccin theme applied |

## Rollback Instructions

If something goes wrong with home-manager:

```bash
# Roll back to previous generation
home-manager rollback

# List all generations
home-manager generations

# Switch to a specific generation
home-manager switch --flake ~/.dotfiles/nix#ivan
```

## VM Snapshots (Recommended)

Take UTM snapshots at key points to speed up re-testing:

1. **After macOS setup** - Clean slate before any tools
2. **After Xcode CLI** - Before Homebrew/Nix
3. **After successful bootstrap** - Known good state

To take a snapshot in UTM:
- Stop the VM
- Right-click VM → "Clone" or use the snapshot feature

## Troubleshooting

### Nix daemon not starting
```bash
# Check if daemon is running
sudo launchctl list | grep nix

# Restart daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Flakes not enabled
```bash
# Verify flakes config
cat ~/.config/nix/nix.conf
# Should contain: experimental-features = nix-command flakes
```

### home-manager command not found
```bash
# Run via nix run instead
nix run home-manager -- switch --flake ~/.dotfiles/nix#ivan
```

### Permission errors
```bash
# Fix Nix store permissions
sudo chown -R $(whoami) /nix
```

## Clean Re-test

To test from absolute scratch, delete the VM and create a new one, or restore to the "After macOS setup" snapshot.
