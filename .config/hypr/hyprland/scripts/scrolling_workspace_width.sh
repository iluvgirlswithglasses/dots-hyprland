#!/usr/bin/env bash
set -u

apply_width() {
    local workspace_id layout width

    workspace_id="$(hyprctl activeworkspace -j | jq -r '.id // empty')" || return 0
    layout="$(hyprctl activeworkspace -j | jq -r '.tiledLayout // empty')" || return 0

    [[ "$layout" == "scrolling" ]] || return 0

    case "$workspace_id" in
        8) width="0.333" ;;
        9|10) width="0.5" ;;
        *) return 0 ;;
    esac

    hyprctl dispatch layoutmsg "colresize all $width" >/dev/null 2>&1 || true
}

if [[ "${1:-}" == "--apply" ]]; then
    apply_width
    exit 0
fi

socket_path="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:?}/.socket2.sock"
lock_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr-scrolling-workspace-width.lock"

if ! mkdir "$lock_dir" 2>/dev/null; then
    if [[ -r "$lock_dir/pid" ]] && kill -0 "$(cat "$lock_dir/pid")" 2>/dev/null; then
        exit 0
    fi

    rm -f "$lock_dir/pid"
    rmdir "$lock_dir" 2>/dev/null || exit 0
    mkdir "$lock_dir" 2>/dev/null || exit 0
fi

printf '%s\n' "$$" > "$lock_dir/pid"

cleanup() {
    rm -f "$lock_dir/pid"
    rmdir "$lock_dir"
}

trap cleanup EXIT

apply_width

while true; do
    nc -U "$socket_path" 2>/dev/null | while IFS= read -r event; do
        case "$event" in
            workspace*|focusedmon*|openwindow*|closewindow*|movewindow*)
                apply_width
                ;;
        esac
    done

    sleep 1
done
