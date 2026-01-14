# Example: Scala project shell.nix
# Place in project root, then run `nix-shell` to enter environment

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jdk21
    scala_3
    sbt
    maven
    coursier
    metals  # Scala LSP
  ];

  JAVA_HOME = "${pkgs.jdk21}";

  shellHook = ''
    echo "Scala $(scala -version 2>&1 | head -1) environment loaded"
    echo "Java: $JAVA_HOME"
  '';
}
