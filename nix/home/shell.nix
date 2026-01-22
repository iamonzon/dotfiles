{ config, pkgs, lib, ... }:

{
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
        # Custom functions
        mkcd() { mkdir -p "$1" && cd "$1"; }
        lt() { tree -L ''${1:-1}; }
        chpwd() { ls --color=auto -AhF; }  # Auto-ls on directory change

        # Export paths
        export TERM="xterm-256color"
        export COLORTERM="truecolor"
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
    };
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
