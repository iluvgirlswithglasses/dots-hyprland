#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/ags/scripts/color_generation/paths.sh"

if [ "${1:-}" == "--noswitch" ]; then
    imgpath=$(swww query | head -1 | awk -F 'image: ' '{print $2}')
else
    cd "$WALLPAPER_DIR"
    imgpath=$(yad --width 800 --height 400 --file --title='Choose wallpaper' --add-preview --large-preview)

    if [ "$imgpath" == '' ]; then
        echo 'Aborted'
        exit 0
    fi
fi

"$COLORGEN_SCRIPT" "${imgpath}" --apply
