{ pkgs, ... }:

{
  home.packages = with pkgs; [
    statix
    deadnix
    nixfmt
    nil
    nix-output-monitor
  ];
}
