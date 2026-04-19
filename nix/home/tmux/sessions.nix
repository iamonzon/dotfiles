{ maxSessionNameLen, ... }:

{
  catppuccinConfig = ''
    # Session module config (truncate long names)
    set -g @catppuccin_session_text " #{=${toString maxSessionNameLen}:session_name}"
  '';

  pill = " #{E:@catppuccin_status_session}";

  keybindings = ''
    # Session navigation (Alt+j/k)
    bind -n M-k switch-client -p
    bind -n M-j switch-client -n

    # Kill session (Alt+w)
    bind -n M-w confirm-before -p "Kill session #S? (y/n)" kill-session

    # List sessions (Alt+l)
    bind -n M-l choose-tree -Zs

    # New session (Alt+n)
    bind -n M-n command-prompt -p "Session name:" "new-session -s '%%'"

    # Rename session (Alt+r)
    bind -n M-r command-prompt -I "#S" "rename-session '%%'"

    # Detach client (Alt+Shift+D)
    bind -n M-D detach-client

  '';
}
