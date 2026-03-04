{
  description = "Ivan's Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-yazi-plugins, ... }@inputs:
    let
      system = "aarch64-darwin";
      username = "ivan";
    in
    {
      darwinConfigurations.empanada = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./system/darwin.nix
          ./system/homebrew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users.${username} = { ... }: {
              imports = [
                nix-yazi-plugins.legacyPackages.${system}.homeManagerModules.default
                ./home/default.nix
                ./hosts/macbook.nix
              ];
            };
          }
        ];
      };
    };
}
