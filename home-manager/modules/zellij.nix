{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;  # Manual start only

    settings = {
      theme = "nord";
      default_shell = "bash";

      # Mouse support enabled by default in Zellij
      mouse_mode = true;

      # Copy to system clipboard
      copy_on_select = true;

      # Simplified UI option (hides hints after learning)
      simplified_ui = false;  # Keep hints visible for discoverability
    };
  };
}
