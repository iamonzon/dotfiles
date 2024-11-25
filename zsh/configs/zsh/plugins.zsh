# Zsh settings
DISABLE_MAGIC_FUNCTIONS=true
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
COMPLETION_WAITING_DOTS=true
DISABLE_UNTRACKED_FILES_DIRTY=true

# Plugins
plugins=(
  zsh-autosuggestions
  git
  zsh-syntax-highlighting
)

# OS-specific plugins
if command -v docker >/dev/null 2>&1; then
    plugins+=(docker docker-compose)
fi

if command -v dnf >/dev/null 2>&1; then
    plugins+=(dnf)
fi

if command -v npm >/dev/null 2>&1; then
    plugins+=(npm)
fi

if command -v python >/dev/null 2>&1; then
    plugins+=(virtualenv)
fi
