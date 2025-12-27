{ config, pkgs, lib, ... }:

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
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      la = "eza -a --icons";
      lt = "eza --tree --icons --level=2";
      cat = "bat --paging=never";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline -20";
      gp = "git pull";

      # Kubernetes shortcuts (when kubectl is installed via mise)
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";

      # Mise shortcuts
      mr = "mise run";
      mi = "mise install";
      ml = "mise list";

      # Quick edits
      ehome = "vim ~/dotfiles/home-manager/home.nix";
      # Note: This alias assumes dotfiles are located at ~/dotfiles
      reload = "home-manager switch --flake ~/dotfiles/home-manager#$USER && exec $SHELL";
    };
  };

  # ============================================
  # Starship Prompt
  # ============================================
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # Minimal, informative prompt
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$python"
        "$nodejs"
        "$golang"
        "$java"
        "$kubernetes"
        "$aws"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # Directory
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      # Git
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style)) ";
        style = "bold red";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "*";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»";
        deleted = "✘";
      };

      # Languages (only show when in relevant project)
      python = {
        format = "[$symbol$version]($style) ";
        style = "yellow";
        symbol = " ";
      };

      nodejs = {
        format = "[$symbol$version]($style) ";
        style = "green";
        symbol = " ";
      };

      golang = {
        format = "[$symbol$version]($style) ";
        style = "cyan";
        symbol = " ";
      };

      java = {
        format = "[$symbol$version]($style) ";
        style = "red";
        symbol = " ";
      };

      # Kubernetes context
      kubernetes = {
        disabled = false;
        format = "[$symbol$context]($style) ";
        style = "bold blue";
        symbol = "⎈ ";
      };

      # AWS profile
      aws = {
        format = "[$symbol$profile]($style) ";
        style = "bold orange";
        symbol = " ";
      };

      # Command duration (only show if > 2 seconds)
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
        style = "yellow";
      };

      # Prompt character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
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
