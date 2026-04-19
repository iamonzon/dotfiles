#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/dir-lookup-table.sh"

path="$1"
expanded="${path/#\~/$HOME}"
icon=" "  # default: folder icon

# Check lookup table for icon
style=$(get_dir_style "$expanded")
if [[ -n "$style" ]]; then
  IFS='|' read -r cfg_icon _ <<< "$style"
  [[ -n "$cfg_icon" ]] && icon="$cfg_icon "
fi

echo "$icon"
