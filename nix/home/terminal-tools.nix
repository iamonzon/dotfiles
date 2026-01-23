{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ripgrep  # rg - fast grep
    fd       # better find
    tree     # directory tree
    tldr     # simplified man pages
  ];

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
    themes = {
      "Catppuccin Mocha" = {
        src = ../files/yazi/flavors/catppuccin-mocha.yazi;
        file = "tmtheme.xml";
      };
    };
  };
}
