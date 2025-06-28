{ inputs, outputs, lib, config, pkgs, ... }: {


  ids.gids.nixbld = 350;

  system.primaryUser = "iheggie";

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
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
      #      optimise.automatic = true;
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      # "alacritty"
      # "aerospace"
      "discord"
      "firefox"
      "steam"
      "zed"
    ];

    # taps = [
    #   "nikitabobko/aerospace"
    # ];
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
    # inputs.simple-completion-language-server.defaultPackage.${pkgs.system}
    (fenix.complete.withComponents
      [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
    rust-analyzer-nightly
    taplo
    qmk
    zig
    zls
    exercism
  ];

  # nix.package = pkgs.nixUnstable;
  nix.settings.allowed-users = [ "iheggie" "root" ];
  nix.settings.trusted-users = [ "iheggie" "root" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  # services.nix-daemon.enable = true;
  nix.settings.max-jobs = 6;
  nix.settings.cores = 6;
  # nix.configureBuildUsers = true;

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      # josevka
      ia-writer-mono
      # dm-mono
      # intel-one-mono
      # (nerdfonts.override { fonts = [ "CodeNewRoman" ]; })
    ];
  };
}
