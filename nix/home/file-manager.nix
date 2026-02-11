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
        { run = "cd ~/dotfiles/current/"; on = ["d" "o"]; desc = "Go to active dotfiles";}
        { run = "cd ~/Work/Projects/"; on = ["w" "p"]; desc = "Go to work Projects";}
        { run = "cd ~/Personal/Projects/"; on = ["p" "p"]; desc = "Go to personal Projects";}
        { run = "tab_switch 1 --relative"; on = [ "J" ]; }
        { run = "tab_switch -1 --relative"; on = [ "K" ]; }
        { run = "close"; on = [ "x" ]; }
        { run = "close"; on = [ "<Esc>" ]; }
        { run = "cd --interactive"; on = [ "c" "d" ]; desc = "Change directory interactive"; }
        { run = "seek 20"; on = [ "<C-d>" ]; desc = "Preview page down"; }
        { run = "seek -20"; on = [ "<C-u>" ]; desc = "Preview page up"; }
        { run = "seek 1"; on = [ "<C-j>" ]; desc = "Preview scroll down"; }
        { run = "seek -1"; on = [ "<C-k>" ]; desc = "Preview scroll up"; }
      ];
    };
    yaziPlugins = {
      enable = true;
      plugins = {
        relative-motions = {
          enable = true;
          show_numbers = "relative_absolute";
          show_motion = true;
        };
      };
    };
  };

  # Copy flavor files for yazi themes
  home.file.".config/yazi/flavors".source = ../files/yazi/flavors;
}
