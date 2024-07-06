# Zsh options
setopt histreduceblanks    # Remove superfluous blanks from history entries
setopt histignorespace     # Don't save commands starting with space in history
setopt histignorealldups   # Remove older duplicates when adding to history
setopt autocd              # Change directory without 'cd' command
setopt nohup               # Don't send HUP signal to running jobs when shell exits
setopt globdots            # Include hidden files in globbing
setopt vi                  # Use vi key bindings
setopt automenu            # Automatically use menu completion after second tab
setopt listpacked          # Make completion lists more densely packed
setopt nolisttypes         # Don't show types in completion lists
setopt alwaystoend         # Move cursor to end of word after completion
setopt correct             # Try to correct spelling of commands
setopt no_nomatch          # Pass unmatched patterns as-is instead of error
setopt rmstarsilent        # Don't ask for confirmation for 'rm *' or 'rm path/*'

# Keybinding
bindkey '^ ' autosuggest-accept  # Use Ctrl+Space to accept autosuggestions

# Completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # Case-insensitive completion