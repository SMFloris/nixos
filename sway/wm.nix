{ lib, pkgs, ...}:

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
in {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    config = rec {
      modifier = "Mod4";
      terminal = "~/.config/openTerminal.sh";
      bars = [{ command = "waybar"; }];
      menu = "wofi --show drun -I -m -a -p 'Search ...'";
      focus.newWindow = "focus";
      gaps.inner = 10;
      gaps.smartBorders = "on";
      fonts = {
	      names = [ "DroidSansM Nerd Font"];
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
	        app_id = "org.gnome.Calculator";
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
      exec swayidle -w timeout 300 "swaylock-fancy --daemonize" timeout 600 "swaymsg 'output * dpms off'" resume "swaymsg 'output * dpms on'" before-sleep "swaylock-fancy --daemonize" timeout 600 "systemctl suspend"
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
      bindsym XF86AudioRaiseVolume exec 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+'
      bindsym XF86AudioLowerVolume exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'
      bindsym XF86AudioMute exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'

      # Screenshot
      bindsym Print       exec "grimshot --notify copy screen"
      bindsym Mod1+Print  exec "grimshot --notify save window"
      bindsym Shift+Print exec "grimshot --notify save area"
      bindsym Mod4+Print  exec "grimshot --notify copy area"

      bindsym Mod4+Tab workspace back_and_forth
      bindsym Mod4+grave workspace number 10
      bindsym Mod4+Shift+grave move container to workspace number 10
      bindsym Mod4+0 workspace number 10
      bindsym Mod4+Shift+0 move container to workspace number 10
      exec ${configure-gtk}/bin/configure-gtk

      exec_always /home/flow/.config/waybar/setBackground.sh

      # neovim orgmode
      exec foot --title NeoOrg --app-id NeoOrg --working-directory ~/Dropbox/NeoOrg -e nvim .
      exec maestral start
      '';
}
