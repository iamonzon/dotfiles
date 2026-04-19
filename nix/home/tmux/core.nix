''
  # 256-color support for proper color rendering
  set -g default-terminal "tmux-256color"

  # True color support
  set -ag terminal-overrides ",xterm-256color:RGB"

  # From sensible (without broken reattach-to-user-namespace)
  set -g focus-events on
  set -g aggressive-resize on

  # Prevent automatic renaming from overriding manual names
  set-option -g automatic-rename off

  # Switch to another session instead of exiting when a session is destroyed
  set -g detach-on-destroy no-detached
''
