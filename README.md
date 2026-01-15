# dotfiles

Two configuration approaches: **Local** (traditional symlinks) and **Nix** (experimental, goal: single source of truth).

## Quick Start

| Approach | Command | Status |
|----------|---------|--------|
| Local | `./install.sh` | Stable |
| Nix | `./nix-migration/bootstrap.sh` | Experimental |

## Repository Structure

### Local Config

| Directory | Purpose | Target |
|-----------|---------|--------|
| `zsh/` | Shell config (.zshrc, .aliases) | `~/.zshrc`, `~/.aliases` |
| `lazy-vim/` | Neovim (LazyVim) | `~/.config/nvim` |
| `intellij/` | IntelliJ settings exports | Manual import |
| `vscode/` | VS Code profiles | Manual import |
| `iterm/` | iTerm2 preferences | Manual import |
| `tilix/` | Tilix terminal (Linux) | Manual import |
| `tooling/` | Custom tools (bookmarks CLI) | - |

| File | Purpose |
|------|---------|
| `install.sh` | Main installer (runs `update_local_functions.sh`) |
| `macos_functions.sh` | macOS-specific shell functions |
| `linux_functions.sh` | Linux-specific shell functions |

### Nix Config

| File | Purpose |
|------|---------|
| `nix-migration/home.nix` | Home Manager configuration |
| `nix-migration/bootstrap.sh` | Nix setup script |
| `nix-migration/MIGRATION_PLAN.md` | Transition roadmap |
| `nix-migration/ARCHITECTURE_VISION.md` | End-state design |

## Symlink Reference

```sh
# Neovim
ln -sf ~/.dotfiles/lazy-vim ~/.config/nvim

# Zsh
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.aliases ~/.aliases
```
