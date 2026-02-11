#!/usr/bin/env bash

# Catppuccin Mocha palette - function to get hex from name
get_pastel_color() {
  case "$1" in
    rosewater) echo "#f5e0dc" ;;
    flamingo)  echo "#f2cdcd" ;;
    pink)      echo "#f5c2e7" ;;
    mauve)     echo "#cba6f7" ;;
    red)       echo "#f38ba8" ;;
    maroon)    echo "#eba0ac" ;;
    peach)     echo "#fab387" ;;
    yellow)    echo "#f9e2af" ;;
    green)     echo "#a6e3a1" ;;
    teal)      echo "#94e2d5" ;;
    sky)       echo "#89dceb" ;;
    sapphire)  echo "#74c7ec" ;;
    blue)      echo "#89b4fa" ;;
    lavender)  echo "#b4befe" ;;
    *)         echo "" ;;
  esac
}

# Palette array for hash-based fallback
PASTEL_PALETTE=(
  "#f5e0dc" "#f2cdcd" "#f5c2e7" "#cba6f7"
  "#f38ba8" "#eba0ac" "#fab387" "#f9e2af"
  "#a6e3a1" "#94e2d5" "#89dceb" "#74c7ec"
  "#89b4fa" "#b4befe"
)

# Directory styles lookup - returns "icon|color-name" or empty
# Add custom entries here (user can edit)
get_dir_style() {
  local expanded="$1"
  case "$expanded" in
    # Examples (uncomment and edit) Order from most specific:
    "$HOME/dotfiles/nix"*) echo "󱄅|mauve" ;;
    "$HOME/dotfiles"*) echo "|mauve" ;;
    "$HOME/Personal/dory"*)  echo "󰈺|blue" ;;
    "$HOME/Personal"*)  echo "󰲋|blue" ;;
    "$HOME/Work"*)      echo "|sky" ;;  # default icon, sky color
    *) echo "" ;;
  esac
}
