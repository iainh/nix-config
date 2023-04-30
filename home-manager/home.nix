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
  ];

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "iain";
    homeDirectory = "/home/iain";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

    # home.packages = [ pkgs.httpie ];

    home.stateVersion = "22.11";

    programs.bash = {
      enable = true;
      initExtra = ''
      # Change the window title of X terminals
case \$\{TERM\} in
    [aEkx]term*|rxvt*|gnome*|konsole*|interix|tmux*)
        PS1='\[\033]0;\u@\h:\w\007\]'
        ;;
    screen*)
        PS1='\[\033k\u@\h:\w\033\\\]'
        ;;
    *)
        unset PS1
        ;;
esac

use_color=false
if type -P dircolors >/dev/null ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    LS_COLORS=
    if [[ -f ~/.dir_colors ]] ; then
        eval "$(dircolors -b ~/.dir_colors)"
    elif [[ -f /etc/DIR_COLORS ]] ; then
        eval "$(dircolors -b /etc/DIR_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
    if [[ -n ''${LS_COLORS:+set} ]] ; then
        use_color=true
    else
        # Delete it if it's empty as it's useless in that case.
        unset LS_COLORS
    fi
else
    case ''${TERM} in
        [aEkx]term*|rxvt*|gnome*|konsole*|screen|tmux|cons25|*color) use_color=true;;
    esac
fi

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if ''${use_color} ; then
    if [[ ''${EUID} == 0 ]] ; then
        PS1+='\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '
    else
        PS1+='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[33m\]$(parse_git_branch)\[\033[37m\] \$\[\033[00m\] '
    fi

    alias grep='grep --colour=auto'
    alias egrep='grep -E --colour=auto'
    alias fgrep='grep -F --colour=auto'
else
    # show root@ when we don't have colors
    PS1+='\u@\h \w \$ '
fi

for sh in /etc/bash/bashrc.d/* ; do
    [[ -r ''${sh} ]] && source "''${sh}"
done

unset use_color sh

    export INPUTRC=~/.inputrc
      '';
    };

    programs.readline = {
      enable = true;
    
      extraConfig = ''
        set mark-directories on
      '';
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "Jetbrains Mono";
        font.size = 13;

        # Colors (Mellow)
        colors = {
          # Default colors
          primary = {
            background = "#161617";
            foreground = "#c9c7cd";
          };
          # Cursor colors
          cursor = {
            text = "#c9c7cd";
            cursor = "#757581";
          };
          # Normal colors
          normal = {
            black = "#27272a";
            red = "#f5a191";
            green = "#90b99f";
            yellow = "#e6b99d";
            blue = "#aca1cf";
            magenta = "#e29eca";
            cyan = "#ea83a5";
            white = "#c1c0d4";
          };
          # Bright colors
          bright = {
            black = "#353539";
            red = "#ffae9f";
            green = "#9dc6ac";
            yellow = "#f0c5a9";
            blue = "#b9aeda";
            magenta = "#ecaad6";
            cyan = "#f591b2";
            white = "#cac9dd";
          };
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.helix = {
      enable = true;
      package = inputs.helix-git.packages.x86_64-linux.helix;
      settings = {
        theme = "mellow";
        editor.lsp.display-messages = true;
        editor.lsp.display-inlay-hints = true;
        editor.completion-trigger-len = 1;
        editor.soft-wrap.enable = true;
      };
    };

    programs.git = {
      enable = true;
      userEmail = "iain@spiralpoint.org";
      userName = "Iain H";
    };

    programs.fzf = {
      enable = true;
    };

    programs.firefox = {
      enable = true;
      # package = pkgs.wrapFirefox pkgs.firefox-beta-unwrapped {
        # extraPolicies = {
        #   ExtensionSettings = {};
        # };
      # };
    };
    
    # home.pointerCursor = {
    #   package = pkgs.apple-cursor;
    #   name = "macOS-BigSur";
    # };
  # };

  # # List packages installed in system profile. To search, run:
  # # $ nix search wget
  # environment.systemPackages = with pkgs; [
	 #  curl
  #   qmk
  #   qmk-udev-rules
  #   appimage-run
  #   ripgrep
  # ];

  # fonts.fonts = with pkgs; [
  #   jetbrains-mono
  #   noto-fonts
  #   noto-fonts-cjk
  #   noto-fonts-emoji
  #   liberation_ttf
  #   fira-code
  #   fira-code-symbols
  #   iosevka-bin
  # ];  

  # nicely reload system units when changing configs
  # systemd.user.startservices = "sd-switch";

  # # https://nixos.wiki/wiki/faq/when_do_i_update_stateversion
  # home.stateversion = "22.11";
}
