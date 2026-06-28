#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/ags/scripts/color_generation/paths.sh"

if [ $# -eq 0 ]; then
    echo "Usage: colorgen.sh /path/to/image|#color [--apply]"
    exit 1
fi

mkdir -p "$AGS_GENERATED_DIR"

if [[ "$1" = "#"* ]]; then
    "$COLOR_GEN_PY" --color "$1" \
        --termscheme "$TMPL_TERM_SCHEME" --blend_bg_fg \
        > "$GEN_MATERIAL_SCSS"
else
    "$COLOR_GEN_PY" --path "$1" \
        --termscheme "$TMPL_TERM_SCHEME" --blend_bg_fg \
        --cache "$GEN_COLOR_CACHE" \
        > "$GEN_MATERIAL_SCSS"
fi

if [ "${2:-}" = "--apply" ]; then
    cp "$GEN_MATERIAL_SCSS" "$DEST_MATERIAL_SCSS"
fi

"$APPLYCOLOR_SCRIPT"
