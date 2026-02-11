# dotfiles

Two configuration approaches: **Local** (traditional symlinks) and **Nix** (flake-based home-manager).

## Quick Start

| Approach | Command | Status |
|----------|---------|--------|
| Local | `./install.sh` | Stable |
| Nix | `home-manager switch --flake ~/dotfiles/nix#ivan` | Active |

## Nix Configuration

Flake-based home-manager setup in `nix/`:

```
nix/
├── flake.nix           # Entry point
├── home/
│   ├── default.nix     # Main config
│   ├── *.nix           # Tool modules (tmux, shell, kitty, etc.)
│   └── scripts/        # Executable scripts (runtime)
│       └── tmux/
└── files/              # Static assets (configs, themes, wallpapers)
    ├── starship/
    ├── yazi/
    └── wallpapers/
```

### Usage

```bash
# Apply configuration
home-manager switch --flake ~/dotfiles/nix#ivan

# Preview changes without applying
home-manager switch --flake ~/dotfiles/nix#ivan --dry-run

# Roll back to previous generation
home-manager switch --rollback

# List all generations
home-manager generations
```

### Adding Packages

Edit the relevant module in `nix/home/`:
- Shell tools → `dev-tools.nix`
- Media tools → `media.nix`
- Editors → `editors.nix`

Then apply with `home-manager switch --flake ~/dotfiles/nix#ivan`.

## Local Configuration (Legacy)

Traditional symlink-based configs:

| Directory | Purpose | Target |
|-----------|---------|--------|
| `zsh/` | Shell config (.zshrc, .aliases) | `~/.zshrc`, `~/.aliases` |
| `lazy-vim/` | Neovim (LazyVim) | `~/.config/nvim` |
| `intellij/` | IntelliJ settings exports | Manual import |
| `vscode/` | VS Code profiles | Manual import |
| `iterm/` | iTerm2 preferences | Manual import |
| `tilix/` | Tilix terminal (Linux) | Manual import |
| `tooling/` | Custom tools (bookmarks CLI) | - |

### Symlink Reference

```bash
ln -sf ~/dotfiles/lazy-vim ~/.config/nvim
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/.aliases ~/.aliases
```
