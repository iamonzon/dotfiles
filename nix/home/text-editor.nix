{ config, pkgs, lib, ... }:

{
  home.activation.ensureDotfilesCurrent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dotfiles_root="${config.home.homeDirectory}/dotfiles"
    current_link="$dotfiles_root/current"

    # Keep ~/dotfiles/current available so Neovim config follows the active worktree.
    if [ -L "$current_link" ] && [ ! -e "$current_link" ]; then
      rm -f "$current_link"
    fi

    if [ ! -e "$current_link" ]; then
      if [ -d "$dotfiles_root/master" ]; then
        ln -sfn "$dotfiles_root/master" "$current_link"
      elif [ -d "$dotfiles_root" ]; then
        ln -sfn "$dotfiles_root" "$current_link"
      fi
    fi
  '';

  home.packages = with pkgs; [
    neovim
    neovide  # Neovim GUI
  ];

  # LazyVim configuration follows active dotfiles worktree via ~/dotfiles/current.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/current/lazy-vim";
}
