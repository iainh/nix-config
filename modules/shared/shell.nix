# ABOUTME: Shared shell configuration module for both bash and zsh
# ABOUTME: This eliminates duplication and provides consistent shell experience

{ lib, pkgs, config, ... }:
let
  # Common shell aliases used across bash and zsh
  commonAliases = {
    hms = "home-manager switch --flake ~/nix-config";
    
    # Determinate Nix optimized commands
    rebuild = "nix run nixpkgs#nixos-rebuild -- switch --flake ~/nix-config --fast";
    check = "nix flake check --fast";
    update = "nix flake update --commit-lock-file";
    gc = "nix store gc --verbose";
    optimize = "nix store optimise";
    
    # Enhanced grep with color
    grep = "grep --colour=auto";
    egrep = "grep -E --colour=auto";
    fgrep = "grep -F --colour=auto";
    ls = "ls --color=auto";
  };

  # Platform-specific aliases
  darwinAliases = {
    sysup = "sudo nix run nix-darwin -- switch --flake ~/nix-config";
  };

  linuxAliases = {
    sysup = "sudo nixos-rebuild switch --flake ~/nix-config";
  };

  # Determine platform-specific aliases
  platformAliases = 
    if pkgs.stdenv.isDarwin 
    then darwinAliases 
    else linuxAliases;

  # Combined aliases
  allAliases = commonAliases // platformAliases;

  # Common shell initialization for environment setup
  commonInit = ''
    export DIRENV_LOG_FORMAT=

    # Source nix-darwin environment if available (macOS only)
    if [ -d "/run/current-system/sw" ]; then
      if [ -f "/etc/zshrc" ]; then
        . /etc/zshrc
      fi
    fi
  '';
in
{
  # Define a custom option to hold our shell configuration
  options.myShell = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Shared shell configuration";
  };

  # Set the configuration
  config.myShell = {
    aliases = allAliases;
    commonInit = commonInit;
  };
}