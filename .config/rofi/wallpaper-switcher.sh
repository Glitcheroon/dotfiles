#!/usr/bin/env bash

# Configuration
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"
THUMBNAIL_SIZE="400x300"
COLUMNS=4
LINES=3

shopt -s nullglob

mkdir -p "$CACHE_DIR"

generate_thumbnails() {
    for img in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp; do
        [ -f "$img" ] || continue
        filename=$(basename "$img")
        thumb="$CACHE_DIR/$filename"
        if [ ! -f "$thumb" ]; then
            convert "$img" -thumbnail "$THUMBNAIL_SIZE^" -gravity center \
                -extent "$THUMBNAIL_SIZE" "$thumb" 2>/dev/null
        fi
    done
}

set_wallpaper() {
    local img="$1"
    feh --bg-scale "$img"
    echo "$img" > "$HOME/.fehbg_last"
}

generate_thumbnails

options=""
for img in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    name="${filename%.*}"
    thumb="$CACHE_DIR/$filename"
    # Use += only after first entry to avoid leading newline
    if [ -z "$options" ]; then
        options="${name}\x00icon\x1f${thumb}"
    else
        options+="\n${name}\x00icon\x1f${thumb}"
    fi
done

chosen=$(echo -e "$options" | rofi \
    -dmenu \
    -i \
    -show-icons \
    -theme-str "
        window {
            width: 92%;
            height: 90%;
        }
        listview {
            columns: $COLUMNS;
            lines: $LINES;
            scrollbar: false;
            spacing: 8px;
        }
        element {
            orientation: vertical;
            border-radius: 8px;
            padding: 6px;
        }
        element-icon {
            size: 12em;
            border-radius: 4px;
        }
        element-label {
            horizontal-align: 0.5;
            padding: 4px 0 0 0;
        }
        element selected {
            border-radius: 8px;
        }
    " \
    -p "Wallpaper")

[ -z "$chosen" ] && exit 0

for img in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp; do
    [ -f "$img" ] || continue
    name=$(basename "${img%.*}")
    if [ "$name" = "$chosen" ]; then
        set_wallpaper "$img"
        break
    fi
done
