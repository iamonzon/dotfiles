{
  description = "Ivan's Home Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Yazi config directory with flavors
      yaziConfigDir = pkgs.runCommand "yazi-config" {} ''
        mkdir -p $out/flavors
        cp ${./experiments/yazi/yazi.toml} $out/yazi.toml
        cp ${./experiments/yazi/theme.toml} $out/theme.toml
        cp -r ${./experiments/yazi/flavors}/* $out/flavors/
      '';

      # Wrapper script that runs yazi with custom config
      yaziTest = pkgs.writeShellScriptBin "yazi-test" ''
        export YAZI_CONFIG_HOME=${yaziConfigDir}
        export COLORTERM=truecolor
        exec ${pkgs.yazi}/bin/yazi "$@"
      '';
    in
    {
      homeConfigurations = {
        "ivan" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/default.nix
            ./hosts/macbook.nix
          ];
        };
      };

      # Apps for testing configurations
      apps.${system} = {
        yazi-test = {
          type = "app";
          program = pkgs.lib.getExe yaziTest;
        };
      };
    };
}
