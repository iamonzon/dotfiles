{ theme, rightSep, ... }:

{
  catppuccinConfig = ''
    # Theme
    set -g @catppuccin_flavor "${theme}"

    # Status module separators (pill shape)
    set -g @catppuccin_status_connect_separator "no"
    set -g @catppuccin_status_right_separator "${rightSep}"

    # Directory module config
    set -g @catppuccin_directory_text " #{b:pane_current_path}"
    set -g @catppuccin_directory_icon "#(~/.config/tmux/scripts/dir-icon.sh '#{pane_current_path}')"
    set -g @catppuccin_directory_color "#(~/.config/tmux/scripts/dir-color.sh '#{pane_current_path}')"

    # Meeting pill config (repurposes date_time module)
    set -g @catppuccin_date_time_text "#(~/.config/tmux/scripts/meeting.sh text)"
    set -g @catppuccin_date_time_color "#(~/.config/tmux/scripts/meeting.sh color)"
    set -g @catppuccin_date_time_icon "#(~/.config/tmux/scripts/meeting.sh icon)"
  '';

  layout = ''
    set -g status-position top
    set -g status-justify right
    set -g status-left-length 100
    set -g status-right-length 100
  '';

  pills = {
    directory = "#{E:@catppuccin_status_directory} ";
    gitmux = "#(cat /tmp/tmux-gitmux-#{pane_id} 2>/dev/null) ";
    starship = "#(cat /tmp/tmux-starship-#{pane_id} 2>/dev/null)";
    meeting = " #{E:@catppuccin_status_date_time}";
  };
}
