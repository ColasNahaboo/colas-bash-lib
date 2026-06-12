#!/bin/bash

# Functions to copy to/from the clipboard, working both in X11 or Wayland.
# On X11 uses xclip or xsel
# On Wayland, uses the wl-clipboard tools: wl-copy & wl-paste

# Copied its argument into the clipboard
# Clear the clipboard: by clipboard-copy ''
# return success (0) or error (1)
clipboard-copy() {
    local input_str="$1"
    
    if [ "$XDG_SESSION_TYPE" = "wayland" ] &&
           command -v wl-copy >/dev/null; then
        echo -n "$input_str" | wl-copy
    elif command -v xclip >/dev/null; then
        echo -n "$input_str" | xclip -selection clipboard
    elif command -v xsel >/dev/null; then
        echo -n "$input_str" | xsel --clipboard --input
    else
        return 1
    fi
}

# Function to copy from clipboard to stdout
clipboard-paste() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ] &&
           command -v wl-paste >/dev/null; then
        wl-paste -n
    elif command -v xclip >/dev/null; then
        xclip -selection clipboard -o
    elif command -v xsel >/dev/null; then
        xsel --clipboard --output
    fi
}
