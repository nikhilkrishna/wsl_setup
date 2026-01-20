# functions.sh - All bash functions and initialization
# This file is placed at ~/.local/share/dotfiles/functions.sh by home-manager
# and sourced from .bashrc at runtime.

# ============================================
# SSH Agent Relay for 1Password (WSL)
# ============================================
# See docs/ssh-setup.md for 1Password SSH Agent Relay setup

export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# Function to start the SSH agent relay
_start_ssh_relay() {
  # Find npiperelay.exe
  local NPIPERELAY=""
  if command -v npiperelay.exe &>/dev/null; then
    NPIPERELAY="npiperelay.exe"
  elif [ -f "/mnt/c/Program Files/npiperelay/npiperelay.exe" ]; then
    NPIPERELAY="/mnt/c/Program Files/npiperelay/npiperelay.exe"
  elif [ -f "/mnt/c/tools/npiperelay.exe" ]; then
    NPIPERELAY="/mnt/c/tools/npiperelay.exe"
  elif [ -f "/mnt/c/Users/$USER/scoop/shims/npiperelay.exe" ]; then
    NPIPERELAY="/mnt/c/Users/$USER/scoop/shims/npiperelay.exe"
  else
    # Check winget packages location
    local WINGET_DIR="/mnt/c/Users/$USER/AppData/Local/Microsoft/WinGet/Packages"
    NPIPERELAY=$(find "$WINGET_DIR" -name "npiperelay.exe" 2>/dev/null | head -1)
  fi

  if [ -n "$NPIPERELAY" ]; then
    # Kill any stale socat processes for this socket
    pkill -f "socat.*1password/agent.sock" 2>/dev/null
    mkdir -p "$HOME/.1password"
    rm -f "$SSH_AUTH_SOCK"
    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"$NPIPERELAY -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    sleep 0.2
  fi
}

# Start relay if socket doesn't exist or agent isn't responding
if [ ! -S "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
  _start_ssh_relay
fi

# ============================================
# Mise (runtime version manager)
# ============================================
eval "$(mise activate bash)"

# ============================================
# Bash Completion
# ============================================
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# ============================================
# FZF Key Bindings
# ============================================
if command -v fzf &> /dev/null; then
  eval "$(fzf --bash)"
fi
