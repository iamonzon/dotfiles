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
    userName = "iamonzon";
    userEmail = "ivan@boddlelearning.com";

    settings = {
      color.ui = true;
      push.default = "simple";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      merge.tool = "nvimdiff";
      mergetool.keepBackup = false;
    };
  };

  # Worktree sync script: pull latest & warn about stale branches
  home.file.".config/scripts/git-worktree-sync.sh" = {
    executable = true;
    source = ./scripts/git-worktree-sync.sh;
  };

  # Worktree create script: create worktrees in the organized bare-repo layout
  home.file.".config/scripts/gwt-create" = {
    executable = true;
    source = ./scripts/gwt-create;
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
