# Example: Node.js project shell.nix
# Place in project root, then run `nix-shell` to enter environment

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
    yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
  ];

  shellHook = ''
    echo "Node $(node --version) environment loaded"
  '';
}
