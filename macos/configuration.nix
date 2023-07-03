{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  environment.shells = with pkgs; [bashInteractive zsh ];
  
  programs.zsh.enable = true;
  programs.bash.enable = true;

  environment.systemPackages = [
    pkgs.wezterm
  ];

  # nix.package = pkgs.nixUnstable;
  nix.settings.allowed-users = [ "iheggie" "root" ];
  nix.settings.trusted-users = [ "iheggie" "root" ];

  # Allow unfree packages on an unfree OS
  nixpkgs.config.allowUnfree = true;

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

  fonts.fonts = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    iosevka-bin
    ia-writer-mono
  ];
}

