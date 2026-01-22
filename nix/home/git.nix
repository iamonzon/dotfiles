{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    git
    git-lfs
    gh  # GitHub CLI
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
}
