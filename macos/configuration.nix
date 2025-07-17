{ inputs, outputs, lib, config, pkgs, ... }: {
  # Import shared configurations
  imports = [
    ../modules/shared/nixpkgs.nix
  ];

  ids.gids.nixbld = 350;

  system.primaryUser = "iheggie";

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # Note: Most settings are now in determinate-optimizations.nix
    # Only keeping essential Darwin-specific settings here
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "discord"
      "firefox"
      "steam"
      "zed"
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  environment.shells = with pkgs; [ bashInteractive ];

  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    beamMinimalPackages.erlang
    gleam
    master.claude-code
    (fenix.stable.withComponents
      [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
    rust-analyzer
    taplo
    qmk
    zig
    zls
    exercism
    nixd
  ];
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Note: nix configuration moved to determinate-optimizations.nix

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      ia-writer-mono
    ];
  };
}
