{ config, pkgs, lib, nixosConfig, ... }:
let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin];
  };
in lib.mkIf (config.host-info.preferred_wm == "i3") {
  environment.pathsToLink = [ "/libexec" ];

  environment.systemPackages = with pkgs; [
    alacritty
    foot
    xclip
    simplescreenrecorder
    maim
    glow
    libnotify
    lxrandr
    xfce.xfce4-notifyd
    file-roller
    thunarWithPlugins
    xfce.ristretto
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    sway-contrib.grimshot
    gnome-clocks
    gnome-calculator
    rofi
  ];

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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd /home/flow/startWm.sh";
        user = "greeter";
      };
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

  programs.i3lock = {
    enable = true;
    package = pkgs.i3lock-fancy;
  };

  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n";

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
