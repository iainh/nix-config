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

    # Enhanced history configuration
    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    # Enable completion system
    enableCompletion = true;
    
    # Useful zsh options
    setOptions = [
      "AUTO_CD"              # cd by typing directory name
      "AUTO_PUSHD"           # push directories to stack automatically
      "PUSHD_IGNORE_DUPS"    # don't push duplicate directories
      "EXTENDED_GLOB"        # enable extended globbing
      "GLOB_DOTS"            # include dotfiles in glob patterns
      "CORRECT"              # command correction
      "PROMPT_SUBST"         # enable prompt substitution
      "HIST_VERIFY"          # verify history expansion before execution
      "HIST_EXPIRE_DUPS_FIRST" # expire duplicate entries first
      "HIST_IGNORE_DUPS"     # ignore duplicate commands
      "HIST_IGNORE_SPACE"    # ignore commands starting with space
      "HIST_REDUCE_BLANKS"   # remove superfluous blanks
      "SHARE_HISTORY"        # share history between sessions
      "INC_APPEND_HISTORY"   # append to history immediately
    ];

    # Completion configuration
    completionInit = ''
      # Enable completion caching
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path ~/.zsh/cache
      
      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      
      # Menu selection for completions
      zstyle ':completion:*' menu select
      
      # Group completions by type
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%B%d%b'
      
      # Better completion for kill command
      zstyle ':completion:*:*:kill:*' menu yes select
      zstyle ':completion:*:kill:*' force-list always
      
      # Completion for common commands
      zstyle ':completion:*:git:*' verbose yes
      zstyle ':completion:*:nix:*' verbose yes
    '';

    initExtra = config.myShell.commonInit + ''
      # Key bindings for better navigation
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      
      # Better word navigation
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      
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
