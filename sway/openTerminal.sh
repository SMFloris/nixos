#!/usr/bin/env bash

host="$(whoami)@$(hostname)"
terminalLastSession=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | select(.shell=="xdg_shell") | .name')

if [[ ${terminalLastSession} =~ ^${host}.* ]]; then
  wd=$(echo "$terminalLastSession" | cut -d':' -f2)
  foot --working-directory ${wd/'~'/"$HOME"}
else
  foot
fi
