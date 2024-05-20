{ inputs, outputs, lib, config, pkgs, ... }: {

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

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

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  environment.shells = with pkgs; [ bashInteractive ];

  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    nil
    nixpkgs-fmt
    nmap
  ];

  # nix.package = pkgs.nixUnstable;
  nix.settings.allowed-users = [ "iheggie" "root" ];
  nix.settings.trusted-users = [ "iheggie" "root" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  services.nix-daemon.enable = true;
  nix.settings.max-jobs = 8;
  nix.settings.cores = 8;
  nix.configureBuildUsers = true;

  nix.extraOptions = ''
    builders-use-substitutes = true
    experimental-features = nix-command flakes
  '';

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      ia-writer-mono
      dm-mono
      josevka
    ];
  };
}

