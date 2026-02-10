{
  description = "Ivan's Home Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-yazi-plugins, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

    in
    {
      homeConfigurations = {
        "ivan" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            nix-yazi-plugins.legacyPackages.${system}.homeManagerModules.default
            ./home/default.nix
            ./hosts/macbook.nix
          ];
        };
      };
    };
}
