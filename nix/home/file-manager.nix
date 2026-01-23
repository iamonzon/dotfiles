{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
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
  };

  # Copy flavor files for yazi themes
  home.file.".config/yazi/flavors".source = ../files/yazi/flavors;
}
