{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wget         # network downloader
    cloudflared  # Cloudflare Tunnel client
    w3m          # terminal web browser
  ];
}
