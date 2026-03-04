{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    casks = [
      "android-studio"
      "boring-notch"
      "docker-desktop"
      "firefox@developer-edition"
      "iterm2"
      "jordanbaird-ice"
      "karabiner-elements"
      "pearcleaner"
      "popclip"
      "rectangle"
      "stats"
      "ticktick"
      "time-out"
      "zen"
    ];
  };
}
