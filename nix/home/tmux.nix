{ pkgs, ... }:

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

          # Window styling - only basic/rounded/slanted/none are valid
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_number_position "right"

          # Directory module config
          set -g @catppuccin_directory_text "#{pane_current_path}"

          # Window text - show window name
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"
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
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_directory}"
      set -ag status-right "#{E:@catppuccin_status_session}"

      # Hide non-current windows from status bar (keep only current visible)
      set -g window-status-format ""

      # From sensible (without broken reattach-to-user-namespace)
      set -g focus-events on
      set -g aggressive-resize on

      # Prevent automatic renaming from overriding manual names
      set-option -g automatic-rename off
      bind C-p previous-window
      bind C-n next-window

      # Scrolling (vim-style) - enters copy-mode if needed
      bind -n M-u copy-mode \; send-keys -X halfpage-up
      bind -n M-d copy-mode \; send-keys -X halfpage-down

      # Pane splitting (Alt+Ctrl+j/l)
      bind -n M-C-j split-window -v -c "#{pane_current_path}"
      bind -n M-C-l split-window -h -c "#{pane_current_path}"

      # Pane resizing (Ctrl+Shift+h/j/k/l)
      bind -n C-H resize-pane -L 5
      bind -n C-J resize-pane -D 5
      bind -n C-K resize-pane -U 5
      bind -n C-L resize-pane -R 5

      # Maximize pane toggle (Alt+Ctrl+x)
      bind -n M-C-x resize-pane -Z

      # Close pane (Ctrl+w)
      bind -n C-w kill-pane

      # Close window (Alt+w)
      bind -n M-w kill-window

      # Window navigation (Alt+h/l)
      bind -n M-H previous-window
      bind -n M-L next-window

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

      # Copy mode improvements
      bind v copy-mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # New window keeps current path
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
