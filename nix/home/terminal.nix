{ pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./tmux.nix
  ];

  # JetBrains Mono Nerd Font
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Enable fontconfig so macOS apps can find Nix-installed fonts
  fonts.fontconfig.enable = true;
}
