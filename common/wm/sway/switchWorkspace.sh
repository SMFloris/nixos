#/usr/bin/env bash

focusedOutput=$(swaymsg -t get_outputs -r | jq ".[] | select(.focused==true) | .name" | xargs)


outputs=("eDP-1" "DP-3" "DP-2" "DP-1" "HDMI-A-1")

i=0
for output in ${outputs[@]}
do
  if [[ "$focusedOutput" == "$output" ]]; then
    break
  fi
  i=$((i+1))
done

if [[ "$2" == "move" ]]; then
  swaymsg "move to workspace $(($1+$i*10))"
  exit $?
fi

swaymsg "workspace $(($1+$i*10))"
