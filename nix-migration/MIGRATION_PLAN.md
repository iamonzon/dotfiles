# Nix Migration Plan

## Status

| Component | Status | Notes |
|-----------|--------|-------|
| Nix package manager | Not installed | Run `bootstrap.sh` to install |
| home-manager | Not installed | Installed via bootstrap |
| nix-darwin | Not installed | Optional, Phase 6 |
| Flakes enabled | No | Configured via bootstrap |
| home.nix linked | No | Done via bootstrap |

Last checked: 2025-01-14

---

## Current State

### Homebrew CLI Packages (brew leaves)
```
bat
btop
cloudflared
cocoapods
coursier/formulas/coursier
csvkit
dpkg
ffmpeg
fzf
gh
git
git-cola
git-lfs
gnu-sed
htop
ifstat
imagemagick
jq
maven
ncdu
neovide
nvm
openvino
p7zip
portaudio
powerlevel10k
pyenv
pyqt@5
python-setuptools
python@3.11
ripgrep
sherlock
sox
spotify_player
tldr
tree
vim
watch
wget
yarn
yt-dlp
```

### Homebrew Casks (GUI Applications)
```
boring-notch
docker-desktop
firefox@developer-edition
iterm2
jordanbaird-ice
pearcleaner
popclip
rectangle
stats
time-out
```

### Current Dotfiles Structure
```
~/.dotfiles/
├── zsh/
│   ├── .zshrc
│   ├── .aliases
│   └── configs/zsh/
│       ├── env.zsh
│       ├── options.zsh
│       ├── plugins.zsh
│       ├── functions.zsh
│       ├── fzf.zsh
│       ├── conda.zsh
│       ├── python.zsh
│       ├── nvm.zsh
│       ├── sdkman.zsh
│       └── android.zsh
├── lazy-vim/
├── vscode/
├── intellij/
└── iterm/
```

---

## FAQ: UI and macOS-Specific Packages

**Q: Do I have to skip UI or macOS-specific packages?**

No. You have options:

| Approach | CLI Packages | GUI Apps | macOS Settings |
|----------|--------------|----------|----------------|
| home-manager only | Yes (nixpkgs) | Limited | No |
| home-manager + homebrew | Yes (nixpkgs) | Yes (manual brew) | No |
| nix-darwin + home-manager | Yes (nixpkgs) | Yes (declarative casks) | Yes |

**Recommendation:** Start with home-manager for CLI tools and dotfiles. Add nix-darwin later if you want declarative GUI app management.

**Package availability:**
- Most CLI tools: available in nixpkgs
- GUI apps like iTerm2, Firefox: available in nixpkgs for macOS
- macOS-only apps (Rectangle, PopClip, Stats): only via homebrew casks
- nix-darwin can manage homebrew casks declaratively

---

## Migration Phases

### Phase 1: Install Nix + Home Manager (Day 1)

1. Install Nix (if not already installed):
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Enable flakes (add to `~/.config/nix/nix.conf`):
   ```
   experimental-features = nix-command flakes
   ```

3. Install home-manager:
   ```bash
   nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   nix-channel --update
   nix-shell '<home-manager>' -A install
   ```

4. Verify:
   ```bash
   home-manager --version
   ```

### Phase 2: Minimal home.nix (Core Tools)

Start with a minimal config that replaces your most-used brew packages:

```nix
# ~/.config/home-manager/home.nix
{ config, pkgs, ... }:

{
  home.username = "ivan";
  home.homeDirectory = "/Users/ivan";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Core packages (replacing brew)
  home.packages = with pkgs; [
    # Shell essentials
    bat
    btop
    htop
    fzf
    ripgrep
    fd
    tree
    jq
    tldr
    watch
    wget
    ncdu

    # Git
    git
    git-lfs
    gh

    # Development
    neovim

    # Media
    ffmpeg
    imagemagick
    yt-dlp
  ];
}
```

Apply with:
```bash
home-manager switch
```

### Phase 3: Migrate Zsh Config

```nix
# Add to home.nix
programs.zsh = {
  enable = true;

  shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";

    # Neovim
    vi = "nvim";
    vim = "nvim";

    # Git
    ga = "git add";
    gc = "git commit";
    gb = "git branch";
    gd = "git diff";
    gco = "git checkout";
    gp = "git push";
    gl = "git pull";
    glog = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

    # Directories
    workspace = "cd ~/Work";
    personalspace = "cd ~/Personal";
    pp = "cd ~/Personal/Projects/";
    wp = "cd ~/Work/Projects/";
    dot = "cd ~/.dotfiles/";

    # Tools
    lsg = "git status";
    lsd = "docker ps";
    cls = "clear";
    rmd = "rm -rf";
  };

  initExtra = ''
    # Custom functions
    mkcd() { mkdir -p "$1" && cd "$1"; }
    lt() { tree -L ''${1:-1}; }
  '';

  oh-my-zsh = {
    enable = true;
    plugins = [ "git" "docker" "fzf" ];
  };
};

programs.fzf = {
  enable = true;
  enableZshIntegration = true;
};
```

### Phase 4: Git Configuration

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";

  extraConfig = {
    color.ui = true;
    push.default = "simple";
    init.defaultBranch = "main";
  };

  aliases = {
    co = "checkout";
    br = "branch";
    ci = "commit";
    st = "status";
  };
};
```

### Phase 5: Development Environment Managers

**Note:** nvm, pyenv, sdkman don't fit the Nix model well. Options:

| Tool | Nix Alternative |
|------|-----------------|
| nvm | `pkgs.nodejs_20` or direnv + nix-shell per project |
| pyenv | `pkgs.python311` or direnv + nix-shell per project |
| sdkman | `pkgs.jdk21` + `pkgs.maven` + `pkgs.scala` |
| conda | `pkgs.conda` or pure nix python environments |

**Recommended approach:** Use project-level `shell.nix` or `flake.nix` files instead of global version managers.

Example project `shell.nix`:
```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs_20
    pkgs.python311
    pkgs.jdk21
  ];
}
```

Then `nix-shell` or `direnv allow` gives you that environment.

### Phase 6 (Optional): nix-darwin for System Config

If you want declarative GUI apps and macOS settings:

```nix
# flake.nix for nix-darwin
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, darwin, home-manager }: {
    darwinConfigurations."ivans-mac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or x86_64-darwin for Intel
      modules = [
        ./darwin-configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.users.ivan = import ./home.nix;
        }
      ];
    };
  };
}
```

```nix
# darwin-configuration.nix
{ pkgs, ... }:
{
  # Homebrew casks (GUI apps) managed declaratively
  homebrew = {
    enable = true;
    casks = [
      "docker-desktop"
      "firefox@developer-edition"
      "iterm2"
      "rectangle"
      "stats"
    ];
  };

  # macOS settings
  system.defaults = {
    dock.autohide = true;
    finder.ShowPathbar = true;
  };
}
```

---

## Package Migration Checklist

### CLI Tools - Migrate to nixpkgs
- [x] Mapping available

| Brew Package | Nixpkgs Equivalent | Status |
|--------------|-------------------|--------|
| bat | pkgs.bat | Ready |
| btop | pkgs.btop | Ready |
| cloudflared | pkgs.cloudflared | Ready |
| cocoapods | pkgs.cocoapods | Ready |
| coursier | pkgs.coursier | Ready |
| csvkit | pkgs.csvkit | Ready |
| ffmpeg | pkgs.ffmpeg | Ready |
| fzf | pkgs.fzf | Ready |
| gh | pkgs.gh | Ready |
| git | pkgs.git | Ready |
| git-lfs | pkgs.git-lfs | Ready |
| gnu-sed | pkgs.gnused | Ready |
| htop | pkgs.htop | Ready |
| imagemagick | pkgs.imagemagick | Ready |
| jq | pkgs.jq | Ready |
| maven | pkgs.maven | Ready |
| ncdu | pkgs.ncdu | Ready |
| neovide | pkgs.neovide | Ready |
| p7zip | pkgs.p7zip | Ready |
| powerlevel10k | pkgs.zsh-powerlevel10k | Ready |
| ripgrep | pkgs.ripgrep | Ready |
| sox | pkgs.sox | Ready |
| spotify_player | pkgs.spotify-player | Ready |
| tldr | pkgs.tldr | Ready |
| tree | pkgs.tree | Ready |
| vim | pkgs.vim | Ready |
| watch | pkgs.watch | Ready |
| wget | pkgs.wget | Ready |
| yarn | pkgs.yarn | Ready |
| yt-dlp | pkgs.yt-dlp | Ready |

### Special Cases
| Brew Package | Notes |
|--------------|-------|
| nvm | Use per-project shell.nix with specific nodejs version |
| pyenv | Use per-project shell.nix with specific python version |
| python@3.11 | pkgs.python311 |
| openvino | pkgs.openvino (may need overlay) |
| git-cola | pkgs.git-cola (GUI, works on macOS) |
| sherlock | May need custom derivation |

### GUI Apps - Keep in Homebrew (or nix-darwin)
These should stay as casks (managed by nix-darwin if desired):
- docker-desktop
- firefox@developer-edition
- iterm2
- rectangle
- stats
- boring-notch
- jordanbaird-ice
- pearcleaner
- popclip
- time-out

---

## Rollback Strategy

During migration, keep your bash dotfiles working:

1. Don't delete `~/.dotfiles/zsh` configs yet
2. Add nix tools to PATH alongside existing setup
3. Test each phase before committing
4. If something breaks: `home-manager generations` shows history
5. Rollback: `home-manager switch --rollback`

---

## Next Steps

1. [ ] Install Nix
2. [ ] Install home-manager
3. [ ] Create minimal home.nix with core packages
4. [ ] Run `home-manager switch`
5. [ ] Verify packages work
6. [ ] Gradually migrate zsh config
7. [ ] Create project-level shell.nix files
8. [ ] (Optional) Set up nix-darwin for GUI apps
