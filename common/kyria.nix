args@{ ... }:
let
  # Pin the keyboard firmware/service repository. specialArgs.kyriaSource can
  # supply a local Git snapshot for development and pre-push validation.
  source = args.kyriaSource or (builtins.fetchGit {
    url = "https://github.com/SMFloris/vial-kyria.git";
    ref = "master";
    rev = "0a21a2f301a1b407dd8e3062da493871c116a048";
  });
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
    layers = {
      "0" = {
        name = "Typing";
        underglow = { color = "#005aff"; brightness = 255; };
      };
      "1" = {
        name = "Numbers";
        underglow = { color = "#ff9600"; brightness = 255; };
      };
      "2" = {
        name = "COSMIC";
        underglow = { color = "#b400ff"; brightness = 255; };
        keys = {
          N = { color = "#4fea55"; brightness = 255; };
          M = { color = "#4fea55"; brightness = 255; };
          Comma = { color = "#4fea55"; brightness = 255; };
          Period = { color = "#4fea55"; brightness = 255; };
        };
      };
      "3" = {
        name = "Navigation";
        underglow = { color = "#00ff3c"; brightness = 255; };
        keys = {
          H = { color = "#4fea55"; brightness = 255; };
          J = { color = "#4fea55"; brightness = 255; };
          K = { color = "#4fea55"; brightness = 255; };
          L = { color = "#4fea55"; brightness = 255; };
        };
      };
      "4" = {
        name = "Editor";
        underglow = { color = "#00ffff"; brightness = 255; };
      };
      "5" = {
        name = "Function";
        underglow = { color = "#ff0000"; brightness = 255; };
      };
      "6" = {
        name = "Settings";
        underglow = { color = "#ffffff"; brightness = 255; };
      };
      "7" = {
        name = "Spare";
        underglow = { color = "#ff0078"; brightness = 255; };
      };
    };
  };
}
