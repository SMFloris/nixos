{ lib, pkgs, ...}:

{
  home.packages = with pkgs; [
    # sway
      swaylock-fancy swayidle wl-clipboard wl-clipboard-x11 swaynotificationcenter glib dracula-theme dracula-icon-theme wbg
    # wayland
      wayvnc
  ];
  home.file.".config/openTerminal.sh".source = ./openTerminal.sh;
  home.file.".config/waybar/powermenu.sh".source = ./powermenu.sh;
  home.file.".config/waybar/setBackground.sh".source = ./setBackground.sh;
  home.file.".config/swaync/style.css".source = ./swaync_style.css;
  home.file.".config/swaync/config.json".source = ./swaync_config.json;
  dconf = {
      enable = true;
      settings = {
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
