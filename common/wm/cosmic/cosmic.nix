{ config, pkgs, lib, host-info, ... }:

let
  suspendSchedule = pkgs.writeShellApplication {
    name = "cosmic-suspend-schedule";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ./suspend-schedule.sh;
  };
in lib.mkIf (host-info.preferred_wm == "cosmic") {
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;

  systemd.user.services.cosmic-suspend-schedule = {
    Unit = {
      Description = "Apply COSMIC's daytime/overnight screen-off and suspend schedule";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe suspendSchedule;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.timers.cosmic-suspend-schedule = {
    Unit = {
      Description = "Recheck COSMIC screen-off and suspend at clock boundaries and after wake";
      PartOf = [ "graphical-session.target" ];
    };
    Timer = {
      OnCalendar = "*-*-* *:*:00";
      AccuracySec = "1s";
      Persistent = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.activation.cosmicSuspendSchedule = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe suspendSchedule}
  '';
}
