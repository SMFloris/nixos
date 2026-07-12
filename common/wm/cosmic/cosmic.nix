{ config, pkgs, lib, host-info, ... }:

let
in lib.mkIf (host-info.preferred_wm == "cosmic") {
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
}
