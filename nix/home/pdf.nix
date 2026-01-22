{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    sioyek
  ];

  programs.sioyek = {
    enable = true;
    bindings = {
      "move_up" = "k";
      "move_down" = "j";
      "screen_down" = "d";
      "screen_up" = "u";

      "zoom_in" = "K";
      "zoom_out" = "J";

      "toggle_two_page_mode" = "D";
      "toggle_synctex" = "L";
      "synctex_under_cursor" = "H";
      "toggle_statusbar" = "S";
      "toggle_dark_mode" = "i";
    };
  };
}
