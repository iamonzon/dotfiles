{ pkgs, ... }:

let
  # Powerline rounded right separator (U+E0B4) - encoded to survive formatters
  rightSep = builtins.fromJSON ''"\ue0b4"'';
in
{
  # Tmux terminal multiplexer
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    prefix = "C-Space";
    historyLimit = 10000;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          # Theme
          set -g @catppuccin_flavor "mocha"

          # Window styling
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_number_position "right"

          # Window text and number format
          set -g @catppuccin_window_text "#W"
          set -g @catppuccin_window_number "#I"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_window_current_number "#I"

          # Status module separators (pill shape)
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_status_right_separator "${rightSep}"

          # Directory module config
          set -g @catppuccin_directory_text "#{b:pane_current_path}"
        '';
      }
      # Session persistence
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      # Clipboard integration
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection_mouse 'clipboard'
        '';
      }
      # Seamless vim/tmux navigation
      vim-tmux-navigator
    ];
    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Status bar position (must be set separately, catppuccin doesn't control this)
      set -g status-position top

      # Status bar modules
      set -g status-left "#{E:@catppuccin_status_session} "
      set -g status-left-length 50
      set -g status-right "#{E:@catppuccin_status_directory}"

      # Hide non-current windows from status bar (keep only current visible)
      set -g window-status-format ""

      # From sensible (without broken reattach-to-user-namespace)
      set -g focus-events on
      set -g aggressive-resize on

      # Prevent automatic renaming from overriding manual names
      set-option -g automatic-rename off

      # Pane splitting (Ctrl+Alt+j/l)
      bind -n C-M-j split-window -v -c "#{pane_current_path}"
      bind -n C-M-l split-window -h -c "#{pane_current_path}"

      # Pane resizing (Alt+Shift+h/j/k/l)
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # Maximize pane toggle (Ctrl+Alt+x)
      bind -n C-M-x resize-pane -Z

      # Close pane (Ctrl+w)
      bind -n C-w kill-pane

      # Close window (Alt+w)
      bind -n M-w kill-window

      # Window navigation (Alt+j/k)
      bind -n M-k previous-window
      bind -n M-j next-window

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

      # Rename window (Alt+r)
      bind -n M-r command-prompt -I "#W" "rename-window '%%'"

      # Session management (Alt+Shift+key)
      bind -n M-N command-prompt -p "Session name:" "new-session -s '%%'"
      bind -n M-R command-prompt -I "#S" "rename-session '%%'"
      bind -n M-W confirm-before -p "Kill session #S? (y/n)" kill-session
      bind -n M-D detach-client

      # Copy mode improvements
      bind k copy-mode
      bind C-Space if-shell -F '#{pane_in_mode}' 'send-keys -X cancel' 'copy-mode'
      bind -T copy-mode-vi Escape send-keys -X cancel
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # New window keeps current path
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
