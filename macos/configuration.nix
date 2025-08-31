{ inputs, outputs, lib, config, pkgs, ... }: {
  # Import shared configurations
  imports = [
    ../modules/shared/nixpkgs.nix
  ];

  ids.gids.nixbld = 350;

  system.primaryUser = "iheggie";

  nix = {
    # Disable nix-darwin's Nix management for Determinate Nix compatibility
    enable = false;

    # All other nix.* options (registry, nixPath, settings) are unavailable
    # when nix.enable = false since nix-darwin doesn't manage Nix
    # Determinate Nix handles flakes and registries automatically
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
    master.gemini-cli
    master.codex
    gh
    nodejs_24
    uv
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
