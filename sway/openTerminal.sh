#!/usr/bin/env bash

host="$(whoami)@$(hostname)"
focusedWindow=$(swaymsg -t get_tree -r | jq -r '.. | select(.type?) | select(.focused==true) | select(.shell=="xdg_shell")')

appId=$(echo "${focusedWindow}" | jq -r '.app_id')
title=$(echo "${focusedWindow}" | jq -r '.name')

if [[ ${appId} == "Thunar" ]]; then
  thunarSuffix=" - Thunar"
  wd=${title/"$thunarSuffix"/""}
  if [[ ${wd} != ${title} ]]; then
    foot --working-directory ${wd/'~'/"$HOME"}
    exit 0
  fi
fi

if [[ ${title} =~ ^${host}.* ]]; then
  wd=$(echo "$title" | cut -d':' -f2)
  foot --working-directory ${wd/'~'/"$HOME"}
  exit 0
else
  foot
  exit 0
fi
