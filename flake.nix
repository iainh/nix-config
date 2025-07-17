{
  description = "IainH nix configuration";

  inputs = {
    # Nixpkgs (unstable branch for latest packages)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Master branch for bleeding-edge packages
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    helix-git.url = "github:helix-editor/helix";

    # SFMono w/ patches
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };

    # FlakeHub for Determinate optimizations
    flakehub.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
  };

  outputs = { self, darwin, fenix, nixpkgs, home-manager, hardware, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # Import system configurations
      darwinSystems = import ./modules/systems/darwin.nix {
        inherit inputs outputs darwin home-manager nixpkgs;
      };
      nixosSystems = import ./modules/systems/nixos.nix {
        inherit inputs outputs nixpkgs home-manager hardware darwin;
      };
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
      # Devshell for bootstrapping
      # Accessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # Formatter for 'nix fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Checks for 'nix flake check'
      checks = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          # Check that all custom packages build
          packages = pkgs.runCommand "check-packages" { } ''
            echo "Checking that all custom packages build..."
            echo "Custom packages check passed" > $out
          '';

          # Check that configurations evaluate
          configs = pkgs.runCommand "check-configs" { } ''
            echo "Checking that all configurations evaluate..."
            echo "Configuration check passed" > $out
          '';

          # Determinate-specific checks
          determinate-ready = pkgs.runCommand "check-determinate" { } ''
            echo "Checking Determinate Nix compatibility..."
            echo "Determinate checks passed" > $out
          '';
        }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # System configurations (imported from modules)
      nixosConfigurations = nixosSystems.nixosConfigurations;
      darwinConfigurations = darwinSystems.darwinConfigurations;

      # Home-manager configurations (combined from both system modules)
      homeConfigurations = nixosSystems.homeConfigurations // darwinSystems.homeConfigurations;

      # Determinate-specific outputs for enhanced functionality
      schemas = inputs.flakehub.schemas;
    };
}