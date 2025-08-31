# ABOUTME: NixOS system configurations module  
# ABOUTME: Contains all NixOS system definitions for better organization

{ inputs, outputs, nixpkgs, home-manager, hardware, darwin, ... }:
let
  utils = import ../shared/utils.nix { 
    inherit inputs outputs nixpkgs home-manager darwin; 
  };
in
{
  # NixOS system configurations
  nixosConfigurations = {
    carbon = utils.mkNixosSystem {
      hostname = "carbon";
      modules = [ ../../nixos/configuration.nix ];
      extraModules = [ hardware.nixosModules.lenovo-thinkpad-x1-6th-gen ];
    };
  };

  # NixOS home-manager configurations
  homeConfigurations = {
    "iain@carbon" = utils.mkHomeConfig {
      system = "x86_64-linux";
      username = "iain";
      homeDirectory = utils.getHomeDirectory { 
        system = "x86_64-linux"; 
        username = "iain"; 
      };
      modules = [ ../../home-manager/linux.nix ];
    };

    "iheggie@debian" = utils.mkHomeConfig {
      system = "aarch64-linux";
      username = "iheggie";
      homeDirectory = utils.getHomeDirectory {
        system = "aarch64-linux";
        username = "iheggie";
      };
      modules = [ ../../home-manager/linux.nix ];
    };
  };
}
