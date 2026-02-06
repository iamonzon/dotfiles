#!/usr/bin/env bash
path="$1"
dir=$(basename "$path")
config="$HOME/.config/tmux/directory-styles.conf"
color=""

# Check custom config for color override
if [[ -f "$config" ]]; then
  expanded_path="${path/#\~/$HOME}"
  while IFS='|' read -r cfg_path cfg_icon cfg_color || [[ -n "$cfg_path" ]]; do
    [[ "$cfg_path" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$cfg_path" ]] && continue
    cfg_path_expanded="${cfg_path/#\~/$HOME}"
    if [[ "$expanded_path" == "$cfg_path_expanded"* ]]; then
      [[ -n "$cfg_color" ]] && color="$cfg_color"
      break
    fi
  done < "$config"
fi

# Fallback: hash-based color from directory name
if [[ -z "$color" ]]; then
  char=$(printf '%d' "'${dir:0:1}" 2>/dev/null || echo 97)
  colors=("#f5e0dc" "#f2cdcd" "#f5c2e7" "#cba6f7" "#f38ba8" "#eba0ac" "#fab387" "#f9e2af" "#a6e3a1" "#94e2d5" "#89dceb" "#74c7ec" "#89b4fa" "#b4befe")
  idx=$((char % 14))
  color="${colors[$idx]}"
fi

echo "$color"
