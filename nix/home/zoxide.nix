{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide autojump and highlighting for zsh
  programs.zsh.initContent = lib.mkAfter ''
    # Use zoxide for unknown commands (type "dot" to jump to ~/.dotfiles)
    zoxide-autojump() {
      local cmd="$BUFFER"
      # Skip if empty, contains spaces (has args), or starts with special chars
      if [[ -z "$cmd" || "$cmd" == *" "* || "$cmd" == .* || "$cmd" == /* ]]; then
        zle accept-line
        return
      fi
      # Check if it's a valid command/alias/function
      if command -v "$cmd" &>/dev/null || alias "$cmd" &>/dev/null || type "$cmd" &>/dev/null 2>&1; then
        zle accept-line
        return
      fi
      # Try zoxide
      local dir
      dir=$(zoxide query --exclude "$PWD" -- "$cmd" 2>/dev/null)
      if [[ -n "$dir" ]]; then
        BUFFER="cd $dir"
      fi
      zle accept-line
    }
    zle -N zoxide-autojump
    bindkey '^M' zoxide-autojump

    # Highlight valid zoxide matches like valid commands
    _zoxide_highlight() {
      local cmd="''${BUFFER%% *}"
      # Skip if empty, has spaces, or is already a valid command
      [[ -z "$cmd" || "$cmd" == *" "* ]] && return
      type "$cmd" &>/dev/null && return
      # Check zoxide and highlight in green if match found
      if zoxide query --exclude "$PWD" -- "$cmd" &>/dev/null 2>&1; then
        region_highlight+=("0 ''${#cmd} fg=green,bold")
      fi
    }
    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget line-pre-redraw _zoxide_highlight
  '';
}
