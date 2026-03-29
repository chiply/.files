#!/bin/bash
# Rotate desktop wallpaper to a random image from ~/Wallpapers

WALLPAPER_DIR="$HOME/Wallpapers"

# Find image files
images=()
while IFS= read -r -d '' file; do
    images+=("$file")
done < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' -o -iname '*.webp' \) -print0)

# Exit if no images found
if [ ${#images[@]} -eq 0 ]; then
    exit 0
fi

# Pick a random image
wallpaper="${images[$((RANDOM % ${#images[@]}))]}"

# Set wallpaper on all desktops
osascript -e "
tell application \"System Events\"
    tell every desktop
        set picture to \"$wallpaper\"
    end tell
end tell
"
