{ lib, host-info, home-manager, ... }:
let
  inherit (home-manager.users.flow.lib.formats.rasi) mkLiteral;
in lib.mkIf (host-info.preferred_wm == "i3") {
  programs.rofi = {
    enable = true;
    theme = import ./rofi/applauncher.nix { inherit mkLiteral; };
  };
}
