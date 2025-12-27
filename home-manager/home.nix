{ config, pkgs, lib, ... }:

{
  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # This value determines the home-manager release compatibility
  home.stateVersion = "24.05";

  # Import modular configurations
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/development.nix
    ./modules/secrets.nix
  ];

  # ============================================
  # Core System Packages
  # ============================================
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    findutils
    gnugrep
    gnused
    gawk

    # Modern CLI tools
    ripgrep          # Better grep
    fd               # Better find
    fzf              # Fuzzy finder
    bat              # Better cat
    eza              # Better ls (formerly exa)
    delta            # Better diff
    jq               # JSON processor
    yq               # YAML processor
    htop             # Process viewer
    tree             # Directory tree

    # Network tools
    curl
    wget
    netcat-openbsd   # Or netcat-gnu if you prefer
    socat

    # Compression
    unzip
    zip
    gzip

    # Build essentials (for compiling things mise might need)
    gcc
    gnumake
    pkg-config
    openssl

    # The key orchestration tools
    mise             # Runtime version manager

    # Fonts - JetBrains Mono and FiraCode with Nerd Font patches
    # Note: Using the new nerd-fonts package format for nixos-unstable
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # ============================================
  # Fonts Configuration
  # ============================================
  fonts.fontconfig.enable = true;

  # ============================================
  # Session Variables
  # ============================================
  home.sessionVariables = {
    VISUAL = "vim";
    PAGER = "less";

    # Ensure mise shims are in PATH
    PATH = "$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH";

    # Better colors
    TERM = "xterm-256color";
  };

  # ============================================
  # XDG Base Directories
  # ============================================
  xdg.enable = true;
}
