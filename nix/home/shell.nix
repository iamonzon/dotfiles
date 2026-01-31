{ pkgs, lib, ... }:

{
  imports = [
    ./zoxide.nix
  ];

  programs.zsh = {
    enable = true;

    history = {
      size = 500000;
      save = 500000;
      path = "$HOME/.zsh_history";
    };

    # .zprofile content - survives macOS major upgrades (unlike /etc/zshrc)
    profileExtra = ''
      # Nix daemon
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      fi

      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Python 3.10
      PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:''${PATH}"
      export PATH

      # Coursier
      export PATH="$PATH:/Users/ivan/Library/Application Support/Coursier/bin"
    '';

    shellAliases = {
      # Make aliases sudo-able
      sudo = "sudo ";

      # Quick shortcuts
      y = "yazi";
      v = "nvim";
      d = "docker";
      b = "bat";
      g = "git";
      t = "tree";
      c = "claude";

      # Claude dangerous mode
      cdsp = "claude --dangerously-skip-permissions";

      # Home Manager
      hms = "home-manager switch --flake ~/.dotfiles/nix#ivan |& nom";

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

      # List (lsd with icons)
      ls = "lsd";
      l = "lsd -a --blocks date,size,name --date '+%Y%m%d-%H:%M'";
      la = "lsd -a";
      ll = "lsd -la"; # Full info
      lf = "lsd -aF";
      lt = "lsd --tree --depth 2";

      # Git shortcuts
      ga = "git add";
      gc = "git commit";
      gb = "git branch";
      gd = "git diff";
      gco = "git checkout";
      gp = "git push";
      gpm = "git push origin master";
      gl = "git log";
      gt = "git tag";
      gm = "git merge";
      glog = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ggstat = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --stat";
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
      dps = "docker ps";

      # Directory shortcuts
      workspace = "cd ~/Work";
      personalspace = "cd ~/Personal";
      pp = "cd ~/Personal/Projects/";
      wp = "cd ~/Work/Projects/";
      tp = "cd ~/Personal/Projects/tooling/";
      # dot = "cd ~/.dotfiles/";

      # Tools
      obsidian = ''open -a "Obsidian"'';

      timestamp = "date +%s";
    };

    # Powerlevel10k and syntax plugins
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
        # Auto-start tmux (attach existing or prompt for new session name)
        if [[ -z "$TMUX" ]] && command -v tmux &> /dev/null && [[ $- == *i* ]]; then
          if ! tmux attach-session 2>/dev/null; then
            read "name?New tmux session name: "
            tmux new-session -s "${name:-default}"
          fi
        fi

        # Custom functions
        mkcd() { mkdir -p "$1" && cd "$1"; }
        chpwd() { lsd -aF; }  # Auto-ls on directory change

        # Export paths
        export TERM="xterm-256color"
        export COLORTERM="truecolor"
        export DOTFILES_PATH=~/.dotfiles

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
    };
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden";
    defaultOptions = [
      "-m"
      "--height 50%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--preview-window=:hidden"
      "--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
      "--bind '?:toggle-preview'"
    ];
  };
}
