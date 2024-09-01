#!/usr/bin/env bash

set -x

host="$(whoami)@$(hostname)"
focusedWindow=$(i3-msg -t get_tree -r | jq -r '.. | select(.type?) | select(.focused==true)')

appId=$(echo "${focusedWindow}" | jq -r '.window_properties.instance')
title=$(echo "${focusedWindow}" | jq -r '.name')

if [[ ${appId} == "Thunar" ||  ${appId} == "thunar" ]]; then
  thunarSuffix=" - Thunar"
  wd=${title/"$thunarSuffix"/""}
  if [[ ${wd} != ${title} ]]; then
    alacritty --working-directory ${wd/'~'/"$HOME"}
    exit 0
  fi
fi

if [[ ${title} =~ ^${host}.* ]]; then
  wd=$(echo "$title" | cut -d':' -f2 | xargs)
  wd=${wd/'~'/"$HOME"}
  if [ -d "$wd" ]; then
    alacritty --working-directory  ${wd}
    exit 0
  else
    wd=$(basename "$wd")
    alacritty --working-directory ${wd}
    exit 0
  fi
fi

alacritty
exit 0

