{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Shell essentials
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

    # Development
    nodejs

    # Archives
    p7zip

    # Other tools
    csvkit
    cloudflared
    gnused
  ];

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };
}
