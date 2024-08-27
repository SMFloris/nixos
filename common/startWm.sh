#!/usr/bin/env bash

if [ "$PREFERRED_WM" == "sway" ]; then
  sway
  exit $?
fi

if [ "$PREFERRED_WM" == "i3" ]; then
  sx ~/.xinitrc
  exit $?
fi

echo "No wm selected"
exit 1
