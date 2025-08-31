# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }: let
  inherit
    (lib)
    mapAttrs'
    nameValuePair
    ;

  bindWithModifier = mapAttrs' (k: nameValuePair (cfg.modifier + "+" + k));
  cfg = config.wayland.windowManager.sway.config;
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./common.nix
  ];

  # Username and homeDirectory are provided by the top-level
  # home-manager configuration via utils.mkHomeConfig.

  # Enable home-manager and git
  programs.home-manager.enable = true;

  home.packages = [ pkgs.hut ];

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

  services.mako = {
    enable = true;
    defaultTimeout = 2500;
    borderRadius = 3;
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemd.xdgAutostart = true;
    config = rec {
      modifier = "Mod4";

      focus.followMouse = false;
      focus.mouseWarping = false;

      fonts = {
        names = [ "DejaVu Sans Mono" "FontAwesome5Free" ];
        style = "Bold Semi-Condensed";
        size = 9.0;
      };

       keybindings =
          {
            "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" = "exec --no-startup-id wpctl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioMicMute" = "exec --no-startup-id wpctl set-source-mute @DEFAULT_SOURCE@ toggle";
          }

      // bindWithModifier {
          "t" = "exec ${cfg.terminal}";
          "b" = "exec firefox";
          "p" = "exec j4-dmenu-desktop --dmenu='BEMENU_BACKEND=wayland bemenu -m -1 -i";
          "z" = "exec zed";
          "Shift+r" = "reload";
          "q" = "kill";

          "Left" = "focus left";
          "Right" = "focus right";
          "Up" = "focus up";
          "Down" = "focus down";

          "Shift+Left" = "move left";
          "Shift+Right" = "move right";
          "Shift+Up" = "move up";
          "Shift+Down" = "move down";

          "s" = "splith";
          "v" = "splitv";
          "f" = "floating toggle";
          "Return" = "fullscreen toggle";
          "Space" = "focus mode_toggle";
          "w" = "layout tabbed";
          "e" = "layout toggle split";

          "Shift+Ctrl+q" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
          "r" = "mode resize";

          "1" = "workspace number 1";
          "2" = "workspace number 2";
          "3" = "workspace number 3";
          "4" = "workspace number 4";
          "5" = "workspace number 5";
          "6" = "workspace number 6";
          "7" = "workspace number 7";
          "8" = "workspace number 8";
          "9" = "workspace number 9";
          "Comma" = "workspace prev";
          "Period" = "workspace next";

          "Shift+1" = "move container to workspace number 1";
          "Shift+2" = "move container to workspace number 2";
          "Shift+3" = "move container to workspace number 3";
          "Shift+4" = "move container to workspace number 4";
          "Shift+5" = "move container to workspace number 5";
          "Shift+6" = "move container to workspace number 6";
          "Shift+7" = "move container to workspace number 7";
          "Shift+8" = "move container to workspace number 8";
          "Shift+9" = "move container to workspace number 9";
          "Shift+Comma" = "move container to workspace prev";
          "Shift+Period" = "move container to workspace next";
        };

      window.titlebar = true;

      terminal = "alacritty";
      startup = [
        { command = "nm-applet"; }
      ];
      output = {
        "eDP-1" = { scale = "1.5"; };
      };
    };
    extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
      export SSH_AUTH_SOCK;
    '';
  };

  home.sessionVariables = {
    # Let nixos electron wrappers enable wayland
    NIXOS_OZONE_WL = 1;
    # opengl backend flickers, also vulkan is love.
    # WLR_RENDERER = "vulkan";
  };

}
