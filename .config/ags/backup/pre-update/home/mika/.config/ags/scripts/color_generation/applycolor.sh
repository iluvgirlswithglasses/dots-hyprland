#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/ags/scripts/color_generation/paths.sh"

term_alpha=100

mkdir -p "$AGS_GENERATED_DIR"

colorlist=()
colorvalues=()

apply_fuzzel() {
    if [ ! -f "$TMPL_FUZZEL" ]; then
        echo "Template file not found for Fuzzel. Skipping."
        return
    fi
    mkdir -p "$(dirname "$GEN_FUZZEL")"
    cp "$TMPL_FUZZEL" "$GEN_FUZZEL"
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$GEN_FUZZEL"
    done
    cp "$GEN_FUZZEL" "$DEST_FUZZEL"
}

apply_term() {
    if [ ! -f "$TMPL_TERM_SEQ" ]; then
        echo "Template file not found for Terminal. Skipping."
        return
    fi
    mkdir -p "$(dirname "$GEN_TERM_SEQ")"
    cp "$TMPL_TERM_SEQ" "$GEN_TERM_SEQ"
    for i in "${!colorlist[@]}"; do
        sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$GEN_TERM_SEQ"
    done
    sed -i "s/\$alpha/$term_alpha/g" "$GEN_TERM_SEQ"
    for file in /dev/pts/*; do
        if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
            cat "$GEN_TERM_SEQ" > "$file"
        fi
    done
}

apply_hyprland() {
    if [ ! -f "$TMPL_HYPRLAND" ]; then
        echo "Template file not found for Hyprland colors. Skipping."
        return
    fi
    mkdir -p "$(dirname "$GEN_HYPRLAND")"
    cp "$TMPL_HYPRLAND" "$GEN_HYPRLAND"
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$GEN_HYPRLAND"
    done
    cp "$GEN_HYPRLAND" "$DEST_HYPRLAND"
}

apply_gtk() {
    if [ ! -f "$TMPL_GTK" ]; then
        echo "Template file not found for GTK. Skipping."
        return
    fi
    cp "$TMPL_GTK" "$GEN_GTK"
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$GEN_GTK"
    done
    mkdir -p "$(dirname "$DEST_GTK4")" "$(dirname "$DEST_GTK3")"
    cp "$GEN_GTK" "$DEST_GTK4"
    cp "$GEN_GTK" "$DEST_GTK3"
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

apply_shyfox() {
    if [ ! -f "$WATERFOX_PROFILE_PTR" ]; then
        echo "[For Shyfox users] Waterfox default profile is not set"
        echo "Please set the path of your default Waterfox profile in $WATERFOX_PROFILE_PTR"
        return
    fi
    local color_dir
    color_dir="$(cat "$WATERFOX_PROFILE_PTR")/chrome/ilgwg"
    local color_file="${color_dir}/color.css"
    if [ ! -d "${color_dir}" ]; then
        echo "Shyfox is not installed. Skipping."
        return
    fi
    cp "$TMPL_SHYFOX" "${color_file}"
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "${color_file}"
    done
}

apply_ags() {
    sass "$DEST_MAIN_SCSS" "$GEN_STYLE_CSS"
    ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'
    ags run-js "App.resetCss(); App.applyCss('$GEN_STYLE_CSS');"
}

IFS=$'\n'
colorlist=( $(cut -d: -f1 "$DEST_MATERIAL_SCSS") )
colorvalues=( $(cut -d: -f2 "$DEST_MATERIAL_SCSS" | cut -d ' ' -f2 | cut -d ";" -f1) )

apply_ags &
apply_hyprland &
apply_gtk &
apply_fuzzel &
apply_term &
apply_shyfox &
wait
