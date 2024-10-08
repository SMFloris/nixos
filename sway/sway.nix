{ config, pkgs, lib, ...}:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in lib.mkIf (config.host-info.preferred_wm == "sway") {
  home.packages = with pkgs; [
    # sway
      sway-audio-idle-inhibit
      swaylock-fancy swayidle 
      wl-clipboard wl-clipboard-x11 
      unstable.swaynotificationcenter 
      glib dracula-theme dracula-icon-theme 
      wbg
    # wayland
      wayvnc
  ];
  home.file.".config/openTerminal.sh".source = ./openTerminal.sh;
  home.file.".config/organizeOutputs.sh".source = ./organizeOutputs.sh;
  home.file.".config/switchWorkspace.sh".source = ./switchWorkspace.sh;
  home.file.".config/wofi/powermenu.css".source = ./wofi_menu.css;
  home.file.".config/waybar/powermenu.sh".source = ./powermenu.sh;
  home.file.".config/waybar/setBackground.sh".source = ./setBackground.sh;
  home.file.".config/swaync/style.css".source = ./swaync_style.css;
  home.file.".config/swaync/config.json".source = ./swaync_config.json;
  xfconf= {
    enable = true;
    settings = {
      # https://gitlab.xfce.org/xfce/thunar/-/blob/master/thunar/thunar-preferences.c
      thunar = {
        "misc-full-path-in-window-title" = true;
      };
    };
  };
  dconf = {
      enable = true;
      settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.dracula-icon-theme;
        name = "Dracula";
      };
      theme = {
        package = pkgs.dracula-theme;
        name = "Dracula";
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

  programs.wofi = {
    enable = true;
    style = (builtins.readFile ./wofi_style.css);
  };
  programs.waybar = import ./waybar.nix;
  wayland.windowManager.sway = import ./wm.nix { pkgs = pkgs; lib = lib; };
}
