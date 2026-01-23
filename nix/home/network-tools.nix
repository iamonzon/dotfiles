{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wget         # network downloader
    cloudflared  # Cloudflare Tunnel client
  ];
}
