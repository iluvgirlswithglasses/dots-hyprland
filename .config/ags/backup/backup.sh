#!/usr/bin/env bash
# Snapshot the current state of color_generation scripts and active color configs.
# Run this on the source machine; copy the backup/ directory to the target machine
# and run restore.sh there.

set -euo pipefail

BACKUP="$(cd "$(dirname "$0")/pre-update" && pwd)"
mkdir -p "$BACKUP"

backup() {
    local src="$1"
    local dst="$BACKUP$1"
    if [ ! -e "$src" ]; then
        echo "SKIP (not found): $src"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "backed up $src"
}

echo "=== Source scripts ==="
backup "$HOME/.config/ags/scripts/color_generation/paths.sh"
backup "$HOME/.config/ags/scripts/color_generation/colorgen.sh"
backup "$HOME/.config/ags/scripts/color_generation/applycolor.sh"
backup "$HOME/.config/ags/scripts/color_generation/switchwall.sh"
backup "$HOME/.config/ags/scripts/color_generation/switchcolor.sh"
backup "$HOME/.config/ags/scripts/color_generation/generate_colors_material.py"
backup "$HOME/.config/ags/scripts/color_generation/pywal_to_material.scss"
backup "$HOME/.config/ags/scripts/templates/gtk/gtk.css"

echo ""
echo "=== Active color palette ==="
backup "$HOME/.cache/ags/user/color.txt"
backup "$HOME/.cache/ags/user/generated/material_colors.scss"
backup "$HOME/.config/ags/scss/_material.scss"
backup "$HOME/.cache/ags/user/generated/style.css"

echo ""
echo "=== Generated app configs ==="
backup "$HOME/.config/hypr/hyprland/colors.conf"
backup "$HOME/.cache/ags/user/generated/hypr/hyprland/colors.conf"
backup "$HOME/.config/fuzzel/fuzzel.ini"
backup "$HOME/.cache/ags/user/generated/fuzzel/fuzzel.ini"
backup "$HOME/.cache/ags/user/generated/gtk.css"
backup "$HOME/.config/gtk-4.0/gtk.css"
backup "$HOME/.config/gtk-3.0/gtk.css"
backup "$HOME/.cache/ags/user/generated/terminal/sequences.txt"

if [ -f "$HOME/.waterfox/default-profile" ]; then
    waterfox_css="$(cat "$HOME/.waterfox/default-profile")/chrome/ilgwg/color.css"
    backup "$waterfox_css"
fi

echo ""
echo "=== gsettings ==="
{
    echo "gtk-theme=$(gsettings get org.gnome.desktop.interface gtk-theme)"
    echo "color-scheme=$(gsettings get org.gnome.desktop.interface color-scheme)"
} > "$BACKUP/gsettings.txt"
echo "backed up gsettings -> $BACKUP/gsettings.txt"

echo ""
echo "Snapshot written to: $BACKUP"
