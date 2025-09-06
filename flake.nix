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
      
      # Create a configuration that can work with any user
      mkUserConfig = username: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ 
          ./team-base.nix 
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
        ];
      };
    in {
      # Default config (fallback)
      homeConfigurations.default = mkUserConfig "user";
      
      # Common usernames for convenience
      homeConfigurations.ryan = mkUserConfig "ryan";
      homeConfigurations.ubuntu = mkUserConfig "ubuntu";
      homeConfigurations.root = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ 
          ./team-base.nix 
          {
            home.username = "root";
            home.homeDirectory = "/root";
          }
        ];
      };
    };
}