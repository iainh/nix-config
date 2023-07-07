# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    # Import shared home manager configuration
    ./home-common.nix
  ];

  home = {
    username = "iheggie";
    homeDirectory = "/Users/iheggie";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # home.packages = [ pkgs.httpie ];

  home.stateVersion = "22.11";

  programs.dircolors = { 
    enable = true;
  };
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ripgrep.enable = true;

}
