#!/usr/bin/env bash

echo "Called with: '$1'" >> /tmp/power.log

if [ -z "$1" ]; then
  # Output power options for Rofi
  echo -e "Shutdown\0icon\x1fsystem-shutdown"
  echo -e "Restart\0icon\x1fsystem-reboot"
  echo -e "Logoff\0icon\x1fsystem-log-out"
  echo -e "Suspend\0icon\x1fmedia-playback-pause"
  echo -e "Hibernate\0icon\x1fmedia-playback-pause"
  echo -e "Lock\0icon\x1fsystem-lock-screen"
else
  # Handle selection
  selected="$1"
  case "$selected" in
    "Shutdown")
      systemctl poweroff
      ;;
    "Restart")
      systemctl reboot
      ;;
    "Logoff")
      i3-msg exit
      ;;
    "Suspend")
      systemctl suspend
      ;;
    "Hibernate")
      systemctl hibernate
      ;;
    "Lock")
      i3lock
      ;;
    *)
      echo "Unknown option: $selected"
      ;;
  esac
fi