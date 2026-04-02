#!/bin/bash
current=$(ibus engine)
if [ "$current" = "Bamboo" ]; then
    ibus engine xkb:us::eng
    rm "$STATE_FILE"
else
    ibus engine Bamboo
    touch "$STATEFILE"
fi
