#!/usr/bin/env bash

maim -s -u /tmp/ocr.jpg && easyocr -l en -f /tmp/ocr.jpg --paragraph True --output_format json | jq '.text' -r | xclip -i && notify-send "Text copied to clipboard" "The text has been succesfully copied. Paste it wherever you'd like"
