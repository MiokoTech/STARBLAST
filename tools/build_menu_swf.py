#!/usr/bin/env python3
"""
STARBLAST Main Menu SWF Builder (build_menu_swf.py)
High-performance script to embed:
  1. Synchronized 1280x720 background images (Sprite 29, random_bg -> bg_mc)
  2. Preview illustrations (Sprite 120, menu_preview_mc)
  3. Character voice sound clips (DefineSoundTag IDs 121-126)
  4. ActionScript 3 (AVM2) bytecode definitions for all embedded classes
with smart caching, asset auto-discovery, benchmarking, and zero dead asset residue.
"""

import sys
import time
import json
import shutil
import argparse
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from PIL import Image

# Add project root to path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.swf_lib import SwfCompiler, SwfXml

ORIG_SWF = PROJECT_ROOT / "common/swf/menu.swf"
BACKUP_SWF = PROJECT_ROOT / "common/swf/menu.swf.orig"
WORK_DIR = PROJECT_ROOT / "scratch/menu_xml"
XML_FILE = WORK_DIR / "menu.xml"
BASE_XML = WORK_DIR / "menu_base.xml"
ASSETS_DIR = WORK_DIR / "menu_assets" / "images"
SOUNDS_DIR = WORK_DIR / "menu_assets" / "sounds"
CACHE_FILE = WORK_DIR / ".cache_meta.json"

SRC_PREVIEW_DIR = PROJECT_ROOT / "tools/menu"
SRC_BG_DIR = PROJECT_ROOT / "tools/menu/background"
SRC_SOUND_DIR = PROJECT_ROOT / "tools/menu/sound"

# (label, prefix, default_file, char_id, shape_id)
PREVIEW_MAPPING = [
    ("single", "01", "01.png", 101, 102),
    ("versus", "02", "02.png", 103, 104),
    ("training", "03", "03.png", 105, 106),
    ("credits", "04", "04.png", 107, 108),
    ("exit", "05", "05.png", 109, 110),
    ("option", "06", "06.png", 111, 112),
]

# (label, prefix, default_file, bitmap_char_id, shape_id)
BG_MAPPING = [
    ("single", "01", "01.jpg", 7, 8),
    ("versus", "02", "02.jpg", 9, 10),
    ("training", "03", "03.jpg", 11, 12),
    ("credits", "04", "04.png", 13, 14),
    ("exit", "05", "05.jpg", 15, 16),
    ("option", "06", "06.jpg", 17, 18),
]

# (label, prefix, default_file, sound_id, class_name)
SOUND_MAPPING = [
    ("single", "01", "01_1.mp3", 121, "menu_snd_01"),
    ("versus", "02", "02_1.mp3", 122, "menu_snd_02"),
    ("training", "03", "03_1.mp3", 123, "menu_snd_03"),
    ("credits", "04", "04_1.mp3", 124, "menu_snd_04"),
    ("exit", "05", "05_1.mp3", 125, "menu_snd_05"),
    ("option", "06", "06_1.mp3", 126, "menu_snd_06"),
]

PREVIEW_MAX_W = 680
PREVIEW_MAX_H = 720
BG_W = 1280
BG_H = 720


def resolve_asset_file(directory: Path, prefix: str, default_name: str, allowed_exts: Tuple[str, ...]) -> Path:
    """
    Intelligently resolve asset file:
    1. Exact default_name
    2. Prefix with allowed extension (e.g., 01.png, 01.jpg)
    3. Prefix wildcard variation (e.g., 01_1.mp3, 01_v2.png)
    """
    exact = directory / default_name
    if exact.exists():
        return exact

    for ext in allowed_exts:
        cand = directory / f"{prefix}{ext}"
        if cand.exists():
            return cand

    for ext in allowed_exts:
        matches = sorted(directory.glob(f"{prefix}_*{ext}")) + sorted(directory.glob(f"{prefix}-*{ext}"))
        if matches:
            return matches[0]

    return exact


def load_cache_meta() -> Dict[str, Any]:
    if CACHE_FILE.exists():
        try:
            with open(CACHE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def save_cache_meta(meta: Dict[str, Any]):
    try:
        with open(CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump(meta, f, indent=2)
    except Exception:
        pass


def prepare_base_xml(force: bool = False, clean: bool = False) -> Path:
    """Ensure original SWF backup exists and base XML snapshot is cached."""
    if clean and WORK_DIR.exists():
        print(f"[*] Cleaning working directory: {WORK_DIR}...")
        shutil.rmtree(WORK_DIR, ignore_errors=True)

    if not BACKUP_SWF.exists():
        print(f"[*] Creating backup of original menu.swf -> {BACKUP_SWF.name}...")
        shutil.copy2(ORIG_SWF, BACKUP_SWF)

    source_swf = BACKUP_SWF if BACKUP_SWF.exists() else ORIG_SWF

    if force or not BASE_XML.exists():
        SwfCompiler.export_xml(
            swf_path=source_swf,
            out_xml_path=BASE_XML,
            external=True,
            force=True,
        )

    # Fresh copy to working XML_FILE for 100% deterministic build
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy2(BASE_XML, XML_FILE)
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    SOUNDS_DIR.mkdir(parents=True, exist_ok=True)
    return XML_FILE


def process_backgrounds(swf_xml: SwfXml, cache_meta: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Resize background images to 1280x720 (cover crop) and replace old backgrounds
    in XML (IDs 7, 9, 11, 13, 15, 17) and Sprite 29 without leaving old residue.
    """
    print("[*] Processing & replacing background images (1280x720)...")
    target_ratio = BG_W / BG_H
    info_list = []

    for label, prefix, default_file, cid, sid in BG_MAPPING:
        src_path = resolve_asset_file(SRC_BG_DIR, prefix, default_file, (".jpg", ".jpeg", ".png", ".webp"))
        dest_jpg = ASSETS_DIR / f"{cid}.jpg"

        if not src_path.exists():
            raise FileNotFoundError(f"Background image for '{label}' not found in {SRC_BG_DIR}")

        bg_meta = cache_meta.get("backgrounds", {}).get(label, {})
        needs_process = True
        if (
            dest_jpg.exists()
            and bg_meta.get("source_name") == src_path.name
            and bg_meta.get("source_size") == src_path.stat().st_size
            and dest_jpg.stat().st_mtime >= src_path.stat().st_mtime
        ):
            needs_process = False

        if needs_process:
            with Image.open(src_path) as im:
                im = im.convert("RGB")
                im_ratio = im.width / im.height
                if im_ratio > target_ratio:
                    new_h = BG_H
                    new_w = int(im.width * (BG_H / im.height))
                else:
                    new_w = BG_W
                    new_h = int(im.height * (BG_W / im.width))
                resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
                left = (new_w - BG_W) // 2
                top = (new_h - BG_H) // 2
                cropped = resized.crop((left, top, left + BG_W, top + BG_H))
                cropped.save(dest_jpg, "JPEG", quality=92, optimize=True)
                size_kb = dest_jpg.stat().st_size / 1024
                print(f"  [+] Background {label:<8} ({src_path.name}) -> {dest_jpg.name} ({size_kb:.1f} KB)")
        else:
            size_kb = dest_jpg.stat().st_size / 1024
            print(f"  [cached] Background {label:<8} ({src_path.name}) -> {dest_jpg.name}")

        cache_meta.setdefault("backgrounds", {})[label] = {
            "source_name": src_path.name,
            "source_size": src_path.stat().st_size,
            "source_mtime": src_path.stat().st_mtime,
        }

        # Update external file path in DefineBitsJPEG2Tag
        cid_str = str(cid)
        rel_path = f"menu_assets/images/{cid}.jpg"
        for tag in swf_xml.tags_container.findall(".//item"):
            if tag.get("type") in ("DefineBitsJPEG2Tag", "DefineBitsJPEG3Tag") and tag.get("characterID") == cid_str:
                tag.attrib["_externalFile"] = rel_path

        info_list.append({
            "label": label,
            "source": src_path.name,
            "cid": cid,
            "sid": sid,
            "size_kb": dest_jpg.stat().st_size / 1024,
        })

    # Rebuild Sprite 29 with frame labels matching preview labels
    print("[*] Updating Sprite 29 (random_bg / bg_mc) with deterministic frame labels...")
    sprite29 = swf_xml.tags_container.find(".//item[@type='DefineSpriteTag'][@spriteId='29']")
    if sprite29 is not None:
        subtags = sprite29.find("subTags")
        if subtags is not None:
            subtags.clear()
            for i, (label, prefix, default_file, cid, sid) in enumerate(BG_MAPPING):
                # FrameLabelTag
                ET.SubElement(subtags, "item", {
                    "type": "FrameLabelTag",
                    "forceWriteAsLong": "false",
                    "name": label
                })
                # PlaceObject2Tag
                ET.SubElement(subtags, "item", {
                    "type": "PlaceObject2Tag",
                    "characterId": str(sid),
                    "depth": "1",
                    "forceWriteAsLong": "false",
                    "placeFlagHasCharacter": "true",
                    "placeFlagHasClipActions": "false",
                    "placeFlagHasClipDepth": "false",
                    "placeFlagHasColorTransform": "false",
                    "placeFlagHasMatrix": "false",
                    "placeFlagHasName": "false",
                    "placeFlagHasRatio": "false",
                    "placeFlagMove": "false" if i == 0 else "true"
                })
                # ShowFrameTag
                ET.SubElement(subtags, "item", {
                    "type": "ShowFrameTag",
                    "forceWriteAsLong": "false"
                })

    # Give Sprite 29 the instance name 'bg_mc' inside Sprite 30 (front_game)
    sprite30 = swf_xml.tags_container.find(".//item[@type='DefineSpriteTag'][@spriteId='30']")
    if sprite30 is not None:
        p29 = sprite30.find(".//subTags/item[@type='PlaceObject2Tag'][@characterId='29']")
        if p29 is not None:
            p29.attrib["placeFlagHasName"] = "true"
            p29.attrib["name"] = "bg_mc"
            print("  [+] Set instance name 'bg_mc' on Sprite 29 in front_game (Sprite 30)")

    # Replace random_bg DoABC2Tag with clean constructor (stop on frame 1)
    print("[*] Injecting deterministic DoABC2Tag for 'random_bg'...")
    swf_xml.add_as3_class(
        class_name="random_bg",
        symbol_id=29,
        stop_on_frame=0,
    )
    return info_list


def process_previews(swf_xml: SwfXml, cache_meta: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Process and inject preview illustrations into Sprite 120 and DoABC2Tag."""
    print("[*] Processing preview illustrations...")
    frame_specs = []
    info_list = []

    for label, prefix, default_file, cid, sid in PREVIEW_MAPPING:
        src_path = resolve_asset_file(SRC_PREVIEW_DIR, prefix, default_file, (".png", ".jpg", ".webp"))
        dest_png = ASSETS_DIR / f"{cid}.png"

        if not src_path.exists():
            raise FileNotFoundError(f"Preview image for '{label}' not found in {SRC_PREVIEW_DIR}")

        prev_meta = cache_meta.get("previews", {}).get(label, {})
        needs_process = True
        if (
            dest_png.exists()
            and prev_meta.get("source_name") == src_path.name
            and prev_meta.get("source_size") == src_path.stat().st_size
            and dest_png.stat().st_mtime >= src_path.stat().st_mtime
        ):
            needs_process = False

        if needs_process:
            res = swf_xml.add_lossless_image(
                src_image_path=src_path,
                dest_assets_dir=ASSETS_DIR,
                char_id=cid,
                shape_id=sid,
                max_width=PREVIEW_MAX_W,
                max_height=PREVIEW_MAX_H,
            )
            print(f"  [+] Resized & injected preview {label:<8} ({src_path.name}): {res['width']}x{res['height']}")
        else:
            res = swf_xml.add_lossless_image(
                src_image_path=dest_png,
                dest_assets_dir=ASSETS_DIR,
                char_id=cid,
                shape_id=sid,
            )
            print(f"  [cached] Preview {label:<8} ({src_path.name}) -> {dest_png.name} ({res['width']}x{res['height']})")

        cache_meta.setdefault("previews", {})[label] = {
            "source_name": src_path.name,
            "source_size": src_path.stat().st_size,
            "source_mtime": src_path.stat().st_mtime,
        }

        frame_specs.append({
            "label": label,
            "char_id": sid,
            "depth": 1,
        })
        info_list.append({
            "label": label,
            "source": src_path.name,
            "width": res["width"],
            "height": res["height"],
            "cid": cid,
            "sid": sid,
            "size_kb": dest_png.stat().st_size / 1024,
        })

    # Inject Sprite 120 (menu_preview_mc)
    print("[*] Injecting Sprite 120 (menu_preview_mc)...")
    swf_xml.add_multi_frame_sprite(sprite_id=120, frame_specs=frame_specs)

    # Inject DoABC2Tag for menu_preview_mc
    print("[*] Injecting ActionScript 3 class (DoABC2Tag) for 'menu_preview_mc'...")
    swf_xml.add_as3_class(
        class_name="menu_preview_mc",
        symbol_id=120,
        stop_on_frame=0,
    )
    return info_list


def process_sounds(swf_xml: SwfXml, cache_meta: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Embed character voice clips into menu.swf as DefineSoundTags and AS3 Sound classes."""
    print("[*] Processing character voice sounds...")
    SOUNDS_DIR.mkdir(parents=True, exist_ok=True)
    info_list = []

    for label, prefix, default_file, sound_id, class_name in SOUND_MAPPING:
        src_path = resolve_asset_file(SRC_SOUND_DIR, prefix, default_file, (".mp3", ".wav"))
        dest_mp3 = SOUNDS_DIR / f"{sound_id}.mp3"

        if not src_path.exists():
            raise FileNotFoundError(f"Voice sound for '{label}' not found in {SRC_SOUND_DIR}")

        snd_meta = cache_meta.get("sounds", {}).get(label, {})
        needs_copy = True
        if (
            dest_mp3.exists()
            and snd_meta.get("source_name") == src_path.name
            and snd_meta.get("source_size") == src_path.stat().st_size
            and dest_mp3.stat().st_mtime >= src_path.stat().st_mtime
        ):
            needs_copy = False

        if needs_copy:
            shutil.copy2(src_path, dest_mp3)
            size_kb = dest_mp3.stat().st_size / 1024
            print(f"  [+] Copied sound {label:<8} ({src_path.name}) -> {dest_mp3.name} ({size_kb:.1f} KB)")
        else:
            size_kb = dest_mp3.stat().st_size / 1024
            print(f"  [cached] Sound {label:<8} ({src_path.name}) -> {dest_mp3.name}")

        cache_meta.setdefault("sounds", {})[label] = {
            "source_name": src_path.name,
            "source_size": src_path.stat().st_size,
            "source_mtime": src_path.stat().st_mtime,
        }

        # Inject DefineSoundTag
        swf_xml.add_sound(
            src_sound_path=dest_mp3,
            dest_sounds_dir=SOUNDS_DIR,
            sound_id=sound_id,
        )

        # Inject AS3 Sound class
        swf_xml.add_as3_sound_class(
            class_name=class_name,
            symbol_id=sound_id,
        )

        info_list.append({
            "label": label,
            "source": src_path.name,
            "sound_id": sound_id,
            "class_name": class_name,
            "size_kb": size_kb,
        })

    return info_list


def print_report(
    bg_info: List[Dict[str, Any]],
    preview_info: List[Dict[str, Any]],
    sound_info: List[Dict[str, Any]],
    total_time: float,
    swf_size_kb: float,
):
    """Print clean summary report table."""
    print("\n" + "=" * 78)
    print("                STARBLAST MAIN MENU ASSET INVENTORY REPORT")
    print("=" * 78)

    print(f"\n[1] SYNCHRONIZED BACKGROUNDS (1280x720 HD)")
    print(f"{'-'*78}")
    print(f"{'Label':<10} {'Source File':<16} {'IDs (Bmp/Shp)':<16} {'Resolution':<14} {'Size':<10}")
    print(f"{'-'*78}")
    for b in bg_info:
        ids_str = f"{b['cid']}/{b['sid']}"
        print(f"{b['label']:<10} {b['source']:<16} {ids_str:<16} 1280x720       {b['size_kb']:.1f} KB")

    print(f"\n[2] PREVIEW ILLUSTRATIONS (Sprite 120: menu_preview_mc)")
    print(f"{'-'*78}")
    print(f"{'Label':<10} {'Source File':<16} {'IDs (Bmp/Shp)':<16} {'Resolution':<14} {'Size':<10}")
    print(f"{'-'*78}")
    for p in preview_info:
        ids_str = f"{p['cid']}/{p['sid']}"
        dim_str = f"{p['width']}x{p['height']}"
        print(f"{p['label']:<10} {p['source']:<16} {ids_str:<16} {dim_str:<14} {p['size_kb']:.1f} KB")

    print(f"\n[3] CHARACTER VOICE SOUNDS (flash.media.Sound)")
    print(f"{'-'*78}")
    print(f"{'Label':<10} {'Source File':<16} {'Sound ID':<10} {'AS3 Class':<20} {'Size':<10}")
    print(f"{'-'*78}")
    for s in sound_info:
        print(f"{s['label']:<10} {s['source']:<16} {s['sound_id']:<10} {s['class_name']:<20} {s['size_kb']:.1f} KB")

    print(f"\n{'-'*78}")
    print(f"Total Compilation Time: {total_time:.2f}s | Output SWF: {ORIG_SWF.name} ({swf_size_kb:.1f} KB)")
    print("=" * 78 + "\n")


def build_menu_swf(force: bool = False, clean: bool = False, report: bool = False, verify: bool = True):
    """Complete build pipeline for menu.swf."""
    start_time = time.time()
    print("=== STARBLAST Menu SWF Builder ===")

    t0 = time.time()
    xml_path = prepare_base_xml(force=force, clean=clean)
    prep_time = time.time() - t0

    cache_meta = {} if clean or force else load_cache_meta()

    print("[*] Parsing SWF XML definitions...")
    swf_xml = SwfXml(xml_path)

    # 1. Backgrounds
    t0 = time.time()
    bg_info = process_backgrounds(swf_xml, cache_meta)
    bg_time = time.time() - t0

    # 2. Previews
    t0 = time.time()
    preview_info = process_previews(swf_xml, cache_meta)
    preview_time = time.time() - t0

    # 3. Sounds
    t0 = time.time()
    sound_info = process_sounds(swf_xml, cache_meta)
    sound_time = time.time() - t0

    # 4. Save modified XML and cache metadata
    swf_xml.save()
    save_cache_meta(cache_meta)
    print(f"[SUCCESS] Saved modified XML: {XML_FILE}")

    # 5. Compile to common/swf/menu.swf
    t0 = time.time()
    out_swf = SwfCompiler.build_swf(xml_path=XML_FILE, out_swf_path=ORIG_SWF)
    compile_time = time.time() - t0

    # 6. Verification
    if verify:
        print("[*] Verifying compiled AS3 classes in SWF...")
        classes = SwfCompiler.dump_as3(out_swf)
        expected = [
            "front_game", "random_bg", "menu_gameSet", "menu_preview_mc",
            "menu_snd_01", "menu_snd_02", "menu_snd_03", "menu_snd_04", "menu_snd_05", "menu_snd_06",
        ]
        verified_count = 0
        for exp in expected:
            if any(exp in c for c in classes):
                print(f"  [OK] Class '{exp}' verified in AS3 runtime")
                verified_count += 1
            else:
                print(f"  [WARNING] Class '{exp}' NOT found in AS3 dump!")

        print(f"  ==> Verified: {verified_count}/{len(expected)} classes active.")

    total_time = time.time() - start_time
    size_kb = out_swf.stat().st_size / 1024

    print(f"\n[BENCHMARK]")
    print(f"  - Preparation:  {prep_time:.2f}s")
    print(f"  - Backgrounds:  {bg_time:.2f}s")
    print(f"  - Previews:     {preview_time:.2f}s")
    print(f"  - Sounds:       {sound_time:.2f}s")
    print(f"  - XML2SWF:      {compile_time:.2f}s")
    print(f"  - Total Elapsed:{total_time:.2f}s")

    if report:
        print_report(bg_info, preview_info, sound_info, total_time, size_kb)

    print(f"\n[ALL DONE] Built {out_swf.name} ({size_kb:.1f} KB) in {total_time:.2f}s successfully!")


def main():
    parser = argparse.ArgumentParser(description="STARBLAST Menu SWF Builder & Asset Embedder")
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Force full re-export from original SWF instead of using cached XML snapshot",
    )
    parser.add_argument(
        "-c", "--clean",
        action="store_true",
        help="Clean scratch working directory before building",
    )
    parser.add_argument(
        "-r", "--report",
        action="store_true",
        help="Print detailed asset inventory report after building",
    )
    parser.add_argument(
        "--no-verify",
        action="store_true",
        help="Skip AVM2 ActionScript 3 bytecode verification",
    )
    args = parser.parse_args()
    build_menu_swf(
        force=args.force,
        clean=args.clean,
        report=args.report,
        verify=not args.no_verify,
    )


if __name__ == "__main__":
    main()
