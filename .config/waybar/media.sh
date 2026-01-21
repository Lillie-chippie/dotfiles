#!/bin/bash

# Check if playerctl is available
if ! command -v playerctl &> /dev/null; then
    echo "playerctl not found"
    exit 1
fi

case "$1" in
    "status")
        # Returns current status: Playing, Paused, or Stopped
        playerctl status 2>/dev/null | grep -E "Playing|Paused" | head -n 1
        ;;
    "toggle")
        playerctl play-pause
        ;;
    "next")
        playerctl next
        ;;
    "prev")
        playerctl previous
        ;;
    "toggle-icon")
         # Returns JSON for Play/Pause icon
         status=$(playerctl status 2>/dev/null | grep -E "Playing|Paused" | head -n 1)
         if [[ -z "$status" ]]; then status="Paused"; fi # Default to Paused icon if unsure (so it shows Play button)
         
         # Alt is used for format-icons key
         echo "{\"text\": \"$status\", \"alt\": \"$status\", \"tooltip\": \"Play/Pause\", \"class\": \"$status\"}"
         ;;
    "metadata")
        # Returns JSON with title, artist, and status for Waybar tooltip/label
        # We only want to show if status is Playing or Paused (not Stopped)
        status=$(playerctl status 2>/dev/null)
        
        if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
             title=$(playerctl metadata title 2>/dev/null | sed 's/&/&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
             artist=$(playerctl metadata artist 2>/dev/null | sed 's/&/&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
             
             # Fallback if empty
             if [[ -z "$title" ]]; then title="Unknown Title"; fi
             if [[ -z "$artist" ]]; then artist="Unknown Artist"; fi

             # Output JSON
             echo "{\"text\": \"$artist - $title\", \"tooltip\": \"$artist - $title ($status)\", \"class\": \"$status\", \"alt\": \"$status\"}"
        else
            # Empty output to hide module
            echo "" 
        fi
        ;;
    "check")
        # Exit success (0) if ANY player is Playing or Paused
        if playerctl status 2>/dev/null | grep -qE "Playing|Paused"; then
            exit 0
        else
            exit 1
        fi
        ;;
esac
