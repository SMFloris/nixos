{ config, pkgs, lib, ... }:

let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in lib.mkIf (config.host-info.preferred_wm == "i3") {
  home.file.".xinitrc".source = ./xfiles/xinitrc;
  home.file."ai_chat.sh".source = ./rofi/ai_chat.sh;
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
  gtk = lib.mkForce {
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
  xsession.windowManager.i3 = {
    enable = true;

    config = rec {
      modifier = "Mod4";
      bars = [ ];

      window.border = 0;

      gaps = {
        inner = 15;
        outer = 5;
      };

      keybindings = lib.mkOptionDefault {
        "XF86AudioRaiseVolume" = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && \$playVolumeChangeSound'";
        "XF86AudioLowerVolume" = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && \$playVolumeChangeSound'";
        "XF86AudioMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";
        "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
        "Print" = "exec ${pkgs.maim}/bin/maim -s -u | xclip -selection clipboard -t image/png -i";
        "Shift+Print" = "exec ${pkgs.maim}/bin/maim -u ~/Pictures/\$(date +%Y-%m-%dT%H:%M:%S).png";
        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
        "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
        "${modifier}+Shift+x" = "exec systemctl suspend";
        "${modifier}+Tab" = "workspace back_and_forth";
        "${modifier}+grave" = "workspace 10";
        "${modifier}+~" = "move workspace 10";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+f" = "focus mode_toggle";
        "${modifier}+space" = "exec '/home/flow/ai_chat.sh'";
      };

      startup = [
        {
          command = "set \$playVolumeChangeSound cvlc --play-and-exit ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga";
          always = false;
          notification = false;
        }
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polkit-gnome-authentication-agent-1.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale --randomize ~/Pictures/Wallpapers";
          always = true;
          notification = false;
        }
        {
          command = "exec nm-applet --indicator";
          always = true;
          notification = false;
        }
        {
          command = "exec ${configure-gtk}/bin/configure-gtk";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
