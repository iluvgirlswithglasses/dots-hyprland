#!/usr/bin/env bash
sudo pacman -D --asexplicit \
    aquamarine cairo glib2 glibc glslang hyprcursor hyprgraphics hyprlang \
    hyprutils hyprwayland-scanner hyprwire libdisplay-info libdrm libgcc \
    libglvnd libinput libliftoff libstdc++ libx11 libxcb libxcomposite \
    libxcursor libxfixes libxkbcommon libxrender mesa muparser pango pixman re2 \
    seatd systemd-libs tomlplusplus util-linux-libs wayland wayland-protocols \
    xcb-proto xcb-util xcb-util-errors xcb-util-image xcb-util-keysyms \
    xcb-util-renderutil xcb-util-wm xorg-xwayland
