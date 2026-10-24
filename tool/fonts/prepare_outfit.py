"""Reproduce the official Outfit static faces; requires fontTools (see FONTS.md)."""
import argparse
import hashlib
import re
from pathlib import Path
from urllib.request import urlopen

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

REVISION = "8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5"
SOURCE_HASH = "fc7287273e66929776e2ba54f144fe699080bec29f61bf649d70d871468aeade"
ROOT = Path(__file__).resolve().parents[2]
DIRECTORY = ROOT / "packages/design_system/assets/fonts/outfit"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        used = set()
        for source in (ROOT / "packages/design_system/lib").rglob("*.dart"):
            text = source.read_text(encoding="utf-8")
            used.update(int(w) for w in re.findall(r"FontWeight\.w(\d+)", text))
            used.update(int(w) for w in re.findall(r'"fontWeight"\s*:\s*(\d+)', text))
            if "FontWeight.bold" in text:
                used.add(700)
        assert used <= {400, 500, 600, 700}, f"Missing real Outfit faces: {used - {400, 500, 600, 700}}"
        for weight in (400, 500, 600, 700):
            font = TTFont(DIRECTORY / f"Outfit-{weight}.ttf")
            assert "fvar" not in font
            assert font["OS/2"].usWeightClass == weight
        print(f"Outfit: real static faces match all referenced DS weights: {sorted(used)}")
        return
    data = urlopen(
        f"https://raw.githubusercontent.com/google/fonts/{REVISION}/ofl/outfit/Outfit%5Bwght%5D.ttf"
    ).read()
    assert hashlib.sha256(data).hexdigest() == SOURCE_HASH
    import io

    for weight in (400, 500, 600, 700):
        font = instantiateVariableFont(
            TTFont(io.BytesIO(data)), {"wght": weight}, inplace=True, updateFontNames=True
        )
        font.save(DIRECTORY / f"Outfit-{weight}.ttf")


if __name__ == "__main__":
    main()
