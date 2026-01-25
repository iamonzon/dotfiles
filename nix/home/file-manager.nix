{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        ratio = [0 1 2];  # [parent, current, preview] - hides parent, 1/3 current, 2/3 preview
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
        image_filter = "triangle";
        image_quality = 75;
      };
    };
    theme = {
      flavor = {
        dark = "catppuccin-mocha";
        light = "catppuccin-mocha";
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        { on = [ "<C-d>" ]; run = "seek 20"; desc = "Preview page down"; }
        { on = [ "<C-u>" ]; run = "seek -20"; desc = "Preview page up"; }
        { on = [ "<C-j>" ]; run = "seek 1"; desc = "Preview scroll down"; }
        { on = [ "<C-k>" ]; run = "seek -1"; desc = "Preview scroll up"; }
      ];
    };
  };

  # Copy flavor files for yazi themes
  home.file.".config/yazi/flavors".source = ../files/yazi/flavors;
}
