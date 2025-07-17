# ABOUTME: Determinate Nix specific optimizations and configurations
# ABOUTME: Takes advantage of Determinate Nix features for better performance

{ lib, ... }:
{
  nix.settings = {
    # Determinate Nix optimizations (compatible settings only)
    
    # Enable parallel builds for faster compilation
    max-jobs = "auto";
    
    # Use all available cores for each build job
    cores = 0; # 0 means use all available cores
    
    # Enable keep-outputs to speed up development workflows
    keep-outputs = true;
    keep-derivations = true;
    
    # Optimize for binary cache hits
    builders-use-substitutes = true;
    
    # Enable more aggressive garbage collection settings
    min-free = lib.mkDefault (1000 * 1000 * 1000); # 1GB
    max-free = lib.mkDefault (3000 * 1000 * 1000); # 3GB
    
    # FlakeHub optimizations (already configured by Determinate)
    flake-registry = "https://flakehub.com/f/DeterminateSystems/flake-registry/*.tar.gz";
    
    # Optimize substitute behavior
    max-substitution-jobs = 16;
    
    # Use HTTP/2 for better performance
    http2 = true;
    
    # Trust the Determinate cache unconditionally for better performance
    trusted-substituters = [
      "https://cache.flakehub.com"
      "https://cache.nixos.org" 
      "https://install.determinate.systems"
    ];
    
    # Increase timeouts for large builds
    stalled-download-timeout = 300;
    timeout = 0; # No timeout for builds
  };

  # Enable automatic store optimization (platform-specific configuration)
  nix.optimise.automatic = true;

  # Enable automatic garbage collection with Determinate-friendly settings
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
}