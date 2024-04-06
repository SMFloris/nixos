{
	enable = true;
	settings = {
		mainbar = {
			layer = "bottom";
			position = "top";
			height = 40;
			margin = "10 10 0 10";
			modules-left = ["sway/window" "sway/mode"];
			modules-center = ["sway/workspaces"];
			modules-right = ["idle_inhibitor" "custom/audio_idle_inhibitor" "memory" "pulseaudio" "battery" "sway/language" "tray" "clock" "custom/notification"];
			"custom/notification" = {
      	tooltip = false;
      	format = "󰐥";
      	format-icons = {
        	"notification" = "";
        	"none" = "";
        	"dnd-notification" = "";
        	"dnd-none" = "";
        	"inhibited-notification" = "";
        	"inhibited-none" = "";
        	"dnd-inhibited-notification" = "";
        	"dnd-inhibited-none" = "";
      	};
      	return-type = "json";
      	exec-if = "which swaync-client";
      	exec = "swaync-client -swb";
      	on-click = "swaync-client -t -sw";
      	on-click-right = "swaync-client -d -sw";
      	escape = true;
			};
			"sway/workspaces" = {
			  disable-scroll = true;
				disable-markup = true;
				format = " {icon} ";
				persistent_workspaces = {
				  "1" =[ "eDP-1" ];
				  "2" =[ "eDP-1" ];
				  "3" =[ "eDP-1" ];
				  "4" =[ "eDP-1" ];
				  "5" =[ "eDP-1" ];
				  "6" =[ "eDP-1" ];
				  "7" =[ "eDP-1" ];
				  "8" =[ "eDP-1" ];
				  "9" =[ "eDP-1" ];
				  "10" =[ "eDP-1" ];
				  "11" =[ "DP-2" ];
				  "12" =[ "DP-2" ];
				  "13" =[ "DP-2" ];
				  "14" =[ "DP-2" ];
				  "15" =[ "DP-2" ];
				  "16" =[ "DP-2" ];
				  "17" =[ "DP-2" ];
				  "18" =[ "DP-2" ];
				  "19" =[ "DP-2" ];
				  "20" =[ "DP-2" ];
				  "21" =[ "DP-1" ];
				  "22" =[ "DP-1" ];
				  "23" =[ "DP-1" ];
				  "24" =[ "DP-1" ];
				  "25" =[ "DP-1" ];
				  "26" =[ "DP-1" ];
				  "27" =[ "DP-1" ];
				  "28" =[ "DP-1" ];
				  "29" =[ "DP-1" ];
				  "30" =[ "DP-1" ];
				  "31" =[ "HDMI-A-1" ];
				  "32" =[ "HDMI-A-1" ];
				  "33" =[ "HDMI-A-1" ];
				  "34" =[ "HDMI-A-1" ];
				  "35" =[ "HDMI-A-1" ];
				  "36" =[ "HDMI-A-1" ];
				  "37" =[ "HDMI-A-1" ];
				  "38" =[ "HDMI-A-1" ];
				  "39" =[ "HDMI-A-1" ];
				  "40" =[ "HDMI-A-1" ];
				};
				format-icons = {
				  urgent = "";
				  focused = "";
				  default = "";
				};
			};
			"sway/window" = {
				format = "{}";
				max-length = 60;
			};
			"sway/mode" = {
			  format = "<span style=\"italic\">{}  </span>";
        tooltip = false;
			};
			memory = {
				interval = 1;
				format = "<span color=\"#f1fa8c\"></span> {}%";
				tooltip = false;
				on-click = "foot --app-id Float -e htop";
			};
			disk = {
				interval = 60;
				format = "{percentage_used}% 󰋊";
				path = "/";
			};
			idle_inhibitor = {
				format = "{icon}";
				tooltip = false;
				format-icons = {
					activated = "";
					deactivated = "";
				};
			};
			"custom/audio_idle_inhibitor" = {
				format = "{icon}";
				exec = "sway-audio-idle-inhibit --dry-print-both-waybar";
				exec-if = "which sway-audio-idle-inhibit";
				return-type = "json";
				tooltip = false;
				format-icons = {
					input = "";
					output-input = "";
					output = " ";
					none = " ";
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
				on-click = "foot --app-id Float -e sudo powertop";
			};
			"sway/language" = {
        format = "<span color=\"#ff6699\"></span> {shortDescription}";
        tooltip-format = "{long}";
        on-click = "swaymsg input type:keyboard xkb_switch_layout next";
      };
			"custom/powermenu" = {
				on-click = "~/.config/waybar/powermenu.sh";
				format = "<span color=\"#ff5555\">⏻</span>";
				tooltip = false;
			};
			clock = {
				format = "{:%H:%M}";
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
  			    weeks =      "";
  			    weekdays =   "<span color='#ffcc66'><b>{}</b></span>";
  			    today =      "<span color='#ff6699'><b><u>{}</u></b></span>";
  		    };
  	    };
  	    actions = {
  		    on-click-right = "mode";
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
				on-click = "foot --app-id Float -e nmtui";
			};
			"custom/launcher" = {
				on-click = "foot --config ~/.config/foot/foot-solid.ini --app-id=launcher ~/.config/sway/scripts/launcher.sh";
				format = "<span color=\"#ff79c6\">  </span>";
				tooltip = false;
			};
		};
  };
  style = (builtins.readFile ./waybar_style.css);  
}
