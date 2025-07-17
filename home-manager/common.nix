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
    
    # Import shared configurations
    ../modules/shared/nixpkgs.nix
    ../modules/shared/shell.nix
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    RUST_SRC_PATH = "${pkgs.fenix.stable.rust-src}/lib/rustlib/src/rust/library";
  };

  home.sessionPath = [ "$HOME/.cargo/bin" "$HOME/.local/bin" ];

  programs.zsh = {
    enable = true;
    shellAliases = config.myShell.aliases;

    initContent = config.myShell.commonInit + ''

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
    shellAliases = config.myShell.aliases;
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.helix = {
    enable = true;
    package = inputs.helix-git.packages.${pkgs.system}.helix;
    settings = {
      theme = "gruvbox-material";
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
            # feature_paths = true; # enable path completion
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

  programs.git = {
    enable = true;
    userEmail = "iain@spiralpoint.org";
    userName = "Iain H";
    aliases = {
      st = "status -sb";
      ci = "commit";
      cm = "commit -am";
      br = "branch";
      co = "checkout";
      df = "diff";
      undo = "reset --hard";
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
      downloader = "aria2c";
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      default_layout = "compact";
    };
  };

}
