#!/usr/bin/env bash

language=$(swaymsg -t get_inputs -r | jq '.[] | select(.vendor == 1 and .product == 1) | .xkb_active_layout_name' -r)
echo "${language:0:2}"
