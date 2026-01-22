{ config, pkgs, lib, userConfig, ... }:

let
  windowsUserDir = "/mnt/c/Users/${userConfig.windowsUsername}";
in
{
  # ============================================
  # SSH Configuration (no secrets, just config)
  # ============================================
  programs.ssh = {
    enable = true;

    # Global SSH settings
    extraConfig = ''
      # Use 1Password SSH agent if available (recommended)
      IdentityAgent ~/.1password/agent.sock

      # Or use Windows SSH agent via WSL:
      # IdentityAgent /mnt/c/Users/YOUR_USER/.ssh/agent.sock

      # Connection sharing for faster repeated connections
      ControlMaster auto
      ControlPath ~/.ssh/sockets/%r@%h-%p
      ControlPersist 600

      # Keep connections alive
      ServerAliveInterval 60
      ServerAliveCountMax 3

      # Security defaults
      AddKeysToAgent yes
    '';

    # Host-specific configurations (no secrets)
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        identityFile = [ "~/.ssh/nikhilkrishna.pub" ];
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
      };

      # Example: company servers
      # "*.company.internal" = {
      #   user = "your-username";
      #   proxyJump = "bastion.company.internal";
      # };
    };
  };

  # Create SSH sockets directory
  home.file.".ssh/sockets/.keep".text = "";

  # ============================================
  # AWS Configuration (symlinked to Windows)
  # ============================================
  # Config managed on Windows side, symlinked here
  home.file.".aws/config".source =
    config.lib.file.mkOutOfStoreSymlink "${windowsUserDir}/.aws/config";

  # ============================================
  # Kubernetes Configuration (symlinked to Windows)
  # ============================================
  # EKS kubeconfig managed on Windows side, symlinked here
  home.file.".kube/config".source =
    config.lib.file.mkOutOfStoreSymlink "${windowsUserDir}/.kube/eksconfig";
}
