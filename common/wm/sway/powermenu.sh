#!/usr/bin/env bash

entries="⇠\tLogout\n⏾\tSuspend\n󰜉\tReboot\n⏻\tShutdown"

selected=$(echo -e $entries|wofi --width 300 --height 200 -b -s ~/.config/wofi/powermenu.css -D dynamic_lines=true -D hide_search=true --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  logout)
    swaymsg exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
