{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nodejs
    ruby
    rubyPackages.solargraph
  ];
}
