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
    in {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./team-base.nix ];
      };
    };
}