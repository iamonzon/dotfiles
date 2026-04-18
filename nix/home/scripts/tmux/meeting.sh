#!/usr/bin/env bash
#
# Meeting pill for tmux status bar.
# Usage: meeting.sh {text|color|icon}
#
# Queries icalBuddy for calendar events and outputs one of three fields.
# Results are cached to avoid repeated queries within the same status refresh.
# Falls back to a clock display if icalBuddy is not installed.

set -euo pipefail

CACHE_FILE="/tmp/tmux-meeting-cache"
CACHE_MAX_AGE=30
MEETING_NAME_LEN=10

# Catppuccin Mocha palette
COLOR_RED="#f38ba8"
COLOR_GREEN="#a6e3a1"
COLOR_MUTED="#6c7086"
COLOR_SAPPHIRE="#74c7ec"

# Icons
ICON_CALENDAR=" "
ICON_CLEAR="✦ "
ICON_CLOCK="󰃰 "

refresh_cache() {
  local now_epoch now_hm
  now_epoch=$(date +%s)
  now_hm=$(date +%H:%M)

  local out_text out_color out_icon

  if ! command -v icalBuddy &>/dev/null; then
    out_text=$(date +" %H:%M, %A")
    out_color="$COLOR_SAPPHIRE"
    out_icon="$ICON_CLOCK"
    printf '%s\n%s\n%s\n' "$out_text" "$out_color" "$out_icon" > "$CACHE_FILE"
    return
  fi

  # Check for a meeting happening right now
  local current
  current=$(icalBuddy -n -nc -nrd -ea -b "" \
    -iep "title,datetime" -po "title,datetime" -df "" -tf "%H:%M" \
    eventsNow 2>/dev/null || true)

  if [[ -n "$current" ]]; then
    local title end_time
    title=$(echo "$current" | head -1 | xargs)
    title="${title:0:$MEETING_NAME_LEN}"
    end_time=$(echo "$current" | sed -n '2p' | grep -oE '[0-9]{2}:[0-9]{2}' | tail -1)

    if [[ -n "$end_time" ]]; then
      local end_epoch remaining
      end_epoch=$(date -j -f "%H:%M" "$end_time" +%s 2>/dev/null || echo "$now_epoch")
      remaining=$(( (end_epoch - now_epoch) / 60 ))
      (( remaining < 0 )) && remaining=0

      out_text=" ${title} ◀ ${remaining}m"
      out_color="$COLOR_RED"
      out_icon="$ICON_CALENDAR"
      printf '%s\n%s\n%s\n' "$out_text" "$out_color" "$out_icon" > "$CACHE_FILE"
      return
    fi
  fi

  # Check for upcoming meetings today
  local upcoming
  upcoming=$(icalBuddy -n -nc -nrd -ea -b "" \
    -iep "title,datetime" -po "title,datetime" -df "" -tf "%H:%M" \
    eventsToday 2>/dev/null || true)

  if [[ -n "$upcoming" ]]; then
    local next_title="" next_start="" found=0
    local current_title=""

    while IFS= read -r line; do
      if [[ "$line" =~ ([0-9]{2}:[0-9]{2})\ -\ ([0-9]{2}:[0-9]{2}) ]]; then
        local start_time="${BASH_REMATCH[1]}"
        if [[ "$start_time" > "$now_hm" ]]; then
          next_title="$current_title"
          next_start="$start_time"
          found=1
          break
        fi
        current_title=""
      else
        local trimmed
        trimmed=$(echo "$line" | xargs)
        [[ -n "$trimmed" ]] && current_title="$trimmed"
      fi
    done <<< "$upcoming"

    if (( found )); then
      local start_epoch minutes_until
      start_epoch=$(date -j -f "%H:%M" "$next_start" +%s 2>/dev/null || echo "$now_epoch")
      minutes_until=$(( (start_epoch - now_epoch) / 60 ))

      if (( minutes_until <= 120 )); then
        local trunc_title="${next_title:0:$MEETING_NAME_LEN}"
        out_text=" ${minutes_until}m ▶ ${trunc_title}"
        out_color="$COLOR_GREEN"
        out_icon="$ICON_CALENDAR"
        printf '%s\n%s\n%s\n' "$out_text" "$out_color" "$out_icon" > "$CACHE_FILE"
        return
      fi
    fi
  fi

  # Clear state — no meetings within 2 hours
  out_text=" clear"
  out_color="$COLOR_MUTED"
  out_icon="$ICON_CLEAR"
  printf '%s\n%s\n%s\n' "$out_text" "$out_color" "$out_icon" > "$CACHE_FILE"
}

# Refresh cache if stale or missing
if [[ -f "$CACHE_FILE" ]]; then
  cache_mtime=$(stat -f %m "$CACHE_FILE")
  now=$(date +%s)
  age=$(( now - cache_mtime ))
else
  age=$(( CACHE_MAX_AGE + 1 ))
fi

if (( age > CACHE_MAX_AGE )); then
  refresh_cache
fi

# Output the requested field
case "${1:-text}" in
  text)  sed -n '1p' "$CACHE_FILE" ;;
  color) sed -n '2p' "$CACHE_FILE" ;;
  icon)  sed -n '3p' "$CACHE_FILE" ;;
esac
