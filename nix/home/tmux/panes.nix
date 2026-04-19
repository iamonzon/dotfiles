{ resizeAmount, ... }:

{
  keybindings = ''
    # Pane splitting (Ctrl+Alt+j/l)
    bind -n C-M-j split-window -v -c "#{pane_current_path}"
    bind -n C-M-l split-window -h -c "#{pane_current_path}"

    # Pane resizing (Alt+Shift+h/j/k/l)
    bind -n M-H resize-pane -L ${toString resizeAmount}
    bind -n M-J resize-pane -D ${toString resizeAmount}
    bind -n M-K resize-pane -U ${toString resizeAmount}
    bind -n M-L resize-pane -R ${toString resizeAmount}

    # Maximize pane toggle (Ctrl+Alt+x)
    bind -n C-M-x resize-pane -Z

    # Close pane (Ctrl+w)
    bind -n C-w kill-pane
  '';
}
