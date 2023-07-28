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
    ./common.nix
  ];

  home = {
    username = "iheggie";
    homeDirectory = "/Users/iheggie";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # home.packages = [ pkgs.httpie ];

  home.stateVersion = "22.11";

  # Set the font size of alacritty
  programs.alacritty.settings.font.size = pkgs.lib.mkForce 16;


  programs.dircolors = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ripgrep.enable = true;

  programs.kitty = {
    enable = true;
    settings = {
      theme = "Rosé Pine";
      cursor_beam_thickness = "2.0";
      # font_family = "Berkeley Mono";

      # font_family = "iA Writer Mono S";
      font_family = "iA Writer Mono S Regular";
      bold_font = "iA Writer Mono S Bold";
      italic_font = "iA Writer Mono S Italic";
      bold_italic_font = "iA Writer Mono S Bold Italic";


      font_size = 17;
      # Gamma and contrast. The default on Linux is 1.0 gamma and 0 contrast,
      # 1.7 gamma and 30 contrast on MacOS.
      text_composition_strategy = "1.1 10";
    };
  };

}
