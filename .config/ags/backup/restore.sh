#!/usr/bin/env bash
# Restore color_generation scripts and color configs from the pre-update snapshot.
# Safe to run on a fresh machine; skips any file not present in the backup.

set -euo pipefail

BACKUP="$(cd "$(dirname "$0")/pre-update" && pwd)"

if [ ! -d "$BACKUP" ]; then
    echo "ERROR: Backup directory not found: $BACKUP"
    exit 1
fi

restore() {
    local src="$BACKUP$1"
    local dst="$1"
    if [ ! -f "$src" ]; then
        echo "SKIP (not in backup): $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "restored $dst"
}

echo "=== Source scripts ==="
restore "$HOME/.config/ags/scripts/color_generation/paths.sh"
restore "$HOME/.config/ags/scripts/color_generation/colorgen.sh"
restore "$HOME/.config/ags/scripts/color_generation/applycolor.sh"
restore "$HOME/.config/ags/scripts/color_generation/switchwall.sh"
restore "$HOME/.config/ags/scripts/color_generation/switchcolor.sh"
restore "$HOME/.config/ags/scripts/color_generation/generate_colors_material.py"
restore "$HOME/.config/ags/scripts/color_generation/pywal_to_material.scss"
restore "$HOME/.config/ags/scripts/templates/gtk/gtk.css"
chmod +x \
    "$HOME/.config/ags/scripts/color_generation/colorgen.sh" \
    "$HOME/.config/ags/scripts/color_generation/applycolor.sh" \
    "$HOME/.config/ags/scripts/color_generation/switchwall.sh" \
    "$HOME/.config/ags/scripts/color_generation/switchcolor.sh" \
    "$HOME/.config/ags/scripts/color_generation/generate_colors_material.py"

echo ""
echo "=== Active color palette ==="
restore "$HOME/.cache/ags/user/color.txt"
restore "$HOME/.cache/ags/user/generated/material_colors.scss"
restore "$HOME/.config/ags/scss/_material.scss"
restore "$HOME/.cache/ags/user/generated/style.css"

echo ""
echo "=== Generated app configs ==="
restore "$HOME/.config/hypr/hyprland/colors.conf"
restore "$HOME/.cache/ags/user/generated/hypr/hyprland/colors.conf"
restore "$HOME/.config/fuzzel/fuzzel.ini"
restore "$HOME/.cache/ags/user/generated/fuzzel/fuzzel.ini"
restore "$HOME/.cache/ags/user/generated/gtk.css"
restore "$HOME/.config/gtk-4.0/gtk.css"
restore "$HOME/.config/gtk-3.0/gtk.css"
restore "$HOME/.cache/ags/user/generated/terminal/sequences.txt"

if [ -f "$HOME/.waterfox/default-profile" ]; then
    waterfox_css="$(cat "$HOME/.waterfox/default-profile")/chrome/ilgwg/color.css"
    restore "$waterfox_css"
fi

echo ""
echo "=== gsettings ==="
gsettings_file="$BACKUP/gsettings.txt"
if [ -f "$gsettings_file" ]; then
    gtk_theme=$(grep '^gtk-theme=' "$gsettings_file" | cut -d= -f2-)
    color_scheme=$(grep '^color-scheme=' "$gsettings_file" | cut -d= -f2-)
    gtk_theme="${gtk_theme//\'/}"
    color_scheme="${color_scheme//\'/}"
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
    echo "restored gsettings (gtk-theme=$gtk_theme, color-scheme=$color_scheme)"
else
    echo "SKIP: gsettings backup not found"
fi

echo ""
echo "Done. To reload AGS styles run:"
echo "  ags run-js \"App.resetCss(); App.applyCss('\$HOME/.cache/ags/user/generated/style.css');\""
