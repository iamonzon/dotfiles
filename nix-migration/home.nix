# Starter home.nix for ivan
# Location: ~/.config/home-manager/home.nix
#
# Apply with: home-manager switch
# Rollback with: home-manager switch --rollback

{ config, pkgs, lib, ... }:

{
  home.username = "ivan";
  home.homeDirectory = "/Users/ivan";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # ============================================
  # PACKAGES
  # ============================================

  home.packages = with pkgs; [
    # Shell essentials
    bat           # better cat
    btop          # better top
    htop
    fzf
    ripgrep       # rg
    fd            # better find
    tree
    jq
    tldr
    watch
    wget
    ncdu          # disk usage

    # Git
    git
    git-lfs
    gh            # GitHub CLI

    # Development
    neovim
    neovide       # Neovim GUI
    nodejs

    # Media
    ffmpeg
    imagemagick
    yt-dlp
    sox

    # Archives
    p7zip

    # Other tools
    csvkit
    cloudflared
    gnused

    # pdf reader
    sioyek
  ];
  
  # ============================================
  # File explorer
  # ============================================

  programs.yazi.enable = true;


  # ============================================
  # ZSH
  # ============================================

  programs.zsh = {
    enable = true;

    shellAliases = {
      # Make aliases sudo-able
      sudo = "sudo ";

      # Delete directories
      rmd = "rm -rf";
      cls = "clear";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # Neovim
      vi = "nvim";
      vim = "nvim";

      # List
      lf = "ls -AhF";

      # Git shortcuts
      ga = "git add";
      gc = "git commit";
      gb = "git branch";
      gd = "git diff";
      gco = "git checkout";
      gp = "git push";
      gpm = "git push origin master";
      gl = "git pull";
      gt = "git tag";
      gm = "git merge";
      glog = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ggstat = "git log --graph --stat";
      gcp = "git cherry-pick";

      # Git utilities
      gff = "git flow feature";
      gfh = "git flow hotfix";
      gfr = "git flow release";

      # Git bisect
      gbg = "git bisect good";
      gbb = "git bisect bad";

      # Grep with color
      grep = "grep --color=auto";

      # Useful lists
      lsg = "git status";
      lsd = "docker ps";

      # Directory shortcuts
      workspace = "cd ~/Work";
      personalspace = "cd ~/Personal";
      pp = "cd ~/Personal/Projects/";
      wp = "cd ~/Work/Projects/";
      tp = "cd ~/Personal/Projects/tooling/";
      dot = "cd ~/.dotfiles/";

      # Tools
      obsidian = ''open -a "Obsidian"'';

      timestamp = "date +%s";
    };

    # Powerlevel10k
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Enable Powerlevel10k instant prompt (must be at top)
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        # Custom functions
        mkcd() { mkdir -p "$1" && cd "$1"; }
        lt() { tree -L ''${1:-1}; }
        chpwd() { ls --color=auto -AhF; }  # Auto-ls on directory change

        # Export paths
        export TERM="xterm-256color"
        export DOTFILES_PATH=~/.dotfiles

        # Keep existing configs working during migration
        if [[ -f "$DOTFILES_PATH/zsh/configs/zsh/env.zsh" ]]; then
          source "$DOTFILES_PATH/zsh/configs/zsh/env.zsh"
        fi
        
        # Load p10k config
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      ''
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "macos"
      ];
      # Theme handled by powerlevel10k below
    };

  };

  # ============================================
  # FZF
  # ============================================

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ============================================
  # GIT
  # ============================================

  programs.git = {
    enable = true;
    # Uncomment and fill in your details:
    # userName = "Ivan";
    # userEmail = "your@email.com";

    settings = {
      color.ui = true;
      push.default = "simple";
      init.defaultBranch = "main";
    };
  };

  # ============================================
  # BAT (better cat)
  # ============================================

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };
  # ============================================
  # PDF reader
  # ============================================
  programs.sioyek = {
      enable = true;
      bindings = {
          "move_up" = "k";
          "move_down" = "j";
          "screen_down" = "d";
          "screen_up" = "u";

          "zoom_in" = "K";
          "zoom_out" = "J";

          "toggle_two_page_mode" = "D";
          "toggle_synctex" = "L";
          "synctex_under_cursor" = "H";
          "toggle_statusbar" = "S";
          "toggle_dark_mode" = "i";
      };
  };

  # ============================================
  # ENVIRONMENT VARIABLES
  # ============================================

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
  ];

  # ============================================
  # DIRECTORIES
  # ============================================

  home.file."Personal/Projects/.keep".text = "";
  home.file."Work/Projects/.keep".text = "";

  # Powerlevel10k config (shows only current folder name in prompt)
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
