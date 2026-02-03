{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    git
    git-lfs
    gh  # GitHub CLI
    gitmux  # Git status in tmux status bar
  ];

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

  # Gitmux config (p10k-matching format)
  xdg.configFile."gitmux/.gitmux.conf".text = ''
    tmux:
      symbols:
        branch: ""
        hashprefix: "@"
        ahead: "⇡"
        behind: "⇣"
        staged: "+"
        conflict: "~"
        modified: "!"
        untracked: "?"
        stashed: "*"
        clean: ""
      styles:
        clear: "#[fg=default]"
        branch: "#[fg=green]"
        remote: "#[fg=cyan]"
        divergence: "#[fg=green]"
        staged: "#[fg=yellow]"
        conflict: "#[fg=red]"
        modified: "#[fg=yellow]"
        untracked: "#[fg=blue]"
        stashed: "#[fg=green]"
        clean: "#[fg=green]"
      layout: [branch, divergence, " ", flags]
      options:
        branch_max_len: 32
        branch_trim: right
        ellipsis: "…"
        hide_clean: true
  '';
}
