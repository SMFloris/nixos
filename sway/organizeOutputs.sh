#!/usr/bin/env bash


outputs=("eDP-1" "DP-2" "DP-1" "HDMI-A-1")

i=0
for output in ${outputs[@]}
do
  swaymsg workspace $((1+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((2+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((3+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((4+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((5+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((6+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((7+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((8+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((9+i*10)) output ${output} "eDP-1"
  swaymsg workspace $((10+i*10)) output ${output} "eDP-1"
  i=$((i+1))
done

