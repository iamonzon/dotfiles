{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    jq       # JSON processor
    csvkit   # CSV utilities
    gnused   # GNU sed
    p7zip    # 7-Zip archiver
  ];
}
