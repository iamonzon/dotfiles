''
  # Copy mode improvements
  bind k copy-mode
  bind C-Space if-shell -F '#{pane_in_mode}' 'send-keys -X cancel' 'copy-mode'
  bind -T copy-mode-vi Escape send-keys -X cancel
  bind -T copy-mode-vi v send-keys -X begin-selection
  bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

  # Reload config (prefix + r)
  bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

  # Toggle floating scratch terminal (Alt+`)
  # Session persists between toggles - work is never lost
  bind -n M-\` if-shell -F '#{==:#{session_name},scratch}' {
    detach-client
  } {
    display-popup -E -w 80% -h 80% -b rounded -d "#{pane_current_path}" \
      'tmux new-session -A -s scratch -c "#{pane_current_path}"'
  }

  # Fuzzy file finder (prefix + Ctrl+f)
  bind C-f send-keys ' fe' Enter

  # Fuzzy live grep (prefix + Ctrl+g)
  bind C-g send-keys ' ge' Enter

  # New window keeps current path
  bind c new-window -c "#{pane_current_path}"
''
