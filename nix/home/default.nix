{
  imports = [
    ./shell.nix
    ./version-control.nix
    ./text-editor.nix
    ./file-manager.nix
    ./terminal.nix
    ./terminal-tools.nix
    ./system-monitor.nix
    ./data-tools.nix
    ./dev-runtime.nix
    ./network-tools.nix
    ./media-processing.nix
    ./document-viewer.nix
    ./nix-tools.nix
  ];

  home.username = "ivan";
  home.homeDirectory = "/Users/ivan";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_EDITOR = "nvim";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
  };

  # Create standard directories
  home.file."Personal/Projects/.keep".text = "";
  home.file."Work/Projects/.keep".text = "";

  # Powerlevel10k config
  home.file.".p10k.zsh".source = ../files/p10k.zsh;
}
