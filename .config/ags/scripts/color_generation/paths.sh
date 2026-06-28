# Shared path definitions for color_generation scripts.
# Source this file; do not execute it directly.

AGS_DIR="$HOME/.config/ags"
AGS_CACHE_DIR="$HOME/.cache/ags/user"
AGS_GENERATED_DIR="$AGS_CACHE_DIR/generated"

# Scripts
COLOR_GEN_PY="$AGS_DIR/scripts/color_generation/generate_colors_material.py"
COLORGEN_SCRIPT="$AGS_DIR/scripts/color_generation/colorgen.sh"
APPLYCOLOR_SCRIPT="$AGS_DIR/scripts/color_generation/applycolor.sh"

# Template sources
TMPL_TERM_SCHEME="$AGS_DIR/scripts/templates/terminal/scheme-base.json"
TMPL_TERM_SEQ="$AGS_DIR/scripts/templates/terminal/sequences.txt"
TMPL_FUZZEL="$AGS_DIR/scripts/templates/fuzzel/fuzzel.ini"
TMPL_HYPRLAND="$AGS_DIR/scripts/templates/hypr/hyprland/colors.conf"
TMPL_GRADIENCE="$AGS_DIR/scripts/templates/gradience/preset.json"
TMPL_SHYFOX="$AGS_DIR/scripts/templates/ilgwg-shyfox-color.css"

# Generated (cache stage)
GEN_MATERIAL_SCSS="$AGS_GENERATED_DIR/material_colors.scss"
GEN_STYLE_CSS="$AGS_GENERATED_DIR/style.css"
GEN_FUZZEL="$AGS_GENERATED_DIR/fuzzel/fuzzel.ini"
GEN_TERM_SEQ="$AGS_GENERATED_DIR/terminal/sequences.txt"
GEN_HYPRLAND="$AGS_GENERATED_DIR/hypr/hyprland/colors.conf"
GEN_GRADIENCE="$AGS_GENERATED_DIR/gradience/preset.json"
GEN_COLOR_CACHE="$AGS_CACHE_DIR/color.txt"

# Destinations (final config locations)
DEST_MATERIAL_SCSS="$AGS_DIR/scss/_material.scss"
DEST_MAIN_SCSS="$AGS_DIR/scss/main.scss"
DEST_FUZZEL="$HOME/.config/fuzzel/fuzzel.ini"
DEST_HYPRLAND="$HOME/.config/hypr/hyprland/colors.conf"
DEST_GRADIENCE_PRESETS="$HOME/.config/presets"

# User config
WALLPAPER_DIR="$HOME/r/wallpaper"
WATERFOX_PROFILE_PTR="$HOME/.waterfox/default-profile"
