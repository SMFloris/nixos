{ lib, host-info, home-manager, ... }:
let
  inherit (home-manager.users.flow.lib.formats.rasi) mkLiteral;
in {
  programs.rofi = {
    enable = true;
    theme = import ./rofi/applauncher.nix { inherit mkLiteral; };
  };
}
