#!/bin/bash

PLAYERCTL="playerctl"
JQ="jq"

# Check dependencies
if ! command -v "$PLAYERCTL" &>/dev/null; then
    echo "playerctl not found"
    exit 1
fi

if ! command -v "$JQ" &>/dev/null; then
    echo "jq not found"
    exit 1
fi

get_status() {
    $PLAYERCTL status 2>/dev/null | awk '/Playing|Paused/ { print; exit }'
}

case "$1" in
    status)
        get_status
        ;;

    toggle)
        $PLAYERCTL play-pause
        ;;

    next)
        $PLAYERCTL next
        ;;

    prev)
        $PLAYERCTL previous
        ;;

    toggle-icon)
        status="$(get_status)"

        if [[ -n "$status" ]]; then
            $JQ -c -n \
                --arg text "$status" \
                --arg alt "$status" \
                --arg tooltip "Play/Pause" \
                --arg class "$status" \
                '{text: $text, alt: $alt, tooltip: $tooltip, class: $class}'
        else
            echo ""
        fi
        ;;

    metadata)
        status="$(get_status)"
        artist="$($PLAYERCTL metadata artist 2>/dev/null)"
        title="$($PLAYERCTL metadata title 2>/dev/null)"

        [[ -z "$title" ]] && title="Unknown Title"
        [[ -z "$artist" ]] && artist="Unknown Artist"

        if [[ -n "$status" ]]; then
            $JQ -c -n \
                --arg text "$artist - $title" \
                --arg tooltip "$artist - $title ($status)" \
                --arg alt "$status" \
                --arg class "$status" \
                '{text: $text, tooltip: $tooltip, alt: $alt, class: $class}'
        else
            echo '{"text": "", "class": "stopped"}' 2>/dev/null
        fi
        ;;

    check)
        if [[ -n "$(get_status)" ]]; then
            exit 0
        else
            exit 1
        fi
        ;;

    *)
        echo "Usage: $0 {status|toggle|next|prev|toggle-icon|metadata|check}"
        exit 1
        ;;
esac
