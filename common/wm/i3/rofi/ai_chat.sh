#!/usr/bin/env bash
# Terminal command variable
# TERMINAL="kitty"
# TERMINAL="konsole -e"
TERMINAL="alacritty --class AICHAT -e"

# Display Rofi menu and get user selection
selection=$(echo "Chat to AI|Summarize clipboard|Personal Assistant - TODO" | rofi -sep '|' -dmenu -p "Select AI Commands")

# Speak Using Piper TTS
# speak_text="piper --model ~/.config/piper/en_GB-alan-medium.onnx --output-raw | aplay -r 22050 -f S16_LE -t raw"

# Render Markdown in terminal
markdown_renderer="glow"

case "$selection" in
    "Chat to AI")
        # Run the command for chatting to AI
        $TERMINAL bash -c "/home/flow/.npm-global/bin/opencode ~/Dropbox/Chat/ --agent chat < <(echo \"hello, what can you do for me?\")"
        ;;
    "Summarize clipboard")
        # Run the command for summarizing clipboard
        $TERMINAL bash -c "/home/flow/.npm-global/bin/opencode ~/Dropbox/Todo/ --agent todo < <(echo \"Please summarize the following:\")"
        ;;
    "Personal Assistant - TODO")
        # Run the command for personal assistant
        $TERMINAL bash -c "/home/flow/.npm-global/bin/opencode ~/Dropbox/Todo/ --agent todo < <(echo \"hello, what's on my plate today?\")"
        ;;
    *)
        echo "No valid selection made."
        ;;
 esac
