#!/usr/bin/env bash
# git-worktree-sync: Pull latest and report stale branches across all worktrees
#
# Usage:
#   git-worktree-sync              # uses current directory
#   git-worktree-sync /path/to/repo
#   git-worktree-sync --all        # syncs all bare repos under ~/Work/boddle-projects

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Find the bare repo root from a path inside a worktree or bare repo
find_bare_root() {
  local dir="$1"

  # Direct bare repo (contains .bare/)
  if [[ -d "$dir/.bare" ]]; then
    echo "$dir"
    return 0
  fi

  # Walk up to find a parent with .bare/
  local check="$dir"
  while [[ "$check" != "/" ]]; do
    if [[ -d "$check/.bare" ]]; then
      echo "$check"
      return 0
    fi
    check="$(dirname "$check")"
  done

  return 1
}

sync_repo() {
  local repo_root="$1"
  local bare_dir="$repo_root/.bare"
  local repo_name
  repo_name="$(basename "$repo_root")"

  if [[ ! -d "$bare_dir" ]]; then
    echo -e "${RED}Not a bare-repo layout: $repo_root${RESET}"
    return 1
  fi

  echo -e "\n${BOLD}${CYAN}=== $repo_name ===${RESET}"
  echo -e "${DIM}$repo_root${RESET}\n"

  # Fetch with prune
  echo -e "${DIM}Fetching remote...${RESET}"
  if ! git -C "$bare_dir" fetch --prune --quiet 2>&1; then
    echo -e "${RED}  Failed to fetch remote${RESET}"
    return 1
  fi

  # Get worktree list
  local worktrees
  worktrees=$(git -C "$bare_dir" worktree list --porcelain)

  local wt_path="" wt_branch="" wt_head=""
  local stale_count=0
  local updated_count=0
  local total_count=0

  while IFS= read -r line || [[ -n "$wt_path" ]]; do
    if [[ "$line" =~ ^worktree\ (.+) ]]; then
      wt_path="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^HEAD\ (.+) ]]; then
      wt_head="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+) ]]; then
      wt_branch="${BASH_REMATCH[1]}"
    elif [[ "$line" == "bare" ]]; then
      # Skip the bare entry itself
      wt_path="" wt_branch="" wt_head=""
      continue
    elif [[ -z "$line" && -n "$wt_path" ]]; then
      # End of a worktree block - process it
      ((total_count++)) || true

      local wt_dir
      wt_dir="$(basename "$(dirname "$wt_path")")/$(basename "$wt_path")"
      # Handle top-level worktrees (like main/)
      if [[ "$(dirname "$wt_path")" == "$repo_root" ]]; then
        wt_dir="$(basename "$wt_path")"
      fi

      if [[ -z "$wt_branch" ]]; then
        echo -e "  ${YELLOW}[detached]${RESET} $wt_dir ${DIM}@ ${wt_head:0:7}${RESET}"
        wt_path="" wt_branch="" wt_head=""
        continue
      fi

      # Check upstream tracking
      local upstream
      upstream=$(git -C "$bare_dir" for-each-ref --format='%(upstream:short)' "refs/heads/$wt_branch" 2>/dev/null)

      if [[ -z "$upstream" ]]; then
        echo -e "  ${YELLOW}[no remote]${RESET} $wt_dir ${DIM}($wt_branch)${RESET}"
        echo -e "    ${YELLOW}Branch has no upstream tracking${RESET}"
        ((stale_count++)) || true
        wt_path="" wt_branch="" wt_head=""
        continue
      fi

      # Check ahead/behind
      local ab
      ab=$(git -C "$bare_dir" rev-list --left-right --count "$wt_branch...$upstream" 2>/dev/null || echo "0 0")
      local ahead behind
      ahead=$(echo "$ab" | awk '{print $1}')
      behind=$(echo "$ab" | awk '{print $2}')

      local status_parts=()

      if [[ "$behind" -gt 0 && "$ahead" -gt 0 ]]; then
        # Diverged — try rebase to replay local commits on top of upstream
        if git -C "$wt_path" pull --rebase --quiet 2>/dev/null; then
          status_parts+=("${GREEN}rebased${RESET} ${DIM}(ahead $ahead, pulled $behind)${RESET}")
          ((updated_count++)) || true
        else
          git -C "$wt_path" rebase --abort 2>/dev/null || true
          status_parts+=("${YELLOW}diverged${RESET} ${DIM}(ahead $ahead, behind $behind — rebase failed)${RESET}")
          ((stale_count++)) || true
        fi
      elif [[ "$behind" -gt 0 ]]; then
        # Try fast-forward first, fall back to rebase
        if git -C "$wt_path" merge --ff-only "$upstream" --quiet 2>/dev/null; then
          status_parts+=("${GREEN}pulled${RESET} ${DIM}($behind commits)${RESET}")
          ((updated_count++)) || true
        elif git -C "$wt_path" pull --rebase --quiet 2>/dev/null; then
          status_parts+=("${GREEN}rebased${RESET} ${DIM}($behind commits)${RESET}")
          ((updated_count++)) || true
        else
          git -C "$wt_path" rebase --abort 2>/dev/null || true
          status_parts+=("${YELLOW}behind $behind${RESET} ${DIM}(rebase failed)${RESET}")
          ((stale_count++)) || true
        fi
      elif [[ "$ahead" -gt 0 ]]; then
        status_parts+=("${CYAN}ahead $ahead${RESET}")
      else
        status_parts+=("${GREEN}up to date${RESET}")
      fi

      # Check if remote branch was merged into main
      local main_branch="main"
      if git -C "$bare_dir" show-ref --verify --quiet "refs/heads/master" 2>/dev/null; then
        main_branch="master"
      fi

      if [[ "$wt_branch" != "$main_branch" ]]; then
        local remote_ref="refs/remotes/origin/$wt_branch"
        if ! git -C "$bare_dir" show-ref --verify --quiet "$remote_ref" 2>/dev/null; then
          status_parts+=("${RED}remote deleted${RESET}")
          ((stale_count++)) || true
        elif git -C "$bare_dir" merge-base --is-ancestor "$remote_ref" "refs/heads/$main_branch" 2>/dev/null; then
          status_parts+=("${RED}merged into $main_branch${RESET}")
          ((stale_count++)) || true
        fi
      fi

      local status_str
      status_str=$(IFS=', '; echo "${status_parts[*]}")
      echo -e "  [${status_str}] $wt_dir ${DIM}($wt_branch)${RESET}"

      wt_path="" wt_branch="" wt_head=""
    fi
  done <<< "$worktrees"

  # Process last entry if file didn't end with blank line
  if [[ -n "$wt_path" && -n "$wt_branch" ]]; then
    ((total_count++)) || true
    local wt_dir
    wt_dir="$(basename "$(dirname "$wt_path")")/$(basename "$wt_path")"
    if [[ "$(dirname "$wt_path")" == "$repo_root" ]]; then
      wt_dir="$(basename "$wt_path")"
    fi

    local upstream
    upstream=$(git -C "$bare_dir" for-each-ref --format='%(upstream:short)' "refs/heads/$wt_branch" 2>/dev/null)

    if [[ -z "$upstream" ]]; then
      echo -e "  ${YELLOW}[no remote]${RESET} $wt_dir ${DIM}($wt_branch)${RESET}"
      ((stale_count++)) || true
    else
      local ab
      ab=$(git -C "$bare_dir" rev-list --left-right --count "$wt_branch...$upstream" 2>/dev/null || echo "0 0")
      local ahead behind
      ahead=$(echo "$ab" | awk '{print $1}')
      behind=$(echo "$ab" | awk '{print $2}')

      if [[ "$behind" -gt 0 && "$ahead" -gt 0 ]]; then
        if git -C "$wt_path" pull --rebase --quiet 2>/dev/null; then
          echo -e "  [${GREEN}rebased${RESET} ${DIM}(ahead $ahead, pulled $behind)${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
          ((updated_count++)) || true
        else
          git -C "$wt_path" rebase --abort 2>/dev/null || true
          echo -e "  [${YELLOW}diverged${RESET} ${DIM}(ahead $ahead, behind $behind — rebase failed)${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
          ((stale_count++)) || true
        fi
      elif [[ "$behind" -gt 0 ]]; then
        if git -C "$wt_path" merge --ff-only "$upstream" --quiet 2>/dev/null; then
          echo -e "  [${GREEN}pulled${RESET} ${DIM}($behind commits)${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
          ((updated_count++)) || true
        elif git -C "$wt_path" pull --rebase --quiet 2>/dev/null; then
          echo -e "  [${GREEN}rebased${RESET} ${DIM}($behind commits)${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
          ((updated_count++)) || true
        else
          git -C "$wt_path" rebase --abort 2>/dev/null || true
          echo -e "  [${YELLOW}behind $behind${RESET} ${DIM}(rebase failed)${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
          ((stale_count++)) || true
        fi
      else
        echo -e "  [${GREEN}up to date${RESET}] $wt_dir ${DIM}($wt_branch)${RESET}"
      fi
    fi
  fi

  echo ""
  echo -e "  ${DIM}$total_count worktrees | ${GREEN}$updated_count pulled${RESET} ${DIM}| ${YELLOW}$stale_count stale${RESET}"
}

# Main
if [[ "${1:-}" == "--all" ]]; then
  base_dir="${2:-$PWD}"
  found=0
  for dir in "$base_dir"/*/; do
    if [[ -d "$dir/.bare" ]]; then
      sync_repo "${dir%/}"
      ((found++)) || true
    fi
  done
  if [[ "$found" -eq 0 ]]; then
    echo -e "${RED}No bare-repo layouts found in $base_dir${RESET}"
    exit 1
  fi
elif [[ -n "${1:-}" && "$1" != -* ]]; then
  repo_root=$(find_bare_root "$1")
  sync_repo "$repo_root"
else
  repo_root=$(find_bare_root "${PWD}")
  if [[ -z "$repo_root" ]]; then
    echo -e "${RED}Not inside a bare-repo worktree layout. Provide a path or use --all.${RESET}"
    exit 1
  fi
  sync_repo "$repo_root"
fi
