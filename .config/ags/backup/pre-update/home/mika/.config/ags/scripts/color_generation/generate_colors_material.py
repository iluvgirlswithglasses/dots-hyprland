#!/usr/bin/env python3

import argparse
import json
import math
from collections.abc import Sequence
from dataclasses import dataclass

from PIL import Image
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
from materialyoucolor.score.score import Score
from materialyoucolor.utils.color_utils import argb_from_rgb, rgba_from_argb
from materialyoucolor.utils.math_utils import (
    difference_degrees,
    rotation_direction,
    sanitize_degrees_double,
)

DARKMODE: bool = True
TRANSPARENT: bool = True

SUCCESS_COLORS: dict[str, str] = {
    "success": "#B5CCBA",
    "onSuccess": "#213528",
    "successContainer": "#374B3E",
    "onSuccessContainer": "#D1E9D6",
}


@dataclass
class ImageColorResult:
    argb: int
    orig_width: int
    orig_height: int
    scaled_width: int
    scaled_height: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Material You color generation script")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--path", type=str, help="generate colorscheme from image")
    source.add_argument("--color", type=str, help="generate colorscheme from hex color")
    parser.add_argument("--size", type=int, default=128, help="bitmap image size")
    parser.add_argument("--harmony", type=float, default=0.8, help="(0-1) terminal color hue shift towards accent")
    parser.add_argument("--harmonize_threshold", type=float, default=100, help="(0-180) max angle for hue shift")
    parser.add_argument("--term_fg_boost", type=float, default=0.35, help="terminal foreground separation from background")
    parser.add_argument("--blend_bg_fg", action="store_true", help="shift terminal background/foreground towards accent")
    parser.add_argument("--termscheme", type=str, default=None, help="JSON file with terminal color scheme")
    parser.add_argument("--cache", type=str, default=None, help="file path to cache the generated accent color")
    parser.add_argument("--debug", action="store_true", help="print debug info instead of SCSS")
    return parser.parse_args()


def rgba_to_hex(rgba: Sequence[float]) -> str:
    return "#{:02X}{:02X}{:02X}".format(int(rgba[0]), int(rgba[1]), int(rgba[2]))


def argb_to_hex(argb: int) -> str:
    return "#{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)))


def hex_to_argb(hex_code: str) -> int:
    return argb_from_rgb(
        int(hex_code[1:3], 16),
        int(hex_code[3:5], 16),
        int(hex_code[5:], 16),
    )


def display_color(rgba: Sequence[float]) -> str:
    r, g, b = int(rgba[0]), int(rgba[1]), int(rgba[2])
    return f"\x1B[38;2;{r};{g};{b}m\x1b[7m   \x1b[7m\x1B[0m"


def calculate_optimal_size(width: int, height: int, bitmap_size: int) -> tuple[int, int]:
    image_area = width * height
    bitmap_area = bitmap_size ** 2
    scale = math.sqrt(bitmap_area / image_area) if image_area > bitmap_area else 1
    return max(1, round(width * scale)), max(1, round(height * scale))


def harmonize(
    design_color: int,
    source_color: int,
    threshold: float,
    harmony: float,
) -> int:
    from_hct = Hct.from_int(design_color)
    to_hct = Hct.from_int(source_color)
    diff = difference_degrees(from_hct.hue, to_hct.hue)
    rotation = min(diff * harmony, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation * rotation_direction(from_hct.hue, to_hct.hue)
    )
    return Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()


def boost_chroma_tone(argb: int, chroma: float = 1.0, tone: float = 1.0) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma * chroma, hct.tone * tone).to_int()


def load_color_from_image(path: str, size: int, cache: str | None) -> ImageColorResult:
    image = Image.open(path)
    orig_w, orig_h = image.size
    scaled_w, scaled_h = calculate_optimal_size(orig_w, orig_h, size)
    if scaled_w < orig_w or scaled_h < orig_h:
        image = image.resize((scaled_w, scaled_h), Image.Resampling.BICUBIC)
    colors = QuantizeCelebi(list(image.getdata()), 128)
    argb = Score.score(colors)[0]
    if cache is not None:
        with open(cache, "w") as f:
            f.write(argb_to_hex(argb))
    return ImageColorResult(argb, orig_w, orig_h, scaled_w, scaled_h)


def generate_material_colors(argb: int) -> dict[str, str]:
    scheme = SchemeVibrant(Hct.from_int(argb), DARKMODE, 0.0, spec_version="2021")
    colors: dict[str, str] = {}
    for name in vars(MaterialDynamicColors).keys():
        attr = getattr(MaterialDynamicColors, name)
        if hasattr(attr, "get_hct"):
            colors[name] = rgba_to_hex(attr.get_hct(scheme).to_rgba())
    colors.update(SUCCESS_COLORS)
    return colors


def generate_terminal_colors(
    material_colors: dict[str, str],
    term_source_colors: dict[str, str],
    harmony: float,
    harmonize_threshold: float,
    term_fg_boost: float,
    blend_bg_fg: bool,
) -> dict[str, str]:
    primary_argb = hex_to_argb(material_colors["primaryPaletteKeyColor"])
    result: dict[str, str] = {}
    for color, val in term_source_colors.items():
        if blend_bg_fg and color == "term0":
            out = boost_chroma_tone(hex_to_argb(material_colors["surfaceContainerLow"]), 1.2, 0.95)
        elif blend_bg_fg and color == "term15":
            out = boost_chroma_tone(hex_to_argb(material_colors["onSurface"]), 3.0, 1.0)
        else:
            out = harmonize(hex_to_argb(val), primary_argb, harmonize_threshold, harmony)
            out = boost_chroma_tone(out, 1.0, 1.0 + term_fg_boost)
        result[color] = argb_to_hex(out)
    return result


def emit_scss(material_colors: dict[str, str], term_colors: dict[str, str]) -> None:
    print(f"$darkmode: {DARKMODE};")
    print(f"$transparent: {TRANSPARENT};")
    for name, code in material_colors.items():
        print(f"${name}: {code};")
    for name, code in term_colors.items():
        print(f"${name}: {code};")


def emit_debug(
    argb: int,
    material_colors: dict[str, str],
    term_colors: dict[str, str],
    term_source_colors: dict[str, str],
    image_result: ImageColorResult | None,
) -> None:
    hct = Hct.from_int(argb)
    if image_result is not None:
        print("\n--------------Image properties-----------------")
        print(f"Image size: {image_result.orig_width} x {image_result.orig_height}")
        print(f"Resized image: {image_result.scaled_width} x {image_result.scaled_height}")
    print("\n---------------Selected color------------------")
    print(f"Dark mode: {DARKMODE}")
    print("Scheme: vibrant")
    print(f"Accent color: {display_color(rgba_from_argb(argb))} {argb_to_hex(argb)}")
    print(f"HCT: {hct.hue:.2f}  {hct.chroma:.2f}  {hct.tone:.2f}")
    print("\n---------------Material colors-----------------")
    for name, code in material_colors.items():
        print(f"{name.ljust(32)} : {display_color(rgba_from_argb(hex_to_argb(code)))}  {code}")
    print("\n----------Harmonize terminal colors------------")
    for name, code in term_colors.items():
        source = term_source_colors[name]
        print(
            f"{name.ljust(6)} : {display_color(rgba_from_argb(hex_to_argb(source)))} {source}"
            f" --> {display_color(rgba_from_argb(hex_to_argb(code)))} {code}"
        )
    print("-----------------------------------------------")


def main() -> None:
    args = parse_args()

    image_result: ImageColorResult | None = None
    if args.path is not None:
        image_result = load_color_from_image(args.path, args.size, args.cache)
        argb = image_result.argb
    else:
        argb = hex_to_argb(args.color)

    material_colors = generate_material_colors(argb)

    term_colors: dict[str, str] = {}
    term_source_colors: dict[str, str] = {}
    if args.termscheme is not None:
        with open(args.termscheme) as f:
            term_source_colors = json.load(f)["dark"]
        term_colors = generate_terminal_colors(
            material_colors,
            term_source_colors,
            args.harmony,
            args.harmonize_threshold,
            args.term_fg_boost,
            args.blend_bg_fg,
        )

    if args.debug:
        emit_debug(argb, material_colors, term_colors, term_source_colors, image_result)
    else:
        emit_scss(material_colors, term_colors)


if __name__ == "__main__":
    main()
