{ windowStatusStyle, ... }:

{
  catppuccinConfig = ''
    # Window styling
    set -g @catppuccin_window_status_style "${windowStatusStyle}"
    set -g @catppuccin_window_number_position "right"

    # Window text and number format
    set -g @catppuccin_window_text "#W"
    set -g @catppuccin_window_number "#I"
    set -g @catppuccin_window_current_text "#W"
    set -g @catppuccin_window_current_number "#I"
  '';

  keybindings = ''
    # Window navigation (Alt+j/k)
    bind -n M-k previous-window
    bind -n M-j next-window

    # Close window (Alt+w)
    bind -n M-w kill-window

    # List windows (Alt+l)
    bind -n M-l choose-tree -Zw

    # New window (Alt+n) - prompts for window name
    bind -n M-n command-prompt -p "Window name:" "new-window -c '#{pane_current_path}' -n '%%'"

    # Switch to window by number (Alt+1-9)
    bind -n M-1 select-window -t 1
    bind -n M-2 select-window -t 2
    bind -n M-3 select-window -t 3
    bind -n M-4 select-window -t 4
    bind -n M-5 select-window -t 5
    bind -n M-6 select-window -t 6
    bind -n M-7 select-window -t 7
    bind -n M-8 select-window -t 8
    bind -n M-9 select-window -t 9

    # Rename window (Alt+r)
    bind -n M-r command-prompt -I "#W" "rename-window '%%'"
  '';
}
