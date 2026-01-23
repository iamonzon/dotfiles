{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    btop   # better top
    htop   # interactive process viewer
    ncdu   # disk usage analyzer
    watch  # execute command periodically
  ];
}
