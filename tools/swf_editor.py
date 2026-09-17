#!/usr/bin/env python3
import os
import sys
import json
import argparse
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.modules.swf_lib import SwfCompiler, SwfXml


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
        print("[*] Memverifikasi kelas AS3...")
        classes = SwfCompiler.dump_as3(out_swf)
        print(f"[INFO] Kelas AS3 terdaftar ({len(classes)}):")
        for c in classes:
            print(f"  - {c}")


def cmd_dump_as3(args):
    classes = SwfCompiler.dump_as3(args.swf)
    print(f"\nKelas AS3 pada {Path(args.swf).name} ({len(classes)} ditemukan):")
    print("-" * 50)
    for c in classes:
        print(f"  {c}")
    print("-" * 50)


def cmd_symbols(args):
    target = Path(args.target).resolve()
    if target.suffix.lower() == ".swf":
        classes = SwfCompiler.dump_as3(target)
        print(f"\nKelas AS3 yang diekspor pada {target.name}:")
        for c in classes:
            print(f"  {c}")
        return

    # Inspeksi XML
    swf_xml = SwfXml(target)
    print(f"\nSimbol pada {target.name} ({len(swf_xml.symbol_map)} ditemukan):")
    print(f"{'-'*60}")
    print(f"{'Nama Kelas / Simbol':<40} {'ID':<10}")
    print(f"{'-'*60}")
    for tid, name in sorted(swf_xml.symbol_map.items(), key=lambda x: x[1]):
        print(f"{name:<40} {tid:<10}")
    print(f"{'-'*60}")


def cmd_inject_image(args):
    """Sematkan gambar lossless ke XML."""
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
    print(f"[OK] Gambar berhasil disematkan:")
    print(f"  - Character ID (Bitmap): {res['char_id']}")
    print(f"  - Shape ID:             {res['shape_id']}")
    print(f"  - Dimensi:              {res['width']}x{res['height']}")
    print(f"  - File aset:            {res['file']}")


def cmd_inject_sprite(args):
    """Sematkan multi-frame sprite ke XML."""
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)

    # Format frame: "label1:charId1,label2:charId2"
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
        print(f"  - Kelas AS3 terhubung: {args.class_name}")

    swf_xml.save()
    print(f"[OK] Sprite {args.sprite_id} ({len(frames)} frame) berhasil disematkan ke {xml_path.name}")


def cmd_inject_class(args):
    """Sematkan kelas MovieClip AS3 (DoABC2Tag) ke XML."""
    xml_path = Path(args.xml).resolve()
    swf_xml = SwfXml(xml_path)
    swf_xml.add_as3_class(
        class_name=args.class_name,
        symbol_id=args.symbol_id,
        stop_on_frame=args.stop_frame,
    )
    swf_xml.save()
    print(f"[OK] DoABC2Tag untuk kelas '{args.class_name}'" +
          (f" terhubung ke Symbol {args.symbol_id}" if args.symbol_id else "") +
          f" berhasil disematkan ke {xml_path.name}")


def cmd_inject_sound(args):
    """Sematkan file audio MP3 ke XML."""
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
        print(f"  - Kelas Sound AS3 terhubung: {args.class_name}")

    swf_xml.save()
    print(f"[OK] File audio berhasil disematkan ke {xml_path.name}:")
    print(f"  - Sound ID:  {res['sound_id']}")
    print(f"  - File aset: {res['file']}")


def cmd_batch(args):
    """Injeksi batch aset gambar, sprite, dan suara dari file konfigurasi JSON."""
    xml_path = Path(args.xml).resolve()
    cfg_path = Path(args.config).resolve()
    if not cfg_path.exists():
        print(f"[ERROR] File konfigurasi tidak ditemukan: {cfg_path}")
        sys.exit(1)

    with open(cfg_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    swf_xml = SwfXml(xml_path)
    assets_dir = xml_path.parent / f"{xml_path.stem}_assets" / "images"
    sounds_dir = xml_path.parent / f"{xml_path.stem}_assets" / "sounds"

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
        print(f"  [+] Injeksi gambar '{name}': char_id={res['char_id']}, shape_id={res['shape_id']}")

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
        print(f"  [+] Injeksi sprite {sid} ({len(frame_specs)} frame)")

        cls_name = sp_item.get("class_name")
        if cls_name:
            swf_xml.add_as3_class(
                class_name=cls_name,
                symbol_id=sid,
                stop_on_frame=sp_item.get("stop_frame", 0),
            )
            print(f"      Hubungkan kelas AS3 '{cls_name}' -> symbol {sid}")

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
            print(f"  [+] Injeksi suara '{name}' (ID {sid}) -> kelas AS3 '{cls_name}'")
        else:
            print(f"  [+] Injeksi suara '{name}' (ID {sid})")

    swf_xml.save()
    print(f"[OK] Injeksi batch selesai untuk {xml_path.name}!")


def main():
    parser = argparse.ArgumentParser(
        description="Tool CLI Editor SWF & Injeksi XML STARBLAST (berbasis FFDec)"
    )
    sub = parser.add_subparsers(dest="command", help="Perintah")

    # export
    p_exp = sub.add_parser("export", help="Ekspor SWF ke XML dan ekstrak aset eksternal")
    p_exp.add_argument("swf", help="Jalur file SWF sumber")
    p_exp.add_argument("-o", "--output", help="Jalur file XML output")
    p_exp.add_argument("--no-external", action="store_true", help="Jangan ekstrak aset secara eksternal")
    p_exp.add_argument("-f", "--force", action="store_true", help="Paksa ekspor ulang meskipun cache tersedia")

    # build
    p_bld = sub.add_parser("build", help="Kompilasi XML dan aset eksternal kembali ke SWF")
    p_bld.add_argument("xml", help="Jalur file XML sumber")
    p_bld.add_argument("-o", "--output", help="Jalur file SWF output")
    p_bld.add_argument("--verify", action="store_true", help="Verifikasi kelas AS3 setelah kompilasi")

    # dump-as3
    p_as3 = sub.add_parser("dump-as3", help="Tampilkan daftar kelas AS3 dari SWF")
    p_as3.add_argument("swf", help="Jalur file SWF target")

    # symbols
    p_sym = sub.add_parser("symbols", help="Daftar simbol yang diekspor pada SWF atau XML")
    p_sym.add_argument("target", help="Jalur file SWF atau XML")

    # inject-image
    p_img = sub.add_parser("inject-image", help="Sematkan gambar lossless ke XML")
    p_img.add_argument("xml", help="Jalur file XML target")
    p_img.add_argument("--image", required=True, help="Jalur file gambar sumber")
    p_img.add_argument("--char-id", type=int, help="Character ID spesifik")
    p_img.add_argument("--shape-id", type=int, help="Shape ID spesifik")
    p_img.add_argument("--max-w", type=int, help="Batasan lebar maksimal")
    p_img.add_argument("--max-h", type=int, help="Batasan tinggi maksimal")

    # inject-sprite
    p_spr = sub.add_parser("inject-sprite", help="Sematkan multi-frame sprite ke XML")
    p_spr.add_argument("xml", help="Jalur file XML target")
    p_spr.add_argument("--sprite-id", type=int, required=True, help="ID Sprite")
    p_spr.add_argument("--frames", required=True, help="Pasangan 'label:charId' dipisah koma")
    p_spr.add_argument("--depth", type=int, default=1, help="Depth layer (default 1)")
    p_spr.add_argument("--class-name", help="Nama kelas AS3 opsional untuk dihubungkan")
    p_spr.add_argument("--stop-frame", type=int, default=0, help="Frame berhenti (default 0)")

    # inject-class
    p_cls = sub.add_parser("inject-class", help="Sematkan kelas MovieClip AS3 (DoABC2Tag) ke XML")
    p_cls.add_argument("xml", help="Jalur file XML target")
    p_cls.add_argument("--class-name", required=True, help="Nama kelas AS3")
    p_cls.add_argument("--symbol-id", type=int, help="ID simbol opsional untuk SymbolClassTag")
    p_cls.add_argument("--stop-frame", type=int, default=0, help="Frame berhenti (default 0)")

    # inject-sound
    p_snd = sub.add_parser("inject-sound", help="Sematkan audio MP3 ke XML")
    p_snd.add_argument("xml", help="Jalur file XML target")
    p_snd.add_argument("--sound", required=True, help="Jalur file audio MP3 sumber")
    p_snd.add_argument("--sound-id", type=int, required=True, help="ID karakter suara")
    p_snd.add_argument("--class-name", help="Nama kelas Sound AS3 opsional untuk dihubungkan")

    # batch
    p_bat = sub.add_parser("batch", help="Injeksi batch aset dari konfigurasi JSON")
    p_bat.add_argument("xml", help="Jalur file XML target")
    p_bat.add_argument("--config", required=True, help="Jalur file konfigurasi JSON")

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
