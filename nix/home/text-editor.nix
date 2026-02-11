{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    neovim
    neovide  # Neovim GUI
  ];

  # LazyVim configuration (direct symlink to dotfiles, keeps files writable)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/Users/ivan/dotfiles/lazy-vim";
}
