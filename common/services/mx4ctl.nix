{ pkgs, ... }:

let
  mx4ctl = pkgs.callPackage ../packages/mx4ctl.nix { };
  servicePath = with pkgs; [
    alsa-utils
    brightnessctl
    dbus
    libnotify
    wireplumber
    xdotool
    xprop
  ];
in
{
  environment.systemPackages = [ mx4ctl ];
  services.udev.packages = [ mx4ctl ];

  systemd.user.services.mx4ctl = {
    description = "MX Master 4 haptics and extras daemon";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = servicePath;
    serviceConfig = {
      ExecStart = "${mx4ctl}/bin/mx4ctl daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.user.services.mx4ctl-restore = {
    description = "Restore MX Master 4 settings";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = servicePath;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mx4ctl}/bin/mx4-wizard --restore";
    };
  };
}
