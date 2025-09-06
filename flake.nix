{
  description = "Dynamo team development environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { nixpkgs, home-manager, ... }: 
    let
      # Auto-detect system or default to x86_64-linux
      system = builtins.currentSystem or "x86_64-linux";
      
      # Create a configuration that detects user dynamically
      mkDynamicConfig = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ 
          ./team-base.nix 
          {
            # Use environment variables for dynamic user detection
            home.username = builtins.getEnv "USER";
            home.homeDirectory = builtins.getEnv "HOME";
          }
        ];
      };
    in {
      # Single dynamic configuration that works for any user
      homeConfigurations.default = mkDynamicConfig;
    };
}