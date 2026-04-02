{ lib, ... }:
let
  coreCasks = [
    "boring-notch"
    "firefox@developer-edition"
    "jordanbaird-ice"
    "karabiner-elements"
    "rectangle"
    "stats"
    "time-out"
    "zen"
  ];

  defaultSelections = lib.importJSON ./homebrew-casks-default.json;
  localSelectionsPath = ./homebrew-casks-local.json;
  localSelections =
    if builtins.pathExists localSelectionsPath
    then lib.importJSON localSelectionsPath
    else {};
  selections = defaultSelections // localSelections;
  enabledOptionalCasks =
    lib.filter (name: selections.${name} or false) (builtins.attrNames selections);
in
{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    casks = coreCasks ++ enabledOptionalCasks;
  };
}
