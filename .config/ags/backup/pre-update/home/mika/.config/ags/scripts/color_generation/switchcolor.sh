#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/ags/scripts/color_generation/paths.sh"

if [ "$1" == "--pick" ]; then
    color=$(hyprpicker --no-fancy)
else
    color=$(cut -f1 "$GEN_COLOR_CACHE")
fi

"$COLORGEN_SCRIPT" "${color}" --apply
