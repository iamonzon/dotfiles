# Example: Python project shell.nix
# Place in project root, then run `nix-shell` to enter environment
#
# For direnv integration, create .envrc with: use nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.pandas
    python311Packages.numpy
    python311Packages.requests
  ];

  shellHook = ''
    echo "Python $(python --version) environment loaded"
  '';
}
