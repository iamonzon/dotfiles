{ pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./tmux.nix
  ];

  # 0xProto Nerd Font (matching iTerm config)
  home.packages = with pkgs; [
    nerd-fonts._0xproto
  ];

  # Enable fontconfig so macOS apps can find Nix-installed fonts
  fonts.fontconfig.enable = true;
}
