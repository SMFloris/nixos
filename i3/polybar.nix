{ config, pkgs, lib, ... }:

# Created By @icanwalkonwater
# Edited and ported to Nix by Th0rgal

let
  bg-1 = "#12121f";
  bg-2 = "#171728";
  bg-3 = "#1d1d2f";
  bg-4 = "#222236";
  bg-5 = "#29293f";

  fg-1 = "#f4ffff";
  fg-2 = "#f0f3ff";
  fg-3 = "#fcffff";

  grey-1 = "#4f5071";
  grey-2 = "#595b7e";
  grey-3 = "#63658b";

  red-1 = "#de688a";
  red-2 = "#da587d";
  red-3 = "#d74770";

  purple-1 = "#9792dd";
  purple-2 = "#8983d8";
  purple-3 = "#7a73d3";

  blue-1 = "#83a8ec";
  blue-2 = "#729ce9";
  blue-3 = "#608fe6";

  cyan-1 = "#89e6e4";
  cyan-2 = "#78e2e1";
  cyan-3 = "#65dedc";

  green-1 = "#8fe0b4";
  green-2	= "#7fdca9";
  green-3	= "#6fd89e";

  yellow-1 = "#fdf5b0";
  yellow-2 = "#fcf39c";
  yellow-3 = "#fbf088";

  orange-1 = "#e7c188";
  orange-2 = "#e3b878";
  orange-3 = "#e0af67";

  hostname = config.system.hostname;
  hwmonPaths = {                                                     
    "gastly" = "/sys/devices/virtual/thermal/thermal_zone0/hwmon4/temp1_input";                
    "onix" = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";                  
    # Add more hostnames as needed                                   
  };                                                                 
in lib.mkIf (config.host-info.preferred_wm == "i3") {
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };

    script = "polybar -q -r bar &";

    config = {
      "settings" = {
        "screenchange-reload" = true;
        "pseudo-transparency" = true;
      };

      "bar/bar" = {
          width = "100%";
          height = "23pt";
          offset-x = "98%";
          offset-y = "3pt";
          
          background = "#00000000";
          foreground = "${fg-1}";
          
          line-size = "1pt";
          border-size = "5pt";
          border-color = "#00000000";

          padding-left = "0pt";
          padding-right = "0pt";

          module-margin-top = "5pt";
          module-margin-left = "0pt";
          module-margin-right = "0pt";
          
          font-0 = "CaskaydiaCove Nerd Font:size=13;4";
          font-1 = "CaskaydiaCove Nerd Font:size=22;5";
          font-2 = "CaskaydiaCove Nerd Font:size=25;6";
          font-3 = "CaskaydiaCove Nerd Font:size=16;4";
          # font-3 = "Font Awesome 6 Free;3";
          
          modules-left = "spacer left xworkspaces slash space slash space xwindow space right";
          modules-center = "left space date space right";
          modules-right = "left space cpu slash space slash memory slash space slash battery slash space slash temperature slash space slash pulseaudio space slash space slash space systray space slash space slash space ollama space right spacer";
          # modules-left = "left date right spacer left xwindow right"
          # modules-center = "left xworkspaces right"
          # modules-right = "left pulseaudio spacerbg cpu spacerbg memory right spacer left systray right"
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 90;
        low-at = 10;
        battery = "BAT0";
        adapter = "AC";
        poll-interval = 5;
        time-format = "%H:%M";
        format-background = "${bg-1}";
        label-underline = "${fg-1}";
        format-charging = "<animation-charging> <label-charging>";
        format-charging-background = "${bg-1}";
        format-charging-underline = "${fg-1}";
        format-discharging = "<ramp-capacity> <label-discharging>";
        format-discharging-underline = "${fg-1}";
        format-discharging-background = "${bg-1}";
        format-low = "<animation-low> <label-low>";
        format-low-background = "${bg-1}";
        format-low-foreground = "${red-1}";
        format-low-underline = "${red-1}";

        label-charging = "%percentage%%";
        label-discharging = "%percentage%%";
        label-full = "%percentage%%";
        label-low = "%percentage%%";

        ramp-capacity-0 = " ";
        ramp-capacity-1 = " ";
        ramp-capacity-2 = " ";
        ramp-capacity-3 = " ";
        ramp-capacity-4 = " ";

        bar-capacity-width = "10 ";

        animation-charging-0 = " ";
        animation-charging-1 = " ";
        animation-charging-2 = " ";
        animation-charging-3 = " ";
        animation-charging-4 = " ";
        animation-charging-framerate = "750 ";

        animation-discharging-0 = " ";
        animation-discharging-1 = " ";
        animation-discharging-2 = " ";
        animation-discharging-3 = " ";
        animation-discharging-4 = " ";
        animation-discharging-framerate = "500 ";

        animation-low-0 = "! ";
        animation-low-1 = " ";
        animation-low-framerate = "200 ";
      };

      "module/spacer" = {
        type = "custom/text";
        format = "<label>";
        label = " ";
      };

      "module/spacerbg" = {
        type = "custom/text";
        format = "<label>";
        format-background = "${bg-1}";
        format-padding = "4pt";
        label = " ";
      };

      "module/left" = {
        type = "custom/text";
        format = "<label>";
        format-foreground = "${bg-1}";
        # format-padding = "4pt";
        label = "";
        label-font = 2;
      };

      "module/right" = {
        type = "custom/text";
        format = "<label>";
        format-foreground = "${bg-1}";
        # format-padding = "4pt";
        label = "";
        label-font = 2;
      };

      "module/slash" = {
        type = "custom/text";
        content = "/";
        content-background = "${bg-1}";
        content-foreground = "${bg-4}";
        content-font = 3;
      };

      "module/line" = {
        type = "custom/text";
        content = "|";
        content-background = "${bg-1}";
        content-foreground = "${fg-1}";
        content-font = 3;
      };

      "module/space" = {
        type = "custom/text";
        content = " ";
        content-background = "${bg-1}";
        content-foreground = "${bg-1}";
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        format = "<label>";
        format-background = "${bg-1}";
        format-foreground = "${fg-2}";
        label = "%title:0:60:...%";
        label-empty = "flow@onix";
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        icon-0 = "1;I";
        icon-1 = "2;II";
        icon-2 = "3;III";
        icon-3 = "4;IV";
        icon-4 = "5;V";
        icon-5 = "6;VI";
        icon-6 = "7;VII";
        icon-7 = "8;VIII";
        icon-8 = "9;IX";
        icon-9 = "10;X";
        format = "<label-state>";
        icon-default = "%index%";

        label-active = "%icon%";
        label-active-background = "${bg-1}";
        label-active-foreground = "${fg-1}";
        label-active-padding = "1";

        label-occupied = "%icon%";
        label-occupied-background = "${bg-1}";
        label-occupied-foreground = "${grey-1}";
        label-occupied-padding = "1";

        label-empty = "%icon%";
        label-empty-background = "${bg-1}";
        label-empty-foreground = "${fg-1}";
        label-empty-padding = "1";

        label-urgent = "%icon%";
        label-urgent-background = "${bg-1}";
        label-urgent-foreground = "${red-1}";
        label-urgent-padding = "1";
        #
        # label-active-font = 3;
        # label-occupied-font = 3;
        # label-empty-font = 3;
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = false;
        interval = 1;

        format-volume-prefix = " ";
        format-volume-prefix-underline = "${purple-1}";
        format-volume-prefix-background = "${bg-1}";
        format-volume-prefix-foreground = "${purple-2}";
        # ;format-volume-font = 4;
        format-volume = "<label-volume>";
        format-volume-background = "${bg-1}";
        format-volume-foreground = "${fg-3}";
        
        label-volume = " %percentage%%";
        label-volume-underline = "${purple-1}";
        label-volume-background = "${bg-1}";
        label-volume-foreground = "${fg-3}";
        
        label-muted = "󰝟";
        label-muted-underline = "${red-2}";
        # ;label-muted-font = 4
        label-muted-foreground = "${fg-3}";
        label-muted-background = "${bg-1}";

        click-left = "pavucontrol";
      };
      
      "module/filesystem" = {
        type = "internal/fs";
        interval = "25";
      
        mount-0 = "/";
        format-mounted-prefix = " ";
        format-mounted-prefix-underline = "${purple-1}";
        format-mounted-prefix-background = "${bg-1}";
        format-mounted-prefix-foreground = "${purple-2}";
        label-mounted = "%used%";
        label-mounted-underline = "${purple-1}";
        label-mounted-background = "${bg-1}";
        label-mounted-foreground = "${fg-1}";
      };
      
      "module/cpu" = {
        type = "internal/cpu";
        interval = "2";
        format-prefix = " ";
        format-prefix-underline = "${cyan-2}";
        format-prefix-foreground = "${cyan-2}";
        format-background = "${bg-1}";
        format = "<label> ";
        label = " %percentage%%";
        label-underline = "${cyan-2}";
        label-foreground = "${fg-1}";
      };
      
      "module/temperature" = {
        type = "internal/temperature";
        interval = 1;
        thermal-zone = 0;
        hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";
        warn-temperature = 65;
        units = true;
      
        format = "<label>";
        format-prefix = " ";
        format-prefix-underline = "${blue-1}";
        format-prefix-background = "${bg-1}";
        format-prefix-foreground = "${blue-2}";
      
        format-warn = "<label-warn>";
        format-warn-prefix = " ";
        format-warn-prefix-underline = "${yellow-3}";
        format-warn-prefix-background = "${bg-1}";
        format-warn-prefix-foreground = "${yellow-3}";
      
        label = "%temperature-c%";
        label-underline = "${blue-1}";
        label-background = "${bg-1}";
        label-foreground = "${fg-1}";
      
        label-warn = "%temperature-c%";
        label-warn-underline = "${yellow-3}";
        label-warn-background = "${bg-1}";
        label-warn-foreground = "${fg-1}";
      };

      "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = " ";
          format-prefix-foreground = "${red-2}";
          format-prefix-background = "${bg-1}";
          format-background = "${bg-1}";
          label = " %percentage_used:2%%";
          label-underline = "${red-2}";
          format-prefix-underline = "${red-2}";
          label-foreground = "${fg-1}";
      };

      "module/systray" = {
        type = "internal/tray";
        format-background = "${bg-1}";
        tray-size = "100%:-5pt";
        tray-spacing = "4pt";
        tray-background = "${bg-1}";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%b %e, %H:%M";
        # date-alt = "%Y-%m-%d %H:%M:%S";
        label = "%{A1:${pkgs.gnome-clocks}/bin/gnome-clocks:}%date%%{A}";
        label-foreground = "${fg-3}";
        label-background = "${bg-1}";
      };

      "module/ollama" = {
        type = "custom/script";

        exec = "if [[ $(/run/current-system/systemd/bin/systemctl --user is-active ollama.service) == \"active\" ]]; then echo ''; else echo ' ' && exit 1; fi";

        interval = 1;

        format = "<label>";
        format-fail = "<label-fail>";
        format-background = "${bg-1}";

        label = "%output% ";
        label-background = "${bg-1}";
        label-foreground = "${green-1}";

        label-fail = "%output% ";
        label-fail-background = "${bg-1}";
        label-fail-foreground = "${red-2}";

        click-right = "/run/current-system/systemd/bin/systemctl --user stop ollama.service";
        click-left = "/run/current-system/systemd/bin/systemctl --user start ollama.service";
      };
    };
  };
}
