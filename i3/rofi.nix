{ config, pkgs, lib, ... }:
let
  inherit (config.home-manager.users.flow.lib.formats.rasi) mkLiteral;
in lib.mkIf (config.host-info.preferred_wm == "i3") {
  programs.rofi = {
    enable = true;
    theme = import ./rofi/applauncher.nix { inherit mkLiteral; };
  };
}
