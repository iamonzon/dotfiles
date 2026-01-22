{ config, pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./dev-tools.nix
    ./editors.nix
    ./media.nix
    ./pdf.nix
  ];

  home.username = "ivan";
  home.homeDirectory = "/Users/ivan";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Create standard directories
  home.file."Personal/Projects/.keep".text = "";
  home.file."Work/Projects/.keep".text = "";

  # Powerlevel10k config
  home.file.".p10k.zsh".source = ../files/p10k.zsh;
}
