{ config, pkgs, lib, ... }:

{
  # 0xProto Nerd Font (matching iTerm config)
  home.packages = with pkgs; [
    nerd-fonts._0xproto
  ];

  # Enable fontconfig so macOS apps can find Nix-installed fonts
  fonts.fontconfig.enable = true;

  # Kitty terminal emulator
  programs.kitty = {
    enable = true;
    font = {
      name = "0xProto Nerd Font Mono";
      size = 22.0;
    };
    settings = {
      # Window
      window_padding_width = 10;
      hide_window_decorations = "titlebar-only";
      background_opacity = "0.95";

      # Terminal
      scrollback_lines = 10000;
      enable_audio_bell = false;
      shell = "/bin/zsh";
      cursor_shape = "block";

      # Layout - splits for iTerm-like pane behavior
      enabled_layouts = "splits,stack";

      # macOS specific
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";

      # Catppuccin Mocha colors
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#cdd6f4";
      selection_background = "#585b70";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      # ANSI colors
      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#f5c2e7";
      color6 = "#94e2d5";
      color7 = "#a6adc8";
      color8 = "#585b70";
      color9 = "#f37799";
      color10 = "#89d88b";
      color11 = "#ebd391";
      color12 = "#74a8fc";
      color13 = "#f2aede";
      color14 = "#6bd7ca";
      color15 = "#bac2de";
    };
    keybindings = {
      # Pane navigation (Alt+h/j/k/l)
      "alt+h" = "neighboring_window left";
      "alt+j" = "neighboring_window bottom";
      "alt+k" = "neighboring_window top";
      "alt+l" = "neighboring_window right";

      # Pane splitting (Alt+Ctrl+j/l)
      "alt+ctrl+j" = "launch --location=hsplit --cwd=current";
      "alt+ctrl+l" = "launch --location=vsplit --cwd=current";

      # Pane resizing (Alt+Shift+h/j/k/l)
      "alt+shift+h" = "resize_window narrower";
      "alt+shift+j" = "resize_window shorter";
      "alt+shift+k" = "resize_window taller";
      "alt+shift+l" = "resize_window wider";

      # Maximize pane (Alt+Ctrl+x)
      "alt+ctrl+x" = "toggle_layout stack";

      # Close pane (Cmd+w) - override default quit behavior
      "cmd+w" = "close_window";
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
