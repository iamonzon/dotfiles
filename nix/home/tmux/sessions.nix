{ maxSessionNameLen, ... }:

{
  catppuccinConfig = ''
    # Session module config (truncate long names)
    set -g @catppuccin_session_text " #{=${toString maxSessionNameLen}:session_name}"
  '';

  pill = " #{E:@catppuccin_status_session}";

  keybindings = ''
    # New session (Alt+Shift+N)
    bind -n M-N command-prompt -p "Session name:" "new-session -s '%%'"

    # Rename session (Alt+Shift+R)
    bind -n M-R command-prompt -I "#S" "rename-session '%%'"

    # Kill session (Alt+Shift+W)
    bind -n M-W confirm-before -p "Kill session #S? (y/n)" kill-session

    # Detach client (Alt+Shift+D)
    bind -n M-D detach-client

    # Switch to session by number (Alt+Shift+1-9)
    bind -n M-! run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 1p)\""
    bind -n M-@ run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 2p)\""
    bind -n 'M-#' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 3p)\""
    bind -n 'M-$' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 4p)\""
    bind -n 'M-%' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 5p)\""
    bind -n 'M-^' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 6p)\""
    bind -n 'M-&' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 7p)\""
    bind -n 'M-*' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 8p)\""
    bind -n 'M-(' run-shell "tmux switch-client -t \"$(tmux list-sessions -F '#S' | sed -n 9p)\""
  '';
}
