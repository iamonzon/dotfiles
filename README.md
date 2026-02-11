# dotfiles

Two configuration approaches: **Local** (traditional symlinks) and **Nix** (flake-based home-manager).

## Quick Start

| Approach | Command | Status |
|----------|---------|--------|
| Local | `./install.sh` | Stable |
| Nix | `hms` | Active |

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
hms

# Apply a specific worktree/branch configuration
hms feat/kitty-integration

# Preview changes without applying
hms --dry-run
hms feat/kitty-integration --dry-run

# Roll back to previous generation
home-manager switch --rollback

# List all generations
home-manager generations
```

### Worktree Modes

`hms` supports both repository layouts:

1. Without worktrees (single clone)

```text
~/dotfiles/
  nix/
  lazy-vim/
```

`hms` resolves to `~/dotfiles/nix`.

2. With worktrees (branch-aware setup)

```text
~/dotfiles/
  master/
    nix/
    lazy-vim/
  feat/kitty-integration/
    nix/
    lazy-vim/
  current -> master (or another selected worktree)
```

- `hms` resolves to `~/dotfiles/master/nix` (fallback `~/dotfiles/nix`)
- `hms feat/kitty-integration` resolves to `~/dotfiles/feat/kitty-integration/nix`
- On successful switch, `hms` updates `~/dotfiles/current` to the selected worktree
- Neovim is linked to `~/dotfiles/current/lazy-vim`, so editor config follows the active worktree

### Adding Packages

Edit the relevant module in `nix/home/`:
- Shell tools → `dev-tools.nix`
- Media tools → `media.nix`
- Editors → `editors.nix`

Then apply with `hms`.

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

Without worktrees:

```bash
ln -sf ~/dotfiles/lazy-vim ~/.config/nvim
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/.aliases ~/.aliases
```

With worktrees:

```bash
ln -sf ~/dotfiles/current/lazy-vim ~/.config/nvim
ln -sf ~/dotfiles/current/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/current/zsh/.aliases ~/.aliases
```
