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
      
      # Create a generic configuration
      mkConfig = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ 
          ./team-base.nix 
          # Use environment variables with fallbacks
          ({lib, ...}: {
            home.username = lib.mkDefault (builtins.getEnv "HM_USER");
            home.homeDirectory = lib.mkDefault (builtins.getEnv "HM_HOME");
          })
        ];
      };
    in {
      # Single configuration that can be overridden
      homeConfigurations.default = mkConfig;
    };
}