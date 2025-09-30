
This fork survives to keep the old looks and feels of illogical impulse intact. I just simply prefer the vibrant, glassy feels of the old illogical impulse.

![img](./img.png)
<details>
  <summary>View Desktop Showcase</summary>
  <img width="3000" height="1920" alt="image" src="https://github.com/user-attachments/assets/34592aec-dbe4-49f0-8c55-89aa98b162f2" />
</details>


# Key differences

|                       | [end-4's original](https://github.com/end-4/dots-hyprland/)   | This fork                                                     |
| --------------------- | ------------------------------------------------------------- | ------------------------------------------------------------- |
| Desktop Environment   | KDE                                                           | GTK                                                           |
| Keybinds              | Windows-inspired                                              | Some random bullshit                                          |
| Window layout         | Dwindle                                                       | Master                                                        |
| Color schemes         | dark/light, opaque/transparent, and many palettes             | dark/light, transparent, and only vibrant palette             |
| Bar                   | Quickshell                                                    | My [AGS v1.8.2 fork](https://github.com/iluvgirlswithglasses/ags-v1) |
| Browser               | Chromium (use system gtk/kde theme)                           | My [ShyFox fork](https://github.com/iluvgirlswithglasses/shyfox) with automatically generated color scheme |
| Hyprlock              | Practical, professional lock UI                               | Anime shenanigans                                             |


# Install

You'd need to do two steps:

1. Get some extra dependencies from the AUR:

```
yay -S anyrun-git gjs gradience gtksourceview3 python-material-color-utilities xorg-xrandr yad
yay -S waterfox-bin     # (optional) this is the default browser of this fork
```

2. Install [patched AGS v1](https://github.com/iluvgirlswithglasses/ags-v1) (please pray that my patch doesn't break)

