#!/usr/bin/env python3
"""
STARBLAST SWF Command-Line Editor Tool
Powered by tools/swf_lib.py and FFDec.
Allows exporting, compiling, inspecting, and injecting assets/classes into SWFs.
"""

import os
import sys
import json
import argparse
from pathlib import Path

# Add script directory to sys.path
SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR.parent) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR.parent))

from tools.swf_lib import SwfCompiler, SwfXml


def cmd_export(args):
    SwfCompiler.export_xml(
        swf_path=args.swf,
        out_xml_path=args.output,
        external=not args.no_external,
        force=args.force,
    )


def cmd_build(args):
    out_swf = SwfCompiler.build_swf(
        xml_path=args.xml,
        out_swf_path=args.output,
    )
    if args.verify:
        print("[*] Verifying AS3 classes...")
        classes = SwfCompiler.dump_as3(out_swf)
        print(f"[INFO] Registered AS3 classes ({len(classes)}):")
        for c in classes:
            print(f"  - {c}")


def cmd_dump_as3(args):
    classes = SwfCompiler.dump_as3(args.swf)
    print(f"\nAS3 Classes in {Path(args.swf).name} ({len(classes)} found):")
    print("-" * 50)
    for c in classes:
        print(f"  {c}")
    print("-" * 50)


def cmd_symbols(args):
    target = Path(args.target).resolve()
    if target.suffix.lower() == ".swf":
        classes = SwfCompiler.dump_as3(target)
        print(f"\nExported AS3 classes in {target.name}:")
        for c in classes:
            print(f"  {c}")
        return

    # XML inspection
    swf_xml = SwfXml(target)
    print(f"\nSymbols in {target.name} ({len(swf_xml.symbol_map)} found):")
    print(f"{'-'*60}")
    print(f"{'Class / Symbol Name':<40} {'ID':<10}")
    print(f"{'-'*60}")
    for tid, name in sorted(swf_xml.symbol_map.items(), key=lambda x: x[1]):
        print(f"{name:<40} {tid:<10}")
    print(f"{'-'*60}")


def cmd_inject_image(args):
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)
    dest_dir = xml_path.parent / f"{xml_path.stem}_assets" / "images"

    res = swf_xml.add_lossless_image(
        src_image_path=args.image,
        dest_assets_dir=dest_dir,
        char_id=args.char_id,
        shape_id=args.shape_id,
        max_width=args.max_w,
        max_height=args.max_h,
    )
    swf_xml.save()
    print(f"[SUCCESS] Injected image:")
    print(f"  - Character ID (Bitmap): {res['char_id']}")
    print(f"  - Shape ID:             {res['shape_id']}")
    print(f"  - Dimensions:           {res['width']}x{res['height']}")
    print(f"  - Asset file:           {res['file']}")


def cmd_inject_sprite(args):
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)

    # Parse frames format: "label1:charId1,label2:charId2"
    frames = []
    for part in args.frames.split(","):
        part = part.strip()
        if not part:
            continue
        if ":" in part:
            label, cid = part.split(":", 1)
        else:
            label, cid = f"frame{len(frames)+1}", part
        frames.append({"label": label, "char_id": int(cid), "depth": args.depth})

    swf_xml.add_multi_frame_sprite(sprite_id=args.sprite_id, frame_specs=frames)

    if args.class_name:
        swf_xml.add_as3_class(
            class_name=args.class_name,
            symbol_id=args.sprite_id,
            stop_on_frame=args.stop_frame,
        )
        print(f"  - Associated AS3 class: {args.class_name}")

    swf_xml.save()
    print(f"[SUCCESS] Injected Sprite {args.sprite_id} with {len(frames)} frames into {xml_path.name}")


def cmd_inject_class(args):
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)
    swf_xml.add_as3_class(
        class_name=args.class_name,
        symbol_id=args.symbol_id,
        stop_on_frame=args.stop_frame,
    )
    swf_xml.save()
    print(f"[SUCCESS] Injected DoABC2Tag for class '{args.class_name}'" +
          (f" linked to Symbol {args.symbol_id}" if args.symbol_id else "") +
          f" into {xml_path.name}")


def cmd_inject_sound(args):
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)
    dest_dir = xml_path.parent / f"{xml_path.stem}_assets" / "sounds"

    res = swf_xml.add_sound(
        src_sound_path=args.sound,
        dest_sounds_dir=dest_dir,
        sound_id=args.sound_id,
    )
    if args.class_name:
        swf_xml.add_as3_sound_class(
            class_name=args.class_name,
            symbol_id=args.sound_id,
        )
        print(f"  - Associated AS3 Sound class: {args.class_name}")

    swf_xml.save()
    print(f"[SUCCESS] Injected sound into {xml_path.name}:")
    print(f"  - Sound ID:   {res['sound_id']}")
    print(f"  - Asset file: {res['file']}")


def cmd_batch(args):
    xml_path = Path(args.xml).resolve()
    cfg_path = Path(args.config).resolve()
    if not cfg_path.exists():
        print(f"[ERROR] Config not found: {cfg_path}")
        sys.exit(1)

    with open(cfg_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    swf_xml = SwfXml(xml_path)
    assets_dir = xml_path.parent / f"{xml_path.stem}_assets" / "images"
    sounds_dir = xml_path.parent / f"{xml_path.stem}_assets" / "sounds"

    # 1. Images
    images = config.get("images", [])
    injected_images = {}
    for img_item in images:
        name = img_item["name"]
        res = swf_xml.add_lossless_image(
            src_image_path=img_item["file"],
            dest_assets_dir=assets_dir,
            char_id=img_item.get("char_id"),
            shape_id=img_item.get("shape_id"),
            max_width=img_item.get("max_w"),
            max_height=img_item.get("max_h"),
        )
        injected_images[name] = res
        print(f"  [+] Injected image '{name}': char_id={res['char_id']}, shape_id={res['shape_id']}")

    # 2. Sprites
    sprites = config.get("sprites", [])
    for sp_item in sprites:
        sid = sp_item["sprite_id"]
        frame_specs = []
        for f in sp_item["frames"]:
            ref = f.get("image_name")
            shape_id = injected_images[ref]["shape_id"] if ref in injected_images else f.get("shape_id")
            frame_specs.append({
                "label": f.get("label", ""),
                "shape_id": shape_id,
                "depth": f.get("depth", 1)
            })
        swf_xml.add_multi_frame_sprite(sid, frame_specs)
        print(f"  [+] Injected sprite {sid} ({len(frame_specs)} frames)")

        # Link class if specified
        cls_name = sp_item.get("class_name")
        if cls_name:
            swf_xml.add_as3_class(
                class_name=cls_name,
                symbol_id=sid,
                stop_on_frame=sp_item.get("stop_frame", 0),
            )
            print(f"      Linked AS3 class '{cls_name}' -> symbol {sid}")

    # 3. Sounds
    sounds = config.get("sounds", [])
    for snd_item in sounds:
        name = snd_item["name"]
        sid = snd_item["sound_id"]
        res = swf_xml.add_sound(
            src_sound_path=snd_item["file"],
            dest_sounds_dir=sounds_dir,
            sound_id=sid,
        )
        cls_name = snd_item.get("class_name")
        if cls_name:
            swf_xml.add_as3_sound_class(
                class_name=cls_name,
                symbol_id=sid,
            )
            print(f"  [+] Injected sound '{name}' (ID {sid}) -> AS3 class '{cls_name}'")
        else:
            print(f"  [+] Injected sound '{name}' (ID {sid})")

    swf_xml.save()
    print(f"[SUCCESS] Batch injection finished for {xml_path.name}!")


def main():
    parser = argparse.ArgumentParser(
        description="STARBLAST SWF <-> XML Editor & Injection Tool (FFDec-powered)"
    )
    sub = parser.add_subparsers(dest="command", help="Command")

    # export
    p_exp = sub.add_parser("export", help="Export SWF to XML + external assets")
    p_exp.add_argument("swf", help="Source SWF path")
    p_exp.add_argument("-o", "--output", help="Output XML path")
    p_exp.add_argument("--no-external", action="store_true", help="Do not extract assets externally")
    p_exp.add_argument("-f", "--force", action="store_true", help="Force export even if cached")

    # build
    p_bld = sub.add_parser("build", help="Build XML + external assets back to SWF")
    p_bld.add_argument("xml", help="Source XML path")
    p_bld.add_argument("-o", "--output", help="Output SWF path")
    p_bld.add_argument("--verify", action="store_true", help="Dump AS3 after build to verify")

    # dump-as3
    p_as3 = sub.add_parser("dump-as3", help="Dump AS3 classes from SWF")
    p_as3.add_argument("swf", help="Target SWF path")

    # symbols
    p_sym = sub.add_parser("symbols", help="List exported symbols in SWF or XML")
    p_sym.add_argument("target", help="SWF or XML path")

    # inject-image
    p_img = sub.add_parser("inject-image", help="Inject lossless image into XML")
    p_img.add_argument("xml", help="Target XML path")
    p_img.add_argument("--image", required=True, help="Path to source image")
    p_img.add_argument("--char-id", type=int, help="Specific character ID")
    p_img.add_argument("--shape-id", type=int, help="Specific shape ID")
    p_img.add_argument("--max-w", type=int, help="Max width constraint")
    p_img.add_argument("--max-h", type=int, help="Max height constraint")

    # inject-sprite
    p_spr = sub.add_parser("inject-sprite", help="Inject multi-frame sprite into XML")
    p_spr.add_argument("xml", help="Target XML path")
    p_spr.add_argument("--sprite-id", type=int, required=True, help="Sprite ID")
    p_spr.add_argument("--frames", required=True, help="Comma-separated 'label:charId' pairs")
    p_spr.add_argument("--depth", type=int, default=1, help="Depth (default 1)")
    p_spr.add_argument("--class-name", help="Optional AS3 class to bind to this sprite")
    p_spr.add_argument("--stop-frame", type=int, default=0, help="Stop frame (default 0)")

    # inject-class
    p_cls = sub.add_parser("inject-class", help="Inject AS3 MovieClip class (DoABC2Tag) into XML")
    p_cls.add_argument("xml", help="Target XML path")
    p_cls.add_argument("--class-name", required=True, help="Class name")
    p_cls.add_argument("--symbol-id", type=int, help="Optional symbol ID to register in SymbolClassTag")
    p_cls.add_argument("--stop-frame", type=int, default=0, help="Stop frame (default 0)")

    # inject-sound
    p_snd = sub.add_parser("inject-sound", help="Inject MP3 sound into XML")
    p_snd.add_argument("xml", help="Target XML path")
    p_snd.add_argument("--sound", required=True, help="Path to source MP3 audio")
    p_snd.add_argument("--sound-id", type=int, required=True, help="Sound character ID")
    p_snd.add_argument("--class-name", help="Optional AS3 Sound class to bind to this sound")

    # batch
    p_bat = sub.add_parser("batch", help="Batch inject assets from a JSON configuration")
    p_bat.add_argument("xml", help="Target XML path")
    p_bat.add_argument("--config", required=True, help="Path to JSON configuration file")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)

    cmds = {
        "export": cmd_export,
        "build": cmd_build,
        "dump-as3": cmd_dump_as3,
        "symbols": cmd_symbols,
        "inject-image": cmd_inject_image,
        "inject-sprite": cmd_inject_sprite,
        "inject-class": cmd_inject_class,
        "inject-sound": cmd_inject_sound,
        "batch": cmd_batch,
    }

    cmds[args.command](args)


if __name__ == "__main__":
    main()
