#!/usr/bin/env bash

lightdark=$( sed -n '1p' ~/.cache/ags/user/colormode.txt )

if [ $lightdark == 'light' ]; then
    lightdark='dark'
else
    lightdark='light'
fi

sed -i "1s/.*/${lightdark}/" ~/.cache/ags/user/colormode.txt
bash ~/.config/ags/scripts/color_generation/switchcolor.sh

