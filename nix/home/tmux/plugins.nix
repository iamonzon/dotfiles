{ pkgs, continuumSaveInterval, catppuccinConfig }:

with pkgs.tmuxPlugins; [
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
]
