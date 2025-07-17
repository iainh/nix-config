# ABOUTME: Shared utility functions for platform-agnostic configuration
# ABOUTME: Contains helper functions used across different system configurations

{ inputs, outputs, nixpkgs, home-manager, darwin, ... }:
{
  # Helper function to create home-manager configurations
  mkHomeConfig = { system, username, homeDirectory, modules }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs outputs; };
      modules = [ 
        {
          home = {
            inherit username;
            homeDirectory = homeDirectory;
          };
        }
      ] ++ modules;
    };

  # Helper function to create Darwin system configurations
  mkDarwinSystem = { hostname, system ? "aarch64-darwin", modules ? [], extraModules ? [] }:
    darwin.lib.darwinSystem {
      specialArgs = { inherit inputs outputs; };
      inherit system;
      modules = modules ++ extraModules;
    };

  # Helper function to create NixOS system configurations  
  mkNixosSystem = { hostname, system ? "x86_64-linux", modules ? [], extraModules ? [] }:
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs; };
      inherit system;
      modules = modules ++ extraModules;
    };

  # Helper to determine if a system is Darwin (macOS)
  isDarwin = system: builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ];

  # Helper to determine if a system is Linux
  isLinux = system: builtins.elem system [ "x86_64-linux" "aarch64-linux" "i686-linux" ];

  # Helper to get appropriate home directory for a system
  getHomeDirectory = { system, username }:
    if (builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ])
    then "/Users/${username}"
    else "/home/${username}";
}