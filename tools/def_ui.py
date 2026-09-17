#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from modules.mugen_def import MugenDefParser
from modules.sff_parser import SffReader


def main():
    parser = argparse.ArgumentParser(description="Tool CLI Ekspor UI & Aset Mugen untuk SWF STARBLAST.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_sff = subparsers.add_parser("sff", help="Ekstrak sprite gambar dari file SFF v1/v2 ke format PNG")
    p_sff.add_argument("sff_file", help="Jalur ke file .sff")
    p_sff.add_argument("-o", "--out", help="Direktori tujuan penyimpanan gambar PNG")
    p_sff.add_argument("-g", "--group", type=int, help="Filter hanya ekstrak grup tertentu")
    p_sff.add_argument("--info", action="store_true", help="Hanya tampilkan informasi header SFF")

    p_info = subparsers.add_parser("info", help="Tampilkan ringkasan isi system.def")
    p_info.add_argument("def_file", help="Jalur ke system.def")

    p_parse = subparsers.add_parser("parse", help="Parse system.def ke file JSON")
    p_parse.add_argument("def_file", help="Jalur ke system.def")
    p_parse.add_argument("-o", "--out", help="File output JSON (default: <def_dir>/system_ui_map.json)")

    p_bg = subparsers.add_parser("compose-bg", help="Komposisikan layer background Mugen menjadi canvas 1280x720")
    p_bg.add_argument("def_file", help="Jalur ke system.def")
    p_bg.add_argument("--scene", default="title", choices=["title", "select", "versus", "victory", "option"], help="Nama scene background")
    p_bg.add_argument("-o", "--out", help="Jalur file PNG hasil komposit")

    p_anim = subparsers.add_parser("export-anim", help="Ekstrak sequence frame animasi dari action tertentu")
    p_anim.add_argument("def_file", help="Jalur ke system.def")
    p_anim.add_argument("--action", type=int, required=True, help="Nomor Action Mugen (misal 100, 160)")
    p_anim.add_argument("-o", "--out", help="Direktori output frame animasi")

    p_as3 = subparsers.add_parser("as3", help="Generate konstanta layout ActionScript 3")
    p_as3.add_argument("def_file", help="Jalur ke system.def")

    args = parser.parse_args()

    if args.command == "sff":
        sff_path = Path(args.sff_file)
        if not sff_path.is_file():
            print(f"Error: File '{sff_path}' tidak ditemukan.")
            sys.exit(1)

        reader = SffReader(str(sff_path))
        with open(sff_path, "rb") as f:
            reader.read_header(f)
            reader.read_sprite_table(f)

        ver = reader.header.version
        ver_str = f"{ver[3]}.{ver[2]}.{ver[1]}.{ver[0]}"
        print(f"[*] SFF: {sff_path}")
        print(f"[*] Versi: {ver_str}")
        print(f"[*] Total Sprite: {len(reader.sprites)}")

        if args.info:
            groups = {}
            for s in reader.sprites:
                groups[s.group] = groups.get(s.group, 0) + 1
            print("\n--- Ringkasan Grup ---")
            for g, cnt in sorted(groups.items()):
                print(f"Group {g:5d}: {cnt:4d} sprite")
            return

        out_dir = args.out
        if not out_dir:
            out_dir = str(sff_path.parent / f"{sff_path.stem}_sprites")

        print(f"[*] Mengekstrak ke: {out_dir} ...")
        count = reader.export_all(out_dir, filter_group=args.group, save_json=True)
        print(f"[OK] Berhasil mengekstrak {count} sprite ke {out_dir}")
        return

    parser_obj = MugenDefParser(args.def_file)
    parser_obj.parse()

    if args.command == "info":
        print(f"[*] File: {parser_obj.def_path}")
        print(f"[*] Total Section: {len(parser_obj.sections)}")
        print(f"[*] Total Action Animasi: {len(parser_obj.actions)}")
        print(f"[*] Background Layers Terdaftar:")
        for bg_k, bg_list in parser_obj.bg_defs.items():
            print(f"    - [{bg_k}]: {len(bg_list)} layer")
        print(f"\n[*] Action Animasi Sampel: {list(parser_obj.actions.keys())[:15]}")

    elif args.command == "parse":
        out_file = args.out or str(parser_obj.def_path.parent / "system_ui_map.json")
        parser_obj.export_summary_json(out_file)

    elif args.command == "compose-bg":
        out_file = args.out or str(parser_obj.def_path.parent / f"composed_{args.scene}_bg.png")
        parser_obj.compose_background(bg_name=f"{args.scene}bg", out_image=out_file)

    elif args.command == "export-anim":
        out_dir = args.out or str(parser_obj.def_path.parent / f"anim_{args.action}")
        parser_obj.export_action_frames(args.action, out_dir)

    elif args.command == "as3":
        code = parser_obj.generate_as3_layout_constants()
        print(code)


if __name__ == "__main__":
    main()
