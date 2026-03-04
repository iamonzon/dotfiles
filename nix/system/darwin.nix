{ username, ... }:

{
  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-level programs
  programs.zsh.enable = true;

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # nix-darwin state version; set on first install, do not change
  system.stateVersion = 6;

  # macOS system defaults
  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      launchanim = false;
      show-recents = false;
      tilesize = 58;
      # Hot corners disabled (1 = disabled)
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    # Global preferences
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      InitialKeyRepeat = 25;
      KeyRepeat = 5;
      NSAutomaticPeriodSubstitutionEnabled = false;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      Dragging = true;
      TrackpadRightClick = true;
    };

    # Screenshots
    screencapture.location = "~/Documents";

    # Window Manager
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
    };
  };

  # Activation script for settings without typed nix-darwin options
  system.activationScripts.postUserActivation.text = ''
    # Stage Manager off
    defaults write com.apple.WindowManager GloballyEnabled -bool false

    # Tiling off
    defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
    defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
    defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false

    # Double-click titlebar minimizes
    defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool true

  '';
}
