{
	  enable = true;
	  settings = {
		  mainbar = {
			  layer = "top";
			  position = "top";
			  height = 40;
			  margin = "10 10 0 10";
			  modules-left = ["custom/notification" "idle_inhibitor" "sway/window" "sway/mode"];
			  modules-center = ["sway/workspaces"];
			  modules-right = ["memory" "pulseaudio" "battery" "custom/keyboard" "network" "tray" "clock" "custom/powermenu"];
			  "sway/workspaces" = {
			  	disable-scroll = true;
				  disable-markup = true;
				  format = "  {icon}  ";
				  persistent_workspaces = {
				    "1" = {};
				    "2" = {};
				    "3" = {};
				    "4" = {};
				    "5" = {};
				    "6" = {};
				    "7" = {};
				    "8" = {};
				    "9" = {};
				    "10" = {};
				  };
				  format-icons = {
				    urgent = "";
				    focused = "";
				    default = "";
				  };
			  };
			  "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            "notification" = "<span foreground='red'><sup></sup></span>";
            "none" = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
			  };
			  "sway/window" = {
				  format = "{}";
				  max-length = 50;
			  };
			  "sway/mode" = {
			  	format = "<span style=\"italic\">{}  </span>";
        	tooltip = false;
			  };
			  memory = {
				  interval = 1;
				  format = "<span color=\"#f1fa8c\"></span> {}%";
				  tooltip = false;
				  on-click = "alacritty --class Float -e htop";
			  };
			  disk = {
				  interval = 60;
				  format = "{percentage_used}% 󰋊";
				  path = "/";
			  };
			  idle_inhibitor = {
				  format = "{icon} ";
				  tooltip = false;
				  format-icons = {
					  activated = "";
					  deactivated = "";
				  };
			  };
			  cpu = {
				  format = "<span color=\"#f1fa8c\"></span>  {usage}%";
				  interval = "1";
				  tooltip = false;
			  };
			  tray = {
				  spacing = 10;
				  icon-size = 21;
			  };
			  battery = {
			  	interval = 10;
				  states = {
				  	good = 95;
					  warning = 20;
					  critical = 10;
				  };
				  format = "{capacity}% {icon} ";
				  format-charging = "{capacity}% 󰂄";
				  format-icons = [
				  	  "<span color=\"#ff5555\"></span>" 
					    "<span color=\"#ffb86c\"></span>" 
					    "<span color=\"#f1fa8c\"></span>" 
					    "<span color=\"#50fa7b\"></span>" 
					    "<span color=\"#50fa7b\"></span>" 
				  ];
				  on-click = "alacritty --class Float -e sudo powertop";
			  };
			  "custom/keyboard" = {
          format = "<span color=\"#ff6699\"></span> {}";
          on-click = "swaymsg input 1:1:AT_Translated_Set_2_keyboard xkb_switch_layout next";
          exec = "~/.config/waybar/getCurrentLayout.sh";
          interval = 5;
			  };
			  "custom/powermenu" = {
				  on-click = "~/.config/waybar/powermenu.sh";
				  format = "<span color=\"#ff5555\">⏻</span>";
				  tooltip = false;
			  };
			  clock = {
				  format = "<span color=\"#ff5535\">󰅐</span> {:%H:%M:%S}";
				  tooltip-format = "<tt>{calendar}</tt>";
  	      calendar = {
  		        mode          = "month";
  		        mode-mon-col  = 3;
  		        weeks-pos     = "";
  		        on-scroll    = 1;
  		        on-click-right = "mode";
  		        format = {
  			        months =     "<span color='#ffead3'><b>{}</b></span>";
  			        days =       "<span color='#ffffff'><b>{}</b></span>";
  			        # weeks =      "<span color='#99ffdd'><b>W{}</b></span>";
  			        weeks =      "";
  			        weekdays =   "<span color='#ffcc66'><b>{}</b></span>";
  			        today =      "<span color='#ff6699'><b><u>{}</u></b></span>";
  		        };
  	        };
  	        actions = {
  		        on-click-right = "mode";
  		        # on-click-forward = "tz_up";
  		        # on-click-backward = "tz_down";
  		        # on-scroll-up = "shift_up";
  		        # on-scroll-down = "shift_down";
  	        };
			  };
			  pulseaudio = {
				  format = "<span color=\"#8be9fd\">{icon}</span> {volume}%";
				  format-bluetooth = "<span color=\"#8be9fd\">{icon}</span> {volume}% ";
				  format-muted = "<span color=\"#ff5555\">󰖁</span>";
				  format-icons = {
					  headphones = "";
					  handsfree = "";
					  headset = "";
					  phone = "";
					  portable = "";
					  car = "";
					  default = [""];
				  };
				  tooltip = false;
				  on-click = "pavucontrol";
			  };
			  network = {
				  format-wifi = "";
				  format-ethernet = "Wired ";
				  format-disconnected = " ⚠";
				  tooltip = false;
				  on-click = "alacritty --class Float -e nmtui";
			  };
			  "custom/launcher" = {
				  on-click = "alacritty --config ~/.config/foot/foot-solid.ini --app-id=launcher ~/.config/sway/scripts/launcher.sh";
				  format = "<span color=\"#ff79c6\">  </span>";
				  tooltip = false;
			  };
		  };
    };
    style = (builtins.readFile ./waybar_style.css);  

}
