{ pkgs, lib, ... }:

let
  # ====================
  # Shared Variables
  # ====================

  # Powerline rounded right separator (U+E0B4) - encoded to survive formatters
  rightSep = builtins.fromJSON ''"\ue0b4"'';

  # Theme configuration
  theme = "mocha";
  windowStatusStyle = "rounded";

  # Timing and sizing
  resizeAmount = 5;
  continuumSaveInterval = 15;
  maxSessionNameLen = 8;

  vars = { inherit theme windowStatusStyle rightSep resizeAmount continuumSaveInterval maxSessionNameLen; };

  # ====================
  # Feature Toggles
  # ====================

  features = {
    panes = true;
    windows = true;
    sessions = true;
  };

  # ====================
  # Import Modules
  # ====================

  themeModule = import ./theme.nix vars;
  panes = import ./panes.nix vars;
  windows = import ./windows.nix vars;
  sessions = import ./sessions.nix vars;

  # Merge catppuccin config from theme + enabled features
  catppuccinConfig = lib.concatStrings [
    themeModule.catppuccinConfig
    (lib.optionalString features.windows windows.catppuccinConfig)
    (lib.optionalString features.sessions sessions.catppuccinConfig)
  ];

  plugins = import ./plugins.nix { inherit pkgs continuumSaveInterval catppuccinConfig; };

  # Helper: assemble tmux status side from ordered pill list
  mkStatusSide = side: pills:
    let
      first = builtins.head pills;
      rest = builtins.tail pills;
    in lib.concatStringsSep "\n    " (
      [ ''set -g status-${side} "${first}"'' ]
      ++ map (p: ''set -ag status-${side} "${p}"'') rest
    );

  # Status bar pill order (left-to-right as they appear on screen)
  statusLeft = [
    themeModule.pills.directory
    themeModule.pills.gitmux
    themeModule.pills.starship
  ];

  statusRight =
    (lib.optional features.sessions sessions.pill)
    ++ [ themeModule.pills.meeting ];

  statusBarConfig = ''
    ${themeModule.layout}
    ${mkStatusSide "left" statusLeft}
    ${mkStatusSide "right" statusRight}
  '';

in
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    prefix = "C-Space";
    historyLimit = 10000;
    terminal = "tmux-256color";
    plugins = plugins;
    extraConfig = ''
      ${import ./core.nix}
      ${statusBarConfig}
      ${lib.optionalString features.panes panes.keybindings}
      ${lib.optionalString features.windows windows.keybindings}
      ${lib.optionalString features.sessions sessions.keybindings}
      ${import ./general.nix}

      # Hot-reload experimental config (create ~/.config/tmux/experimental.conf to use)
      source-file -q ~/.config/tmux/experimental.conf
    '';
  };

  # Deploy tmux helper scripts
  home.file.".config/tmux/scripts/dir-lookup-table.sh" = {
    executable = true;
    source = ./scripts/dir-lookup-table.sh;
  };

  home.file.".config/tmux/scripts/dir-color.sh" = {
    executable = true;
    source = ./scripts/dir-color.sh;
  };

  home.file.".config/tmux/scripts/dir-icon.sh" = {
    executable = true;
    source = ./scripts/dir-icon.sh;
  };

  home.file.".config/tmux/scripts/starship-modules.sh" = {
    executable = true;
    source = ./scripts/starship-modules.sh;
  };

  home.file.".config/tmux/scripts/meeting.sh" = {
    executable = true;
    source = ./scripts/meeting.sh;
  };
}
