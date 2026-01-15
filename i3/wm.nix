{ config, pkgs, lib, nixosConfig, ... }:

lib.mkIf (config.host-info.preferred_wm == "i3") {
  environment.pathsToLink = [ "/libexec" ];

  environment.systemPackages = with pkgs; [
    alacritty
    foot
    xclip
    simplescreenrecorder
    maim
    glow
    libnotify
    dunst
    xfce.xfce4-notifyd
    ulauncher
  ];

  
   systemd.user.services.ulauncher = {
      description = "ulauncher";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      requires = [ "dbus.service" ];
      after = [ "graphical-session.target" "dbus.service" ];
       serviceConfig = {
         Type = "simple";
         ExecStart = pkgs.writeShellScript "ulauncher-env-wrapper.sh" ''
           export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
           export GDK_BACKEND=x11
           exec ${pkgs.ulauncher}/bin/ulauncher --hide-window --no-window-shadow
         '';
         Restart = "on-failure";
         RestartSec = 1;
         TimeoutStopSec = 10;
       };
   };

  systemd.user.services.xfce4-notifyd = {
    description = "xfce4 notifyd";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.xfce.xfce4-notifyd}/lib/xfce4/notifyd/xfce4-notifyd";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    windowManager.i3.enable = true;
  };
  services.autorandr.enable = true;
  services.displayManager = {
    defaultSession = "none+i3";
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
   };
}
