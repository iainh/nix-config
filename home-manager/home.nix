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
    ./home-common.nix
  ];

  home = {
    username = "iain";
    homeDirectory = "/home/iain";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # home.packages = [ pkgs.httpie ];

  home.stateVersion = "22.11";

  # Fix the cursor in applications like alacritty under wayland that don't inherit 
  # gnome's cursor theme. 
  home.file.".icons/default".source = "${pkgs.apple-cursor}/share/icons/macOS-Monterey";

  gtk = {
    enable = true;
    cursorTheme = {
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
    };
  };

  # Reduce font size of alacritty
  programs.alacritty.settings.font.size = pkgs.lib.mkForce 13;

  programs.firefox = {
    enable = true;
  };

}
