{
  description = "Home Manager configuration for WSL development environment";

  inputs = {
    # Pin to a specific nixpkgs commit for reproducibility
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "1password-cli"
          ];
        };
      };

      # Import user configuration
      # Copy user-config.nix.example to user-config.nix and customize
      userConfig = import ./user-config.nix;

      username = userConfig.username;
      homeDirectory = "/home/${username}";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Pass userConfig to all modules
        extraSpecialArgs = { inherit userConfig; };

        modules = [
          ./home.nix
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ];
      };
    };
}
