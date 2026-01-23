{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ffmpeg       # video/audio converter
    imagemagick  # image manipulation
    yt-dlp       # video downloader
    sox          # audio processing
  ];
}
