# Architecture Vision: Thin Client + Cloud Development

## Intent

Move toward a setup where:
- Local machine is a lightweight interface (thin client)
- Heavy development happens on cloud VMs
- Configuration is portable and reproducible via Nix
- Offline work remains possible for essential tasks

## Target Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     LOCAL MACHINE (MacBook)                     │
│                        Role: Interface                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Hardware-Bound (cannot move to cloud):                         │
│    - Microphone input (SuperWhisper, voice transcription)       │
│    - Camera (video calls)                                       │
│    - Screen capture/recording                                   │
│    - Audio output                                               │
│    - Local displays                                             │
│                                                                 │
│  GUI Applications:                                              │
│    - Terminal emulator (iTerm2)                                 │
│    - Browser                                                    │
│    - Window management (Rectangle, Boring Notch)                │
│    - Notes (Obsidian - local-first with sync)                   │
│    - Communication (Slack, Discord, Zoom)                       │
│    - Games / entertainment                                      │
│                                                                 │
│  Connectivity:                                                  │
│    - SSH / mosh clients                                         │
│    - Tailscale (mesh VPN)                                       │
│    - Git credentials / SSH keys                                 │
│                                                                 │
│  Minimal Dev Tools (for offline):                               │
│    - neovim, git, basic CLI                                     │
│    - Local clones of active projects                            │
│                                                                 │
│  Managed by:                                                    │
│    - home-manager (dotfiles, CLI tools)                         │
│    - nix-darwin (system config, homebrew casks)                 │
│    - homebrew (macOS-only GUI apps)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ SSH / mosh / Tailscale
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CLOUD VM (Linux)                           │
│                    Role: Development Engine                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Project Code:                                                  │
│    - All repositories (cloned from GitHub/GitLab)               │
│    - Working directories                                        │
│    - Build artifacts                                            │
│                                                                 │
│  Development Runtimes:                                          │
│    - Node.js, Python, JDK, Scala, Rust, Go                      │
│    - Defined per-project via shell.nix / flake.nix              │
│                                                                 │
│  Services:                                                      │
│    - Docker containers                                          │
│    - Databases (Postgres, Redis, etc.)                          │
│    - Dev servers                                                │
│    - Background jobs                                            │
│                                                                 │
│  Heavy Compute:                                                 │
│    - Builds, compilation                                        │
│    - ML training                                                │
│    - Data processing                                            │
│                                                                 │
│  Session Persistence:                                           │
│    - tmux / zellij (survives disconnects)                       │
│    - Long-running processes                                     │
│                                                                 │
│  Managed by:                                                    │
│    - home-manager (same home.nix as local, minus GUI)           │
│    - NixOS (optional - full system config)                      │
│    - Project-level shell.nix / flake.nix                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Daily Workflow

### Starting Work

```bash
# Connect to dev VM (mosh handles network interruptions)
mosh devbox

# Land in persistent tmux session
# All state preserved from yesterday

# Navigate to project
cd ~/projects/my-app

# Load project environment
nix-shell  # or: direnv auto-loads

# Start working
nvim .
```

### Running Dev Servers

```bash
# On cloud VM
npm run dev  # server runs on port 3000

# On local machine - create tunnel
ssh -L 3000:localhost:3000 devbox

# Browser on local machine
open http://localhost:3000
```

### End of Day

```bash
# Just close laptop / disconnect
# tmux session persists
# Processes keep running
# Resume instantly tomorrow
```

## Offline Mode

### What Works Offline

| Category | Status | Notes |
|----------|--------|-------|
| Local git operations | Works | commit, branch, diff, log |
| Text editing (local files) | Works | neovim, VS Code |
| Note-taking | Works | Obsidian is local-first |
| Reading docs | Works | if cached or downloaded |
| GUI apps | Works | all local apps function |

### What Requires Connection

| Category | Status | Workaround |
|----------|--------|------------|
| Cloud VM access | Blocked | Work on local clones |
| Git push/pull | Blocked | Queue commits, sync later |
| Dev servers on VM | Blocked | Run locally if needed |
| Database access | Blocked | Use local SQLite or mock |
| API calls to services | Blocked | Use recorded fixtures |

### Offline Strategy

1. **Keep local clones** of actively-worked projects
2. **Sync before disconnecting** if anticipating offline work
3. **Accept reduced capability** - offline is for lighter work
4. **Batch commits** and push when reconnected

## Nix Configuration Strategy

### Single home.nix, Platform-Aware

```nix
{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # ══════════════════════════════════════════════
  # SHARED (both local Mac and cloud VM)
  # ══════════════════════════════════════════════

  programs.zsh = { /* shell config */ };
  programs.neovim = { /* editor config */ };
  programs.git = { /* git config */ };
  programs.fzf.enable = true;
  programs.bat.enable = true;

  home.packages = with pkgs; [
    ripgrep fd tree jq
    bat htop
    git gh git-lfs
  ];

  # ══════════════════════════════════════════════
  # LOCAL MAC ONLY
  # ══════════════════════════════════════════════

  home.packages = lib.mkIf isDarwin (with pkgs; [
    # Minimal - most dev tools on VM
    mosh        # better SSH
    tailscale   # mesh VPN
  ]);

  # macOS settings (via nix-darwin)
  # Managed in darwin-configuration.nix

  # ══════════════════════════════════════════════
  # CLOUD VM ONLY (Linux)
  # ══════════════════════════════════════════════

  home.packages = lib.mkIf isLinux (with pkgs; [
    # Heavy dev tools
    docker
    docker-compose
    kubectl

    # Build tools
    gnumake
    cmake
    gcc

    # Session management
    tmux
    zellij
  ]);

  # GNOME settings (if using desktop Linux)
  dconf.settings = lib.mkIf isLinux {
    # desktop customization
  };
}
```

### Project-Level Environments

```nix
# ~/projects/my-app/shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
    yarn
    postgresql
  ];

  shellHook = ''
    export DATABASE_URL="postgres://localhost/myapp_dev"
    echo "my-app dev environment loaded"
  '';
}
```

Projects define their own dependencies. No global version managers (nvm, pyenv, sdkman).

## Infrastructure Options

### Cloud VM Providers

| Provider | Pros | Cons |
|----------|------|------|
| Hetzner | Cheap, good EU locations | Manual setup |
| DigitalOcean | Simple, good UI | Mid-tier pricing |
| AWS EC2 | Flexible, spot instances | Complex, can get expensive |
| Fly.io | Easy provisioning | Less control |
| Home server | No recurring cost | Upfront cost, maintenance |

### Recommended Specs (Dev VM)

```
CPU: 4-8 cores
RAM: 16-32 GB
Storage: 100-200 GB SSD
OS: NixOS or Ubuntu + Nix
```

### Networking

```
┌──────────────┐     Tailscale      ┌──────────────┐
│  MacBook     │◄──────────────────►│  Cloud VM    │
│  100.x.x.x   │    (encrypted)     │  100.x.x.x   │
└──────────────┘                    └──────────────┘
       │
       │ SSH / mosh over Tailscale
       │ (no public IP exposure needed)
       ▼
```

Tailscale creates a private mesh network. VM doesn't need public SSH access.

## Hardware-Software Boundary

### Apps That Must Stay Local

| App | Reason |
|-----|--------|
| SuperWhisper | Needs microphone hardware |
| Screen recording | Needs display capture |
| Video conferencing | Camera + mic + low latency |
| Window managers | Controls local display |
| System utilities | macOS integration |
| Games | GPU, low latency display |

### Apps That Can Be Either

| App | Local | Remote | Notes |
|-----|-------|--------|-------|
| neovim | Yes | Yes | Same config both places |
| VS Code | Yes | Remote SSH | GUI local, compute remote |
| Browser | Yes | No | Always local |
| Obsidian | Yes | Sync | Local-first, optional sync |
| Spotify | Yes | No | Local playback |

### Apps Better on Remote

| App | Reason |
|-----|--------|
| Docker | Resource-heavy, always running |
| Databases | Persistent, resource-heavy |
| Build tools | CPU/memory intensive |
| ML training | GPU instances when needed |
| CI runners | Self-hosted runners |

## Migration Phases

### Phase 1: Local Nix Setup (Current)
- Install Nix + home-manager on Mac
- Port dotfiles to home.nix
- Keep all development local

### Phase 2: Add Cloud VM
- Provision a Linux VM
- Install Nix + home-manager (same config)
- SSH into VM for specific tasks

### Phase 3: Shift Development to VM
- Move project clones to VM
- Run dev servers on VM
- Use SSH tunnels for local access

### Phase 4: Thin Client Mode
- Local machine for interface only
- All development on VM
- Keep minimal local setup for offline

## Open Questions

- [ ] Which cloud provider to use?
- [ ] How to handle secrets/credentials across machines?
- [ ] Sync strategy for Obsidian notes?
- [ ] GPU access for ML work - dedicated VM or on-demand?
- [ ] Backup strategy for cloud VM state?
- [ ] Multiple VMs (work vs personal) or single VM?
