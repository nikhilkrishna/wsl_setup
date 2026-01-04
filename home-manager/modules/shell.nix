{ config, pkgs, lib, userConfig, ... }:

{
  # ============================================
  # Bash Configuration
  # ============================================
  programs.bash = {
    enable = true;

    historyControl = [ "ignoredups" "erasedups" ];
    historyFileSize = 100000;
    historySize = 100000;

    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
    ];

    initExtra = ''
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

      # mise initialization
      eval "$(mise activate bash)"

      # Better bash completion
      if [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi

      # fzf key bindings
      if command -v fzf &> /dev/null; then
        eval "$(fzf --bash)"
      fi

      # ============================================
      # Claude Code with AWS SSO pre-authentication
      # ============================================
      claude() {
        local profile="${userConfig.claude.awsProfile}"

        # Check if SSO session is valid for Claude's profile
        if ! aws sts get-caller-identity --profile "$profile" &>/dev/null; then
          echo "AWS SSO session expired for Claude ($profile). Logging in..."
          aws sso login --profile "$profile"
        fi

        # Run the actual claude command
        command claude "$@"
      }
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern ls replacements
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      la = "eza -a --icons";
      lt = "eza --tree --icons --level=2";
      cat = "bat --paging=never";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      g = "git";
      lzg = "lazygit";

      # Kubernetes shortcuts (when kubectl is installed via mise)
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";

      # Mise shortcuts
      mr = "mise run";
      mi = "mise install";
      ml = "mise list";

      # Docker shortcuts
      d = "docker";
      dc = "docker compose";
      dps = "docker ps";
      dpsa = "docker ps -a";
      lzd = "lazydocker";

      # Quick edits
      ehome = "nvim ~/dotfiles/home-manager/home.nix";
      # Note: This alias assumes dotfiles are located at ~/dotfiles
      reload = "home-manager switch --flake ~/dotfiles/home-manager#$USER && exec $SHELL";

      # Zellij (terminal multiplexer)
      zj = "zellij";
      zja = "zellij attach";
      zjl = "zellij list-sessions";
    };
  };

  # ============================================
  # Direnv with Nix integration
  # ============================================
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;

    # Whitelist directories for automatic loading
    config = {
      global = {
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };

    stdlib = ''
      # Custom direnv function to use mise
      use_mise() {
        direnv_load mise direnv exec
      }
    '';
  };

  # ============================================
  # FZF Configuration
  # ============================================
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;

    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];

    # Use fd for file searching
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };
}
