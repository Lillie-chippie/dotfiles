#!/bin/bash

# Check if playerctl is available
PLAYERCTL="playerctl"
JQ="jq"

if ! command -v $PLAYERCTL &> /dev/null; then
    echo "playerctl not found"
    exit 1
fi

case "$1" in
    "status")
        $PLAYERCTL status 2>/dev/null | grep -E "Playing|Paused" | head -n 1
        ;;
    "toggle")
        $PLAYERCTL play-pause
        ;;
    "next")
        $PLAYERCTL next
        ;;
    "prev")
        $PLAYERCTL previous
        ;;
    "toggle-icon")
         status=$($PLAYERCTL status 2>/dev/null | grep -E "Playing|Paused" | head -n 1)
         if [[ -n "$status" ]]; then
             $JQ -c -n \
                --arg text "$status" \
                --arg alt "$status" \
                --arg tooltip "Play/Pause" \
                --arg class "$status" \
                '{text: $text, alt: $alt, tooltip: $tooltip, class: $class}'
         else
             # Return nothing to hide
             echo ""
         fi
         ;;
    "metadata")
        status=$($PLAYERCTL status 2>/dev/null | grep -E "Playing|Paused" | head -n 1)
        artist=$($PLAYERCTL metadata artist 2>/dev/null)
        title=$($PLAYERCTL metadata title 2>/dev/null)

        if [[ -z "$title" ]]; then title="Unknown Title"; fi
        if [[ -z "$artist" ]]; then artist="Unknown Artist"; fi
        
        if [[ -n "$status" ]]; then
            $JQ -c -n \
                --arg text "$artist - $title" \
                --arg tooltip "$artist - $title ($status)" \
                --arg alt "$status" \
                --arg class "$status" \
                '{text: $text, tooltip: $tooltip, alt: $alt, class: $class}'
        else
            # Return valid empty JSON to prevent waybar errors
            echo "{\"text\": \"\", \"class\": \"stopped\"}"
        fi
        ;;
    "check")
        if $PLAYERCTL status 2>/dev/null | grep -qE "Playing|Paused"; then
            exit 0
        else
            exit 1
        fi
        ;;
esac
