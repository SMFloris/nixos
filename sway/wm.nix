{ lib, pkgs, ...}:

let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
      '';
  };
in
{
  enable = true;
  wrapperFeatures.gtk = true;
  systemd.enable = true;
  config = rec {
    modifier = "Mod4";
    terminal = "~/.config/openTerminal.sh";
    bars = [{ command = "waybar"; }];
    menu = "wofi --show drun -I -m -a -p 'Search ...'";
    focus.newWindow = "focus";
    gaps.inner = 10;
    gaps.smartBorders = "on";
    fonts = {
      names = [ "DroidSansM Nerd Font" ];
      size = 11.0;
    };
    keybindings = pkgs.lib.mkOptionDefault {
      "${modifier}+minus" = "[app_id=\"(?!NeoOrg)\"] scratchpad show";
      "${modifier}+space" = "[app_id=\"NeoOrg\"] scratchpad show";
    };
    input = {
      "type:touchpad" = {
        dwt = "enabled";
        tap = "enabled";
        middle_emulation = "enabled";
      };
    };
    window.hideEdgeBorders = "smart";
    window.titlebar = false;
    window.commands = [
      {
        command = "focus";
        criteria = {
          urgent = "latest";
        };
      }
      {
        command = "floating enable";
        criteria = {
          app_id = "soffice";
          title = "Text Import.*";
        };
      }
      {
        command = "floating enable";
        criteria = {
          app_id = "org.gnome.Calculator";
        };
      }
      {
        command = "floating enable; resize set 800 600";
        criteria = {
          app_id = "wdisplays";
        };
      }
      {
        command = "move scratchpad";
        criteria = {
          app_id = "NeoOrg";
        };
      }
      {
        command = "floating enable";
        criteria = {
          app_id = "Float";
        };
      }
      {
        command = "floating enable";
        criteria = {
          app_id = "pavucontrol";
        };
      }
      {
        command = "kill";
        criteria = {
          title = "Firefox — Sharing Indicator";
        };
      }
      {
        command = "floating enable; sticky toggle";
        criteria = {
          title = "Picture-in-Picture";
        };
      }
    ];
  };
  extraConfig = ''
          #other
          set $playVolumeChangeSound cvlc --play-and-exit ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga
          exec swayidle -w \
            timeout 300 'swaylock-fancy' \
            timeout 600 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
            before-sleep 'swaylock-fancy'
          exec_always nm-applet --indicator

          input "type:keyboard" {
            xkb_layout us,ro
            xkb_options grp:alt_shift_toggle
          }
          mode passthrough {
    	      bindsym Mod4+XF86Messenger mode default
          }
          bindsym Mod4+XF86Messenger mode passthrough
          # swaync 
          exec swaync
          bindsym Mod4+Shift+n exec swaync-client -t -sw
      
          # brightness
          bindsym XF86MonBrightnessDown exec light -U 10
          bindsym XF86MonBrightnessUp exec light -A 10

          # volume
          bindsym XF86AudioRaiseVolume exec 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && $playVolumeChangeSound'
          bindsym XF86AudioLowerVolume exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && $playVolumeChangeSound'
          bindsym XF86AudioMute exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'

          # Screenshot
          bindsym Print       exec "grimshot --notify copy screen"
          bindsym Mod1+Print  exec "grimshot --notify save window"
          bindsym Shift+Print exec "grimshot --notify save area"
          bindsym Mod4+Print  exec "grimshot --notify copy area"

          bindsym Mod4+Tab workspace back_and_forth
          bindsym Mod4+Shift+Tab focus next
          bindsym Mod4+grave workspace 9
          bindsym Mod4+Shift+grave move workspace 9
          exec ${configure-gtk}/bin/configure-gtk

          exec_always /home/flow/.config/waybar/setBackground.sh
          exec_always /home/flow/.config/waybar/organizeOutputs.sh

          bindsym --no-warn Mod4+1 exec "/home/flow/.config/switchWorkspace.sh 0"
          bindsym --no-warn Mod4+2 exec "/home/flow/.config/switchWorkspace.sh 1"
          bindsym --no-warn Mod4+3 exec "/home/flow/.config/switchWorkspace.sh 2"
          bindsym --no-warn Mod4+4 exec "/home/flow/.config/switchWorkspace.sh 3"
          bindsym --no-warn Mod4+5 exec "/home/flow/.config/switchWorkspace.sh 4"
          bindsym --no-warn Mod4+6 exec "/home/flow/.config/switchWorkspace.sh 5"
          bindsym --no-warn Mod4+7 exec "/home/flow/.config/switchWorkspace.sh 6"
          bindsym --no-warn Mod4+8 exec "/home/flow/.config/switchWorkspace.sh 7"
          bindsym --no-warn Mod4+9 exec "/home/flow/.config/switchWorkspace.sh 8"
          bindsym --no-warn Mod4+0 exec "/home/flow/.config/switchWorkspace.sh 9"

          bindsym --no-warn Mod4+Shift+1 exec "/home/flow/.config/switchWorkspace.sh 0 move"
          bindsym --no-warn Mod4+Shift+2 exec "/home/flow/.config/switchWorkspace.sh 1 move"
          bindsym --no-warn Mod4+Shift+3 exec "/home/flow/.config/switchWorkspace.sh 2 move"
          bindsym --no-warn Mod4+Shift+4 exec "/home/flow/.config/switchWorkspace.sh 3 move"
          bindsym --no-warn Mod4+Shift+5 exec "/home/flow/.config/switchWorkspace.sh 4 move"
          bindsym --no-warn Mod4+Shift+6 exec "/home/flow/.config/switchWorkspace.sh 5 move"
          bindsym --no-warn Mod4+Shift+7 exec "/home/flow/.config/switchWorkspace.sh 6 move"
          bindsym --no-warn Mod4+Shift+8 exec "/home/flow/.config/switchWorkspace.sh 7 move"
          bindsym --no-warn Mod4+Shift+9 exec "/home/flow/.config/switchWorkspace.sh 8 move"
          bindsym --no-warn Mod4+Shift+0 exec "/home/flow/.config/switchWorkspace.sh 9 move"

          bindsym --no-warn Mod4+n focus output left
          bindsym --no-warn Mod4+m focus output right

          bindsym --no-warn Mod4+Shift+n move workspace to output left
          bindsym --no-warn Mod4+Shift+m move workspace to output right
          # neovim orgmode
          exec foot --title NeoOrg --app-id NeoOrg --working-directory ~/Dropbox/NeoOrg -e nvim .
          exec maestral start
  '';
}
