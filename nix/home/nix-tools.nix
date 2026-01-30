{ pkgs, ... }:

{
  home.packages = with pkgs; [
    statix
    deadnix
    nixfmt-rfc-style
    nil
    nix-output-monitor
  ];
}
