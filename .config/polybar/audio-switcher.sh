#!/bin/bash

# Get all audio sinks
get_sinks() {
    pactl list sinks | awk '
        /^Sink #/         { id = substr($2, 2) }
        /Name:/           { name = $2 }
        /Description:/    { desc = substr($0, index($0,$2)); print id "|" name "|" desc }
    '
}

# Get the current default sink
current=$(pactl get-default-sink)

# Build rofi menu entries
entries=""
while IFS='|' read -r id name desc; do
    if [ "$name" = "$current" ]; then
        entries+="▶ $desc\n"
    else
        entries+="  $desc\n"
    fi
done <<< "$(get_sinks)"

# Show rofi and get selection
chosen=$(echo -e "$entries" | sed '/^$/d' | rofi -dmenu -i -p "Audio Output" -theme-str '
    window { width: 400px; }
    listview { lines: 5; }
')

[ -z "$chosen" ] && exit

# Strip the ▶ prefix and whitespace, match back to sink name
chosen_desc=$(echo "$chosen" | sed 's/^[▶ ]*//')

while IFS='|' read -r id name desc; do
    if [ "$desc" = "$chosen_desc" ]; then
        pactl set-default-sink "$name"
        # Move all active streams to the new sink
        pactl list sink-inputs short | awk '{print $1}' | \
            xargs -I{} pactl move-sink-input {} "$name"
        break
    fi
done <<< "$(get_sinks)"
