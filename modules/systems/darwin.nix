# ABOUTME: Darwin (macOS) system configurations module
# ABOUTME: Contains all Darwin system definitions for better organization

{ inputs, outputs, darwin, home-manager, nixpkgs, ... }:
let
  utils = import ../shared/utils.nix { 
    inherit inputs outputs nixpkgs home-manager darwin; 
  };
in
{
  # Darwin system configurations
  darwinConfigurations = {
    "yew" = utils.mkDarwinSystem {
      hostname = "yew";
      modules = [ ../../macos/configuration.nix ];
    };

    "ginkgo" = utils.mkDarwinSystem {
      hostname = "ginkgo";
      modules = [ ../../macos/configuration.nix ];
    };
  };

  # Darwin home-manager configurations
  homeConfigurations = {
    "iheggie@yew" = utils.mkHomeConfig {
      system = "aarch64-darwin";
      username = "iheggie";
      homeDirectory = utils.getHomeDirectory { 
        system = "aarch64-darwin"; 
        username = "iheggie"; 
      };
      modules = [ ../../home-manager/macos.nix ];
    };

    "iheggie@ginkgo" = utils.mkHomeConfig {
      system = "aarch64-darwin";
      username = "iheggie";
      homeDirectory = utils.getHomeDirectory { 
        system = "aarch64-darwin"; 
        username = "iheggie"; 
      };
      modules = [ ../../home-manager/macos.nix ];
    };
  };
}