{ config, pkgs, lib, ... }:

{
  # ============================================
  # SSH Configuration (no secrets, just config)
  # ============================================
  programs.ssh = {
    enable = true;

    # Global SSH settings
    extraConfig = ''
      # Use 1Password SSH agent if available (recommended)
      # Uncomment and adjust the path for your setup:
      # IdentityAgent ~/.1password/agent.sock

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
      IdentitiesOnly yes
    '';

    # Host-specific configurations (no secrets)
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # Key will be provided by agent
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
  # AWS Configuration (SSO config only, no creds)
  # ============================================
  # Uncomment and customize for your AWS setup
  #
  # home.file.".aws/config".text = ''
  #   [default]
  #   region = eu-central-1
  #   output = json
  #
  #   [profile dev]
  #   sso_start_url = https://yourcompany.awsapps.com/start
  #   sso_region = eu-central-1
  #   sso_account_id = 123456789012
  #   sso_role_name = DeveloperAccess
  #   region = eu-central-1
  #
  #   [profile prod]
  #   sso_start_url = https://yourcompany.awsapps.com/start
  #   sso_region = eu-central-1
  #   sso_account_id = 987654321098
  #   sso_role_name = ReadOnlyAccess
  #   region = eu-central-1
  # '';
}
