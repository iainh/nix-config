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

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
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
  nix.settings.allowed-users = [ "iheggie" "root" ];
  nix.settings.trusted-users = [ "iheggie" "root" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 6;
  nix.settings.cores = 6;

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      ia-writer-mono
    ];
  };
}
