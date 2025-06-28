{
  description = "IainH nix configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:

    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    helix-git.url = "github:helix-editor/helix";

    # SFMono w/ patches
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, darwin, fenix, nixpkgs, home-manager, hardware, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        # "aarch64-linux"
        # "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        # "x86_64-darwin"
      ];
    in
    let
      # Helper function to create Darwin home-manager configurations
      mkDarwinHome = hostname: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home-manager/macos.nix ];
      };
    in
    {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        carbon = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
            ./nixos/configuration.nix
          ];
        };
      };

      darwinConfigurations = {
        "yew" = darwin.lib.darwinSystem {
          specialArgs = { inherit inputs outputs; };
          system = "aarch64-darwin";
          modules = [
            ./macos/configuration.nix
          ];
        };

        "ginkgo" = darwin.lib.darwinSystem {
          specialArgs = { inherit inputs outputs; };
          system = "aarch64-darwin";
          modules = [
            ./macos/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "iain@carbon" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/linux.nix
          ];
        };

        "iheggie@yew" = mkDarwinHome "yew";
        "iheggie@ginkgo" = mkDarwinHome "ginkgo";
      };
    };
}
