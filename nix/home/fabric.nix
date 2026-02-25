{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    fabric-ai
    glow
  ];

  programs.zsh.initContent = lib.mkAfter ''
    # ── Fabric AI commands ───────────────────────────────────────────

    # Helper: run fabric with spinner, render through glow + less
    #   Usage: _fabric_render <input_file|""> [fabric args...]
    _fabric_render() {
      setopt local_options no_monitor
      local input_file="$1"; shift
      local tmpout
      tmpout=$(mktemp)

      # Spinner in background
      ( while true; do
          for c in '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'; do
            printf "\r  %s Thinking..." "$c"
            sleep 0.1
          done
        done ) &
      local spinner_pid=$!

      # Fabric in FOREGROUND — reliable output capture
      if [[ -n "$input_file" && -f "$input_file" ]]; then
        fabric "$@" < "$input_file" > "$tmpout" 2>&1
      else
        fabric "$@" > "$tmpout" 2>&1
      fi

      # Kill spinner, clear line
      kill "$spinner_pid" 2>/dev/null
      wait "$spinner_pid" 2>/dev/null
      printf "\r\033[K"

      # Render
      glow -w 80 - < "$tmpout" | less -R
      rm -f "$tmpout"
    }

    # f — Quick fabric with glow + auto-sessions
    #   Usage: f -p <pattern> [fabric args...]
    #          echo "text" | f -p <pattern>
    #          f -s <session> -p <pattern>   (resume session)
    f() {
      local -a args=("$@")
      local session="" pattern="" has_session=false
      local i=1

      # Parse args to find -s and -p values
      while (( i <= $#args )); do
        case "''${args[$i]}" in
          -s)
            has_session=true
            session="''${args[$((i+1))]}"
            ((i+=2))
            ;;
          -p)
            pattern="''${args[$((i+1))]}"
            ((i+=2))
            ;;
          *)
            ((i++))
            ;;
        esac
      done

      # Auto-generate session name if not resuming
      if ! $has_session; then
        local ts
        ts=$(date +%Y%m%d-%H%M%S)
        session="''${ts}-''${pattern:-unnamed}"
        args+=(--session="$session")
      fi

      # Capture input (editor or pipe) into tmpfile
      local tmpfile
      tmpfile=$(mktemp)
      if [[ -t 0 ]]; then
        ''${EDITOR:-nvim} "$tmpfile"
        if [[ ! -s "$tmpfile" ]]; then
          echo "Aborted: empty input." >&2
          rm -f "$tmpfile"
          return 1
        fi
      else
        cat > "$tmpfile"
      fi

      _fabric_render "$tmpfile" "''${args[@]}"
      rm -f "$tmpfile"
      echo "Session: $session"
    }

    # ff — Interactive pattern/strategy picker
    ff() {
      local pattern strategy tmpfile

      # Pick pattern
      pattern=$(fabric --listpatterns | fzf \
        --header="Pick a pattern (ESC to cancel)" \
        --preview 'bat --style=plain --color=always ~/.config/fabric/patterns/{1}/system.md 2>/dev/null || echo "No system.md found"' \
        --preview-window=right:60%:wrap | awk '{print $1}')
      [[ -n "$pattern" ]] || return

      # Pick strategy (optional — ESC to skip)
      strategy=$(fabric --liststrategies 2>/dev/null | fzf \
        --header="Pick a strategy (ESC to skip)" \
        --preview-window=right:60%:wrap | awk '{print $1}' || true)

      # Open editor for the question
      tmpfile=$(mktemp)
      ''${EDITOR:-nvim} "$tmpfile"
      if [[ ! -s "$tmpfile" ]]; then
        echo "Aborted: empty input." >&2
        rm -f "$tmpfile"
        return 1
      fi

      # Build command
      local ts
      ts=$(date +%Y%m%d-%H%M%S)
      local session="''${ts}-''${pattern}"
      local -a cmd=(--session="$session" -p "$pattern")
      [[ -n "$strategy" ]] && cmd+=(--strategy="$strategy")

      _fabric_render "$tmpfile" "''${cmd[@]}"
      rm -f "$tmpfile"
      echo "Session: $session"
    }

    # fs — Session search with fzf preview
    fs() {
      local session
      session=$(fabric --listsessions | fzf \
        --header="Pick a session" \
        --preview 'fabric --printsession={1}' \
        --preview-window=right:60%:wrap | awk '{print $1}')
      [[ -n "$session" ]] || return
      fabric --printsession="$session" | glow -w 80 - | less -R
    }

    # fl — List sessions
    fl() { fabric --listsessions; }

    # fp — List patterns
    fp() { fabric --listpatterns; }
  '';
}
