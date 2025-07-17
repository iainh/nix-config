# ABOUTME: Shared nixpkgs configuration module for consistent overlay and config settings
# ABOUTME: This eliminates duplication across different system configurations

{ inputs, outputs, ... }:
{
  # Import Determinate Nix optimizations
  imports = [
    ./determinate-optimizations.nix
  ];

  nixpkgs = {
    # Shared overlays used across all configurations
    overlays = [
      # Add overlays from own flake exports (from overlays and pkgs dir)
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.master-packages
      inputs.fenix.overlays.default

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    # Shared nixpkgs configuration
    config = {
      # Allow unfree packages across all configurations
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };
}