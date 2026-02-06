#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/dir-lookup-table.sh"

path="$1"
dir=$(basename "$path")
expanded="${path/#\~/$HOME}"
color=""

# Check lookup table for color
style=$(get_dir_style "$expanded")
if [[ -n "$style" ]]; then
  IFS='|' read -r _ color_name <<< "$style"
  [[ -n "$color_name" ]] && color=$(get_pastel_color "$color_name")
fi

# Fallback: hash-based color from directory name
if [[ -z "$color" ]]; then
  char=$(printf '%d' "'${dir:0:1}" 2>/dev/null || echo 97)
  idx=$((char % ${#PASTEL_PALETTE[@]}))
  color="${PASTEL_PALETTE[$idx]}"
fi

echo "$color"
