{ config, pkgs, lib, ... }:

{
  # Kitty terminal emulator
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14.0;
    };
    settings = {
      # Window
      window_padding_width = 10;
      hide_window_decorations = "titlebar-only";
      background_opacity = "0.95";

      # Terminal
      scrollback_lines = 10000;
      enable_audio_bell = false;

      # macOS specific
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";
    };
  };

  # Zellij terminal multiplexer
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = false;
      copy_on_select = true;
      pane_frames = false;
      theme = "catppuccin-mocha";
      session_serialization = true;
      scroll_buffer_size = 10000;
    };
  };
}
