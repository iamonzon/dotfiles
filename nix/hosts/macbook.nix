{ config, pkgs, lib, ... }:

{
  # Darwin-specific session paths
  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.sdkman/bin"
    "$HOME/.sdkman/candidates/java/current/bin"
    "$HOME/.sdkman/candidates/sbt/current/bin"
    "$HOME/.sdkman/candidates/scala/current/bin"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
  ];

  # Mac-specific packages (if any)
  # home.packages = with pkgs; [
  #   # Add Mac-only packages here
  # ];
}
