{ config, pkgs, lib, ... }:

{
  # Darwin-specific session paths
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
  ];

  # Mac-specific packages (if any)
  # home.packages = with pkgs; [
  #   # Add Mac-only packages here
  # ];
}
