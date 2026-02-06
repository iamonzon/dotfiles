{ pkgs, ... }:

let
  # ====================
  # Variables
  # ====================

  # Powerline rounded right separator (U+E0B4) - encoded to survive formatters
  rightSep = builtins.fromJSON ''"\ue0b4"'';

  # Theme configuration
  theme = "mocha";
  windowStatusStyle = "rounded";

  # Timing and sizing
  resizeAmount = 5;
  continuumSaveInterval = 15;
  dateTimeFormat = "%H:%M";

  # ====================
  # Config Sections
  # ====================

  catppuccinConfig = ''
    # Theme
    set -g @catppuccin_flavor "${theme}"

    # Window styling
    set -g @catppuccin_window_status_style "${windowStatusStyle}"
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

    # Date/time module config (24h format)
    set -g @catppuccin_date_time_text "${dateTimeFormat}"
  '';

  coreConfig = ''
    # True color support
    set -ag terminal-overrides ",xterm-256color:RGB"

    # From sensible (without broken reattach-to-user-namespace)
    set -g focus-events on
    set -g aggressive-resize on

    # Prevent automatic renaming from overriding manual names
    set-option -g automatic-rename off
  '';

  themeConfig = ''
    # Status bar position
    set -g status-position top
    set -g status-justify right  # Push window list to right

    # LEFT: dirname, git status
    set -g status-left "#{E:@catppuccin_status_directory} "
    set -ag status-left "#(gitmux -cfg ~/.config/gitmux/.gitmux.conf \"#{pane_current_path}\")"
    set -g status-left-length 100

    # RIGHT: session, time (window list auto-positioned before this)
    set -g status-right " #{E:@catppuccin_status_session}"
    set -ag status-right " "
    set -ag status-right "#{E:@catppuccin_status_date_time}"
  '';

  keybindingsConfig = ''
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
  '';

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
        extraConfig = catppuccinConfig;
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
          set -g @continuum-save-interval '${toString continuumSaveInterval}'
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
      # Extract URLs from pane and open with fzf picker (prefix + u)
      fzf-tmux-url
    ];
    extraConfig = ''
      ${coreConfig}
      ${themeConfig}
      ${keybindingsConfig}

      # Hot-reload experimental config (create ~/.config/tmux/experimental.conf to use)
      source-file -q ~/.config/tmux/experimental.conf
    '';
  };
}
