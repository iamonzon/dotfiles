{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    neovim
    neovide  # Neovim GUI
  ];

  # File explorer
  programs.yazi.enable = true;
}
