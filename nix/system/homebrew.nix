{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    brews = [];

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
