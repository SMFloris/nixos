#!/usr/bin/env bash

pushd /home/flow/Pictures/Wallpapers
	pkill wbg
	ls | grep jpg | sort -R | head -1 | xargs -I{} wbg {} & &>/dev/null
popd
