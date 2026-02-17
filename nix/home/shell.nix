{ pkgs, lib, ... }:

{
  imports = [
    ./zoxide.nix
  ];

  programs.zsh = {
    enable = true;

    history = {
      size = 500000;
      save = 500000;
      path = "$HOME/.zsh_history";
    };

    # .zprofile content - survives macOS major upgrades (unlike /etc/zshrc)
    profileExtra = ''
      # Nix daemon
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      fi

      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Python 3.10
      PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:''${PATH}"
      export PATH

      # Coursier
      export PATH="$PATH:/Users/ivan/Library/Application Support/Coursier/bin"
    '';

    shellAliases = {
      # Make aliases sudo-able
      sudo = "sudo ";

      # Quick shortcuts
      y = "yazi";
      v = "nvim";
      d = "docker";
      b = "bat";
      g = "git";
      t = "tree";
      c = "claude";

      # Claude dangerous mode
      cdsp = "claude --dangerously-skip-permissions";

      # Fabric AI patterns
      f = "fabric";
      fp = "fabric --list";

      # Home Manager
      tks = "tmux kill-server";

      # Delete directories
      rmd = "rm -rf";
      cls = "clear";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # Neovim
      vi = "nvim";
      vim = "nvim";

      # List (lsd with icons)
      ls = "lsd";
      l = "lsd -a --blocks date,size,name --date '+%Y%m%d-%H:%M'";
      la = "lsd -a";
      ll = "lsd -la"; # Full info
      lf = "lsd -aF";
      lt = "lsd --tree --depth 2";

      # Git shortcuts
      ga = "git add";
      gc = "git commit";
      gb = "git branch";
      gd = "git diff";
      gco = "git checkout";
      gp = "git push";
      gpm = "git push origin master";
      gl = "git log";
      gt = "git tag";
      gm = "git merge";
      glog = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ggstat = "git log --graph --pretty=format:'%C(bold red)%h%Creset -%C(bold yellow)%d%Creset %s %C(bold green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --stat";
      gcp = "git cherry-pick";

      # Git utilities
      gff = "git flow feature";
      gfh = "git flow hotfix";
      gfr = "git flow release";

      # Git bisect
      gbg = "git bisect good";
      gbb = "git bisect bad";

      # Grep with color
      grep = "grep --color=auto";

      # Useful lists
      lsg = "git status";
      dps = "docker ps";

      # Directory shortcuts
      workspace = "cd ~/Work";
      personalspace = "cd ~/Personal";
      pp = "cd ~/Personal/Projects/";
      wp = "cd ~/Work/Projects/";
      tp = "cd ~/Personal/Projects/tooling/";
      # dot = "cd ~/dotfiles/";

      # Tools
      obsidian = ''open -a "Obsidian"'';

      timestamp = "date +%s";
    };

    # Powerlevel10k and syntax plugins
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Enable Powerlevel10k instant prompt (must be at top)
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        # Auto-start tmux (attach existing or prompt for new session name)
        if [[ -z "$TMUX" ]] && command -v tmux &> /dev/null && [[ $- == *i* ]]; then
          if ! tmux attach-session 2>/dev/null; then
            read "name?New tmux session name: "
            tmux new-session -s "''${name:-default}"
          fi
        fi

        # Custom functions
        # Remove any legacy alias so the function always wins.
        unalias hms 2>/dev/null || true

        # Usage:
        #   hms                         -> uses <root>/master/nix, then <root>/nix
        #   hms feat/kitty-integration  -> uses <root>/feat/kitty-integration/nix
        #   hms --dry-run               -> default path with extra home-manager flags
        #   hms feat/kitty-integration --dry-run
        #
        # Root search order:
        #   1) $DOTFILES_PATH (if set)
        #   2) ~/dotfiles
        #   3) ~/.dotfiles
        #
        # On successful switch, this updates:
        #   <root>/current -> selected worktree
        hms() {
          local -a roots checked_paths
          local -A seen_roots
          local root
          local dotfiles_root=""
          local worktree_path=""
          local flake_path=""
          local current_link=""

          [[ -n "''${DOTFILES_PATH:-}" ]] && roots+=("''${DOTFILES_PATH:A}")
          roots+=("$HOME/dotfiles" "$HOME/.dotfiles")

          local -a unique_roots
          for root in "''${roots[@]}"; do
            [[ -n "$root" ]] || continue
            root="''${root:A}"
            [[ -d "$root" ]] || continue
            [[ -n "''${seen_roots[$root]}" ]] && continue
            seen_roots[$root]=1
            unique_roots+=("$root")
          done
          roots=("''${unique_roots[@]}")

          if [[ ''${#roots[@]} -eq 0 ]]; then
            echo "hms: no dotfiles root found. Checked DOTFILES_PATH, ~/dotfiles and ~/.dotfiles" >&2
            return 1
          fi

          dotfiles_root="''${roots[1]}"
          current_link="$dotfiles_root/current"

          if [[ $# -gt 0 && "$1" != -* ]]; then
            local worktree_name="$1"
            for root in "''${roots[@]}"; do
              checked_paths+=("$root/$worktree_name/nix")
              if [[ -d "$root/$worktree_name/nix" ]]; then
                worktree_path="$root/$worktree_name"
                break
              fi
            done

            if [[ -z "$worktree_path" && -d "$worktree_name/nix" ]]; then
              worktree_path="$worktree_name"
              checked_paths+=("$worktree_name/nix")
            fi

            if [[ -n "$worktree_path" ]]; then
              shift
            else
              echo "hms: worktree '$worktree_name' not found. Checked:" >&2
              printf '  - %s\n' "''${checked_paths[@]}" >&2
              return 1
            fi
          fi

          if [[ -z "$worktree_path" ]]; then
            for root in "''${roots[@]}"; do
              checked_paths+=("$root/master/nix")
              if [[ -d "$root/master/nix" ]]; then
                worktree_path="$root/master"
                break
              fi
            done

            if [[ -z "$worktree_path" ]]; then
              for root in "''${roots[@]}"; do
                checked_paths+=("$root/nix")
                if [[ -d "$root/nix" ]]; then
                  worktree_path="$root"
                  break
                fi
              done
            fi

            if [[ -z "$worktree_path" ]]; then
              echo "hms: nix flake not found. Checked:" >&2
              printf '  - %s\n' "''${checked_paths[@]}" >&2
              return 1
            fi
          fi

          # Use zsh path expansion to avoid triggering chpwd hooks (auto_ls).
          worktree_path="''${worktree_path:A}"
          flake_path="$worktree_path/nix"

          home-manager switch --flake "$flake_path#ivan" "$@" |& nom
          local hm_status=$?
          if [[ $hm_status -ne 0 ]]; then
            return $hm_status
          fi

          mkdir -p "$dotfiles_root"
          ln -sfn "$worktree_path" "$current_link"
          export DOTFILES_CURRENT="$current_link"
          echo "hms: active worktree -> $worktree_path"
        }
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # Fuzzy find file -> open in editor (Enter) or cd to folder (Ctrl+O)
        fe() {
          local result key file
          result=$(fzf --preview "bat --style=numbers --color=always --line-range :500 {}" \
              --preview-window=right:60% \
              --expect=ctrl-o)

          if [[ -n "$result" ]]; then
            key=$(head -1 <<< "$result")
            file=$(tail -n +2 <<< "$result")

            if [[ "$key" == "ctrl-o" ]]; then
              cd "$(dirname "$file")"
            elif [[ -n "$file" ]]; then
              $EDITOR "$file"
            fi
          fi
        }

        # Fuzzy live grep -> open in editor at line
        ge() {
          rg --line-number --no-heading --color=always --smart-case "" 2>/dev/null | \
            fzf --ansi --disabled \
              --bind "change:reload:rg --line-number --no-heading --color=always --smart-case {q} 2>/dev/null || true" \
              --delimiter : \
              --preview "bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null" \
              --preview-window=right:60%:+{2}-5 \
              --bind "enter:become($EDITOR +{2} {1})"
        }

        # Edit command line in $EDITOR (Ctrl+X Ctrl+X)
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^X^x' edit-command-line

        # Undo/Redo keybindings
        bindkey '^X^-' undo   # Ctrl+X Ctrl+- to undo
        bindkey '^X^=' redo   # Ctrl+X Ctrl+= to redo

        # Accept autosuggestion
        bindkey '^e' autosuggest-accept

        # PWD hooks using add-zsh-hook
        autoload -Uz add-zsh-hook

        function auto_ls() {
          lsd -aF
        }

        function auto_venv() {
          # Deactivate if we've left the venv directory
          if [[ -n "$VIRTUAL_ENV" && "$PWD" != *"''${VIRTUAL_ENV:h}"* ]]; then
            deactivate
            return
          fi
          # Skip if already in a venv
          [[ -n "$VIRTUAL_ENV" ]] && return

          # Walk up to find .venv
          local dir="$PWD"
          while [[ "$dir" != "/" ]]; do
            if [[ -f "$dir/.venv/bin/activate" ]]; then
              source "$dir/.venv/bin/activate"
              return
            fi
            dir="''${dir:h}"
          done
        }

        function auto_nvm() {
          [[ -f .nvmrc ]] && command -v nvm &>/dev/null && nvm use
        }

        add-zsh-hook chpwd auto_ls
        add-zsh-hook chpwd auto_venv
        add-zsh-hook chpwd auto_nvm

        # Cache gitmux and starship for tmux status bar
        # precmd: works when split panes, syncs both updates together
        function _tmux_status_update() {
          [[ -n "$TMUX_PANE" ]] || return
          local pane_path
          pane_path=$(pwd)
          gitmux -cfg ~/.config/gitmux/.gitmux.conf "$pane_path" > "/tmp/tmux-gitmux-$TMUX_PANE" 2>/dev/null
          ~/.config/tmux/scripts/starship-modules.sh > "/tmp/tmux-starship-$TMUX_PANE" 2>/dev/null
          tmux refresh-client -S 2>/dev/null
        }
        add-zsh-hook precmd _tmux_status_update

        # Suffix aliases (open files by extension)
        alias -s py='$EDITOR'
        alias -s js='$EDITOR'
        alias -s ts='$EDITOR'
        alias -s html=open
        alias -s go='$EDITOR'
        alias -s rs='$EDITOR'
        alias -s md='$EDITOR'
        alias -s lua='$EDITOR'
        alias -s nix='$EDITOR'

        # Global aliases (usable anywhere in command)
        alias -g NE='2>/dev/null'
        alias -g NO='>/dev/null'
        alias -g NUL='>/dev/null 2>&1'

        # Copy buffer to clipboard widget (Ctrl+X c)
        function copy-buffer-to-clipboard() {
          echo -n "$BUFFER" | pbcopy
          zle -M "Copied to clipboard"
        }
        zle -N copy-buffer-to-clipboard
        bindkey '^Xc' copy-buffer-to-clipboard

        # Hotkey text snippets
        bindkey -s '^Xg^c' 'git commit -m ""\C-b'
        bindkey -s '^g^g' '\C-a\C-k v .\n'

        # Wrap tmux to prompt for session name on new sessions
        tmux() {
          if [[ $# -eq 0 ]]; then
            # No args: attach to existing session or prompt for new
            if ! command tmux attach-session 2>/dev/null; then
              read "name?New tmux session name: "
              command tmux new-session -s "''${name:-default}"
            fi
          elif [[ "$1" == "new" || "$1" == "new-session" ]]; then
            # Creating new session: prompt if no -s flag provided
            if [[ "$*" != *"-s"* ]]; then
              read "name?Session name: "
              command tmux "$@" -s "''${name:-default}"
            else
              command tmux "$@"
            fi
          else
            # Pass through all other commands unchanged
            command tmux "$@"
          fi
        }

        # Export paths
        export TERM="xterm-256color"
        export COLORTERM="truecolor"
        export DOTFILES_PATH="''${DOTFILES_PATH:-$HOME/dotfiles}"
        export DOTFILES_CURRENT="''${DOTFILES_CURRENT:-$DOTFILES_PATH/current}"

        # Load p10k config
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      ''
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "macos"
      ];
    };
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden";
    defaultOptions = [
      "--height 80%"
      "--layout=reverse"
      "--border"
      "--bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up'"
    ];
  };
}
