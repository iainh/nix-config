# Common home-manager configuration to be imported by an OS specific configuration

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

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      hms = "home-manager switch --flake ~/nix-config";
      grep = "grep --colour=auto";
      egrep = "grep -E --colour=auto";
      fgrep = "grep -F --colour=auto";
      ls = "ls --color=auto";
    };

    initExtra = ''

      export DIRENV_LOG_FORMAT=

      if [ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" ]; then
        . /nix/store/qb6x3h3hkczrjblnv976fxg95mrgrkm0-set-environment
      fi

      prompt_gentoo_setup () {
        local prompt_gentoo_prompt=''${1:-'blue'}
        local prompt_gentoo_user=''${2:-'green'}
        local prompt_gentoo_root=''${3:-'red'}

        if [ "$EUID" = '0' ]
        then
          local base_prompt="%B%F{$prompt_gentoo_root}%m%k "
        else
          local base_prompt="%B%F{$prompt_gentoo_user}%n@%m%k "
        fi
        local post_prompt="%b%f%k"

        #setopt noxtrace localoptions

        local path_prompt="%B%F{$prompt_gentoo_prompt}%1~"
        typeset -g PS1="$base_prompt$path_prompt %# $post_prompt"
        typeset -g PS2="$base_prompt$path_prompt %_> $post_prompt"
        typeset -g PS3="$base_prompt$path_prompt ?# $post_prompt"
      }

      prompt_gentoo_setup "$@"
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      hms = "home-manager switch --flake ~/nix-config";
      drs = "darwin-rebuild switch --flake ~/nix-config";
    };
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

          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
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
      font.normal.family = "CodeNewRoman Nerd Font Mono";

      font.offset.y = 2;
      font.glyph_offset.y = 1;

      # window.decorations = "buttonless";
      window.decorations_theme_variant = "Dark";
      # window.padding.y = 8;
      # window.padding.x = 8;

      # Colors (Wombat)
      colors = {
        # Default colors
        primary = {
          background = "0x1f1f1f";
          foreground = "0xe5e1d8";
        };

        # Normal colors
        normal = {
          black = "0x000000";
          red = "0xf7786d";
          green = "0xbde97c";
          yellow = "0xefdfac";
          blue = "0x6ebaf8";
          magenta = "0xef88ff";
          cyan = "0x90fdf8";
          white = "0xe5e1d8";
        };

        # Bright colors
        bright = {
          black = "0xb4b4b4";
          red = "0xf99f92";
          green = "0xe3f7a1";
          yellow = "0xf2e9bf";
          blue = "0xb3d2ff";
          magenta = "0xe5bdff";
          cyan = "0xc2fefa";
          white = "0xffffff";
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
    package = inputs.helix-git.packages.${pkgs.system}.helix;
    settings = {
      # theme = "curzon";
      theme = "noctis_bordo";
      editor.lsp.display-messages = true;
      editor.lsp.display-inlay-hints = true;
      editor.completion-trigger-len = 1;
      editor.soft-wrap.enable = true;
      editor.smart-tab.enable = true;
    };
    languages = {
      language-server.sclc = {
        command = "simple-completion-language-server";
        config =
          {
            max_completion_items = 20; # set max completion results len for each group: words, snippets, unicode-input
            snippets_first = true; # completions will return before snippets by default
            feature_words = true; # enable completion by word
            feature_snippets = true; # enable snippets
            feature_unicode_input = true; # enable "unicode input"
            feature_paths = true; # enable path completion
          };
      };
      language = [{
        name = "nix";
        formatter = { command = "nixpkgs-fmt"; };
        auto-format = true;
      }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "sclc" "rust-analyzer" ];
        }];
    };
  };

  programs.tmux = {
    enable = true;
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;
    # Enable mouse support
    mouse = true;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    extraConfig = ''
      set -g default-terminal "tmux"
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Smart pane switching with awareness of Helix splits.
      is_hx="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|hx)(diff)?$'"
      bind -n C-h if-shell "$is_hx" "send-keys C-h"  "select-pane -L"
      bind -n C-j if-shell "$is_hx" "send-keys C-j"  "select-pane -D"
      bind -n C-k if-shell "$is_hx" "send-keys C-k"  "select-pane -U"
      bind -n C-l if-shell "$is_hx" "send-keys C-l"  "select-pane -R"
      bind -n C-\\ if-shell "$is_hx" "send-keys C-\\" "select-pane -l"
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "iain@spiralpoint.org";
    userName = "Iain H";
    aliases = {
      st = "status - sb";
      ci = "commit";
      cm = "commit -am";
      br = "branch";
      co = "checkout";
      df = "diff";
      undo = "reset - -hard";
    };
  };

  programs.fzf = {
    enable = true;
  };

  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = " all ";
      downloader = "
        aria2c ";
      downloader-args = " aria2c:'-c - x8 - s8 - k1M' ";
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      default_layout = "
        compact ";
    };
  };

}





