#!/usr/bin/env bash
# Outputs starship modules with tmux-native colors matching starship defaults

# Map starship style colors to catppuccin mocha hex
get_module_color() {
  case "$1" in
    nix_shell)      echo "#74c7ec" ;;  # sapphire (starship: bold blue)
    direnv)         echo "#f9e2af" ;;  # yellow (starship: bold yellow)
    package)        echo "#fab387" ;;  # peach (starship: bold 208)
    nodejs)         echo "#a6e3a1" ;;  # green (starship: bold green)
    python)         echo "#f9e2af" ;;  # yellow (starship: bold yellow)
    rust)           echo "#f38ba8" ;;  # red (starship: bold red)
    docker_context) echo "#74c7ec" ;;  # sapphire (starship: bold blue)
    golang)         echo "#89dceb" ;;  # sky (starship: bold cyan)
    ruby)           echo "#f38ba8" ;;  # red (starship: bold red)
    *)              echo "#cdd6f4" ;;  # text (default)
  esac
}

ANSI_STRIP_PATTERN='s/\x1b\[[0-9;]*m//g'
MODULES=(nix_shell direnv package nodejs python rust docker_context golang ruby)

strip_ansi_codes() {
  sed "$ANSI_STRIP_PATTERN"
}

get_module_output() {
  starship module "$1" 2>/dev/null | strip_ansi_codes
}

has_content() {
  [[ "$1" =~ [^[:space:]] ]]
}

format_for_tmux() {
  local color="$1"
  local content="$2"
  printf "#[fg=%s]%s#[fg=default]" "$color" "$content"
}

for module in "${MODULES[@]}"; do
  output=$(get_module_output "$module")
  if has_content "$output"; then
    color=$(get_module_color "$module")
    format_for_tmux "$color" "$output"
  fi
done
