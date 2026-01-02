{ config, pkgs, lib, userConfig, ... }:

{
  # ============================================
  # Docker CLI Tools
  # ============================================
  # Note: Docker daemon runs via systemd in WSL2
  # See docs/docker-setup.md for setup instructions
  home.packages = with pkgs; [
    docker           # Docker CLI client
    docker-compose   # Docker Compose v2
    # lazydocker installed via mise (see mise/config.toml)
  ];
}
