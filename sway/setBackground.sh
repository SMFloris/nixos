#!/usr/bin/env bash

pushd /home/flow/Pictures/Wallpapers
	pkill wbg
	find ./ -name "*.jpg" -o -name "*.png" | sort -R | head -1 | xargs -I{} wbg {} & &>/dev/null
popd
