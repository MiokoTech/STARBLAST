"""
tools/swf2sbs.py
Konverter Flash Character MovieClip SWF -> STARBLAST Sprite Atlas (.sbs) + Timeline (.air).

Mengekstrak frame-frame animasi dari karakter SWF (format BVN),
menghitung pivot axis presisi terhadap origin Flash, melakukan deduplikasi frame,
mengemasnya ke dalam Texture Atlas .sbs (SBS1 format), serta menghasilkan file timeline .air dan konfigurasi character.json.
"""

import argparse
import io
import os
import shutil
import struct
import subprocess
import sys
import json
import tempfile
import time
import zlib
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple
from PIL import Image

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from tools.modules.sbs_format import (
    SbsWriter,
    SbsReader,
    ATLAS_FMT_PNG,
    ATLAS_FMT_ZLIB_RGBA
)

ACTION_MAP = {
    "站立": 0,
    "走": 20,
    "瞬步": 100,
    "瞬步落地": 101,
    "空瞬": 102,
    "起跳": 40,
    "跳": 41,
    "跳中": 42,
    "落": 43,
    "落地": 47,
    "防御": 120,
    "防御恢复": 140,
    "被打": 5000,
    "击飞": 5030,
    "击飞_落": 5050,
    "击飞_弹": 5100,
    "击飞_倒": 5110,
    "击飞_起": 5120,
    "起身": 5121,
    "起身1": 5122,
    "后跳落地1": 105,
    "后跳落地2": 106,
    "开场": 190,
    "胜利": 180,
    "失败": 170,
    "摔1": 800,
    "摔2": 801,
    "跳砍": 600,
    "跳招": 610,
    "跳招0": 611,
    "跳招1": 612,
    "砍1": 200,
    "砍2": 210,
    "砍3": 220,
    "砍技1": 230,
    "砍技11": 231,
    "招1": 1000,
    "快速u": 1005,
    "招2": 1010,
    "招21": 1011,
    "招22": 1012,
    "招3": 1020,
    "招3_loop": 1021,
    "招31": 1022,
    "必杀": 3000,
    "超必杀": 3100,
    "超必杀2": 3200,
    "上必杀": 3300,
}


def read_swf_decompressed(swf_path: str) -> bytes:
    with open(swf_path, "rb") as f:
        sig = f.read(3)
        ver = f.read(1)[0]
        flen = struct.unpack("<I", f.read(4))[0]
        payload = f.read()

    if sig == b"CWS":
        return zlib.decompress(payload)
    elif sig == b"FWS":
        return payload
    else:
        raise ValueError(f"Tipe file SWF tidak dikenal: {sig}")


def parse_swf_symbols_and_sprites(data: bytes):
    bio = io.BytesIO(data)
    first_byte = bio.read(1)[0]
    nbits = first_byte >> 3
    total_bits = 5 + nbits * 4
    bytes_to_skip = (total_bits + 7) // 8 - 1
    bio.read(bytes_to_skip)
    fps = struct.unpack("<H", bio.read(2))[0] / 256.0
    frame_count = struct.unpack("<H", bio.read(2))[0]

    def read_str(b):
        res = []
        while True:
            c = b.read(1)
            if not c or c == b"\x00":
                break
            res.append(c)
        return b"".join(res).decode("utf-8", errors="ignore")

    symbols = {}
    sprites = {}

    while True:
        th_b = bio.read(2)
        if len(th_b) < 2:
            break
        th = struct.unpack("<H", th_b)[0]
        tag_type = th >> 6
        tag_len = th & 0x3F
        if tag_len == 0x3F:
            tag_len = struct.unpack("<I", bio.read(4))[0]
        start_pos = bio.tell()

        if tag_type == 76:
            num_syms = struct.unpack("<H", bio.read(2))[0]
            for _ in range(num_syms):
                sid = struct.unpack("<H", bio.read(2))[0]
                sname = read_str(bio)
                symbols[sid] = sname
        elif tag_type == 39:
            spr_id = struct.unpack("<H", bio.read(2))[0]
            spr_frames = struct.unpack("<H", bio.read(2))[0]

            labels = []
            cur_f = 1
            spr_end = start_pos + tag_len
            while bio.tell() < spr_end:
                sub_th_b = bio.read(2)
                if len(sub_th_b) < 2:
                    break
                sub_th = struct.unpack("<H", sub_th_b)[0]
                sub_type = sub_th >> 6
                sub_len = sub_th & 0x3F
                if sub_len == 0x3F:
                    sub_len = struct.unpack("<I", bio.read(4))[0]
                sub_start = bio.tell()
                if sub_type == 1:
                    cur_f += 1
                elif sub_type == 43:
                    lbl = read_str(bio)
                    labels.append((cur_f, lbl))
                bio.seek(sub_start + sub_len)

            label_ranges = []
            for i in range(len(labels)):
                f_s, lbl = labels[i]
                f_e = labels[i + 1][0] - 1 if i + 1 < len(labels) else spr_frames
                label_ranges.append((lbl, f_s, f_e))

            sprites[spr_id] = {
                "frames": spr_frames,
                "labels": label_ranges
            }

        bio.seek(start_pos + tag_len)
        if tag_type == 0:
            break

    return fps, symbols, sprites


def find_target_sprite(symbols: dict, sprites: dict, target_chid: Optional[int] = None) -> Tuple[int, dict]:
    if target_chid and target_chid in sprites:
        return target_chid, sprites[target_chid]

    candidates = []
    for sid, info in sprites.items():
        num_labels = len(info["labels"])
        candidates.append((num_labels, info["frames"], sid))

    candidates.sort(key=lambda x: (x[0], x[1]), reverse=True)
    best_sid = candidates[0][2]
    return best_sid, sprites[best_sid]


def export_sprite_frames(swf_path: str, chid: int, frame_range_str: str, out_dir: str):
    cmd = [
        "ffdec",
        "-selectid", str(chid),
        "-select", f"{chid}:{frame_range_str}",
        "-ignorebackground",
        "-format", "sprite:png",
        "-export", "sprite",
        out_dir,
        swf_path
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        print(f"Warning FFDec: {res.stderr}")


def convert_swf_to_sbs(
    swf_path: str,
    out_dir: str,
    char_id: str = "flandre",
    char_name: str = "Flandre Scarlet",
    max_frames: Optional[int] = None,
    actions_filter: Optional[List[str]] = None,
    origin_x: int = 760,
    origin_y: int = 475,
    atlas_format: int = ATLAS_FMT_PNG,
    atlas_size: int = 2048,
    padding: int = 1
):
    swf_path = str(Path(swf_path).resolve())
    out_dir_path = Path(out_dir).resolve()
    out_dir_path.mkdir(parents=True, exist_ok=True)

    decomp = read_swf_decompressed(swf_path)
    fps, symbols, sprites = parse_swf_symbols_and_sprites(decomp)

    if not sprites:
        raise ValueError("Tidak ditemukan DefineSprite tag di dalam file SWF.")

    chid, spr_info = find_target_sprite(symbols, sprites)
    total_f = spr_info["frames"]
    label_ranges = spr_info["labels"]
    print(f"Ditemukan Sprite Target: ID {chid} ({total_f} frames, {len(label_ranges)} label aksi).")

    active_ranges = []
    for lbl, fs, fe in label_ranges:
        if actions_filter:
            if lbl not in actions_filter:
                continue
        if max_frames and fs > max_frames:
            continue
        fe_clamped = min(fe, max_frames) if max_frames else fe
        if fs <= fe_clamped:
            active_ranges.append((lbl, fs, fe_clamped))

    if not active_ranges:
        print("Tidak ada range frame aktif yang cocok dengan filter.")
        return

    frame_spec = ",".join(f"{fs}-{fe}" if fs != fe else str(fs) for _, fs, fe in active_ranges)

    temp_export_dir = tempfile.mkdtemp(prefix="sb_swf_export_")
    try:
        export_sprite_frames(swf_path, chid, frame_spec, temp_export_dir)

        spr_dir = None
        for p in Path(temp_export_dir).iterdir():
            if p.is_dir() and f"DefineSprite_{chid}" in p.name:
                spr_dir = p
                break

        if not spr_dir:
            raise FileNotFoundError(f"Folder hasil export DefineSprite {chid} tidak ditemukan di {temp_export_dir}")

        sprite_items = []
        air_actions = []

        print(f"Memproses frame raster dan menghitung pivot origin ({origin_x}, {origin_y})...")

        for lbl, f_start, f_end in active_ranges:
            action_no = ACTION_MAP.get(lbl, 1000 + len(air_actions))
            current_action_frames = []

            last_img_bytes = None
            last_axis = (0, 0)
            last_spr_num = -1

            sub_num = 0
            for f in range(f_start, f_end + 1):
                png_file = spr_dir / f"{f}.png"
                if not png_file.exists():
                    continue

                im = Image.open(png_file)
                bbox = im.getbbox()

                if not bbox:
                    if current_action_frames:
                        current_action_frames[-1]["ticks"] += 1
                    continue

                crop_im = im.crop(bbox)
                axis_x = origin_x - bbox[0]
                axis_y = origin_y - bbox[1]

                img_bytes = crop_im.tobytes()

                if img_bytes == last_img_bytes and (axis_x, axis_y) == last_axis:
                    if current_action_frames:
                        current_action_frames[-1]["ticks"] += 1
                else:
                    spr_num = sub_num
                    sub_num += 1

                    sprite_items.append({
                        "group": action_no,
                        "number": spr_num,
                        "image": crop_im,
                        "axis_x": axis_x,
                        "axis_y": axis_y
                    })

                    current_action_frames.append({
                        "group": action_no,
                        "number": spr_num,
                        "offset_x": 0,
                        "offset_y": 0,
                        "ticks": 1
                    })

                    last_img_bytes = img_bytes
                    last_axis = (axis_x, axis_y)
                    last_spr_num = spr_num

            if current_action_frames:
                air_actions.append((action_no, lbl, current_action_frames))

        sbs_path = out_dir_path / f"{char_id}.sbs"
        print(f"Packing Texture Atlas SBS ({atlas_size}x{atlas_size})...")
        writer = SbsWriter(atlas_format=atlas_format, max_atlas_size=atlas_size, padding=padding)
        writer.pack_sprites(sprite_items)
        writer.write(str(sbs_path))
        print(f"File SBS tersimpan: {sbs_path} ({sbs_path.stat().st_size / 1024:.2f} KB, {len(writer.packer.sheets)} lembar).")

        air_path = out_dir_path / f"{char_id}.air"
        with open(air_path, "w", encoding="utf-8") as f_air:
            f_air.write(f"; STARBLAST Animation Definition (.air)\n")
            f_air.write(f"; Karakter: {char_name} ({char_id})\n\n")

            for act_no, lbl_name, frames in air_actions:
                f_air.write(f"; {lbl_name}\n")
                f_air.write(f"[Begin Action {act_no}]\n")
                f_air.write("Clsn2Default: 1\n")
                f_air.write("  Clsn2[0] = -20, -70, 20, 0\n")
                for fr in frames:
                    f_air.write(f"  {fr['group']}, {fr['number']}, {fr['offset_x']}, {fr['offset_y']}, {fr['ticks'] * 2}\n")
                f_air.write("\n")

        print(f"File AIR tersimpan: {air_path}.")

        cns_path = out_dir_path / f"{char_id}.cns"
        if not cns_path.exists():
            with open(cns_path, "w", encoding="utf-8") as f_cns:
                f_cns.write(f"; STARBLAST Character CNS Definition\n")
                f_cns.write(f"[Data]\n")
                f_cns.write(f"life = 1000\n")
                f_cns.write(f"power = 3000\n")
                f_cns.write(f"attack = 100\n")
                f_cns.write(f"defence = 100\n")
                f_cns.write(f"[Size]\n")
                f_cns.write(f"xscale = 1\n")
                f_cns.write(f"yscale = 1\n")
                f_cns.write(f"ground.back = 15\n")
                f_cns.write(f"ground.front = 16\n")
                f_cns.write(f"air.back = 12\n")
                f_cns.write(f"air.front = 12\n")
                f_cns.write(f"height = 60\n")
                f_cns.write(f"[Velocity]\n")
                f_cns.write(f"walk.fwd = 2.4\n")
                f_cns.write(f"walk.back = -2.2\n")
                f_cns.write(f"run.fwd = 6.5, 0\n")
                f_cns.write(f"jump.neu = 0, -8.5\n")
                f_cns.write(f"jump.back = -2.55\n")
                f_cns.write(f"jump.fwd = 2.55\n")
                f_cns.write(f"[Movement]\n")
                f_cns.write(f"airjump.num = 0\n")
                f_cns.write(f"yaccel = 0.44\n")
                f_cns.write(f"stand.friction = 0.85\n")
                f_cns.write(f"crouch.friction = 0.82\n")

        json_path = out_dir_path / "character.json"
        char_meta = {
            "id": char_id,
            "name": char_name,
            "sbs": f"{char_id}.sbs",
            "air": f"{char_id}.air",
            "cns": f"{char_id}.cns",
            "face": "face.png",
            "face_big": "face_big.png",
            "face_bar": "face_bar.png",
            "face_win": "face_win.png",
            "selectable": True
        }
        with open(json_path, "w", encoding="utf-8") as f_json:
            json.dump(char_meta, f_json, indent=2)

        print(f"File character.json tersimpan: {json_path}.")

        reader = SbsReader(str(sbs_path))
        print(f"Verifikasi SBS: Total Sprites = {reader.header.total_sprites}, Sheets = {reader.header.total_sheets}")

    finally:
        shutil.rmtree(temp_export_dir, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description="STARBLAST SWF to SBS Converter")
    parser.add_argument("input_swf", help="File input Flash SWF karakter")
    parser.add_argument("-o", "--output-dir", required=True, help="Folder output untuk menyimpan .sbs, .air, .json")
    parser.add_argument("--id", default="flandre", help="ID karakter (default: flandre)")
    parser.add_argument("--name", default="Flandre Scarlet", help="Nama karakter")
    parser.add_argument("--max-frames", type=int, default=None, help="Batasi maksimal frame yang diekstrak")
    parser.add_argument("--actions", nargs="+", default=None, help="Daftar nama aksi yang akan diekstrak")
    parser.add_argument("--origin-x", type=int, default=760, help="Pivot origin X Flash (default: 760)")
    parser.add_argument("--origin-y", type=int, default=475, help="Pivot origin Y Flash (default: 475)")
    parser.add_argument("--atlas-size", type=int, default=2048, help="Ukuran sheet atlas (default: 2048)")
    parser.add_argument("--format", choices=["png", "zlib"], default="png", help="Format atlas (png atau zlib)")

    args = parser.parse_args()
    fmt = ATLAS_FMT_ZLIB_RGBA if args.format == "zlib" else ATLAS_FMT_PNG

    convert_swf_to_sbs(
        swf_path=args.input_swf,
        out_dir=args.output_dir,
        char_id=args.id,
        char_name=args.name,
        max_frames=args.max_frames,
        actions_filter=args.actions,
        origin_x=args.origin_x,
        origin_y=args.origin_y,
        atlas_format=fmt,
        atlas_size=args.atlas_size
    )


if __name__ == "__main__":
    main()
