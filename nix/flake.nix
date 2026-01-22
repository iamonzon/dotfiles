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

      # Yazi config directory with Tokyo Night theme
      yaziConfigDir = pkgs.runCommand "yazi-tokyo-night-config" {} ''
        mkdir -p $out
        cp ${./experiments/yazi/yazi.toml} $out/yazi.toml
        cp ${./experiments/yazi/theme.toml} $out/theme.toml
      '';

      # Wrapper script that runs yazi with custom config
      yaziTest = pkgs.writeShellScriptBin "yazi-test" ''
        export YAZI_CONFIG_HOME=${yaziConfigDir}
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
