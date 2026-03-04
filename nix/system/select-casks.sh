#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_FILE="$SCRIPT_DIR/homebrew-casks-default.json"
LOCAL_FILE="$SCRIPT_DIR/homebrew-casks-local.json"

if [ -f "$LOCAL_FILE" ]; then
  echo "Using existing cask selections ($LOCAL_FILE)"
  echo "Delete the file and re-run to re-select."
  exit 0
fi

CASKS=$(jq -r 'keys[]' "$DEFAULT_FILE")

if command -v gum &>/dev/null; then
  SELECTED=$(echo "$CASKS" | gum choose --no-limit \
    --header "Select optional Homebrew casks to install:" \
    --cursor-prefix "[ ] " --selected-prefix "[x] " --unselected-prefix "[ ] " \
    || true)
else
  SELECTED=""
  for cask in $CASKS; do
    read -rp "  Install $cask? [y/N] " answer
    [[ "$answer" =~ ^[Yy] ]] && SELECTED="$SELECTED $cask"
  done
fi

# Build JSON
echo "{" > "$LOCAL_FILE"
FIRST=true
for cask in $CASKS; do
  $FIRST && FIRST=false || echo "," >> "$LOCAL_FILE"
  if echo "$SELECTED" | grep -qw "$cask"; then
    printf '  "%s": true' "$cask" >> "$LOCAL_FILE"
  else
    printf '  "%s": false' "$cask" >> "$LOCAL_FILE"
  fi
done
echo "" >> "$LOCAL_FILE"
echo "}" >> "$LOCAL_FILE"

echo "Selections saved to $LOCAL_FILE"
