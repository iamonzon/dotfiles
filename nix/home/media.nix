{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
    yt-dlp
    sox
  ];
}
