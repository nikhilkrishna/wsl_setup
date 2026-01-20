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
      ${builtins.readFile ./scripts/bash-init.sh}

      # ============================================
      # Claude Code with AWS SSO pre-authentication
      # ============================================
      claude() {
        local profile="${userConfig.claude.awsProfile}"
        ${builtins.readFile ./scripts/claude-wrapper.sh}
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

    stdlib = builtins.readFile ./scripts/direnv-stdlib.sh;
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
