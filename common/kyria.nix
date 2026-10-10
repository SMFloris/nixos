args@{ lib, ... }:
let
  # Use a local Git snapshot for development, or the tested pushed revision.
  source = args.kyriaSource or (builtins.fetchGit {
    url = "https://github.com/SMFloris/vial-kyria.git";
    ref = "master";
    rev = "8043b1bcb9a65af0789d7bd3a3ef2e9c1d91f6c3";
  });

  key = color: { inherit color; brightness = 255; };
  pair = keys: color: lib.genAttrs keys (_: key color);
  numbers = pair [ "G" "H" ] "#92dce5"
    // pair [ "F" "J" ] "#af1b3f"
    // pair [ "D" "K" ] "#ead637"
    // pair [ "S" "L" ] "#473144"
    // pair [ "A" "Semicolon" ] "#2b590f";
  directions = keys: pair keys "#4fea55";
  layer = name: color: keys: {
    inherit name;
    underglow = { inherit color; brightness = 128; };
    keys = { "*" = { inherit color; brightness = 8; }; } // keys;
  };
in {
  imports = [ "${source}/kyria/nix/module.nix" ];

  services.kyria-layer = {
    enable = true;
    user = "flow";
    pollIntervalMs = 50;
    applet = {
      enable = true;
      installToPanel = true;
      panel = "Panel";
    };
    # Lighting and layer names are controlled here; firmware only displays frames.
    layers = {
      "0" = layer "Typing" "#005aff" { };
      "1" = layer "Numbers" "#ff9600" numbers;
      "2" = layer "COSMIC" "#b400ff"
        (numbers // directions [ "N" "M" "Comma" "Period" ]);
      "3" = layer "Navigation" "#00ff3c"
        (directions [ "H" "J" "K" "L" ]);
      "4" = layer "Editor" "#00ffff" { };
      "5" = layer "Function" "#ff0000" { };
      "6" = layer "Settings" "#ffffff" { };
      "7" = layer "Spare" "#ff0078" { };
    };
  };
}
