#!/usr/bin/env python3
import io
import json
import os
import struct
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class SffHeader:
    """Header file SFF."""
    def __init__(self):
        self.signature = b""
        self.version = [0, 0, 0, 0]  # [verlo3, verlo2, verlo1, verhi]
        self.num_sprites = 0
        self.first_sprite_offset = 0
        self.num_palettes = 0
        self.first_palette_offset = 0
        self.lofs = 0
        self.tofs = 0

class SpriteEntry:
    """Metadata entri tiap sprite dalam SFF."""
    def __init__(self):
        self.index = 0
        self.group = 0
        self.number = 0
        self.width = 0
        self.height = 0
        self.axis_x = 0
        self.axis_y = 0
        self.link = 0
        self.format = 0
        self.col_depth = 0
        self.offset = 0
        self.size = 0
        self.pal_idx = 0
        self.flags = 0
        self.real_offset = 0
        self.is_linked = False

class SffReader:
    def __init__(self, filepath: str):
        self.filepath = filepath
        self.header = SffHeader()
        self.sprites: List[SpriteEntry] = []

    def read_header(self, f) -> None:
        raw_header = f.read(512)
        if len(raw_header) < 32:
            raise ValueError("File terlalu kecil untuk header SFF valid.")

        sig = raw_header[:12]
        if not sig.startswith(b"ElecbyteSpr\x00"):
            raise ValueError("Bukan file SFF valid (signature tidak cocok).")

        self.header.signature = sig
        self.header.version = list(raw_header[12:16])
        ver_hi = self.header.version[3]

        if ver_hi == 2:
            # SFF v2
            (
                spr_ofs,
                num_spr,
                pal_ofs,
                num_pal,
                lofs,
                dummy,
                tofs,
            ) = struct.unpack("<7I", raw_header[36:64])
            self.header.first_sprite_offset = spr_ofs
            self.header.num_sprites = num_spr
            self.header.first_palette_offset = pal_ofs
            self.header.num_palettes = num_pal
            self.header.lofs = lofs
            self.header.tofs = tofs
        elif ver_hi == 1:
            # SFF v1
            num_spr, spr_ofs = struct.unpack("<II", raw_header[16:24])
            self.header.num_sprites = num_spr
            self.header.first_sprite_offset = spr_ofs
        else:
            raise ValueError(f"Versi SFF {ver_hi} tidak didukung.")

    def read_sprite_table(self, f) -> None:
        self.sprites = []
        ver_hi = self.header.version[3]
        if ver_hi == 2:
            self._read_sprite_table_v2(f)
        else:
            self._read_sprite_table_v1(f)

    def _read_sprite_table_v2(self, f) -> None:
        f.seek(self.header.first_sprite_offset)
        for i in range(self.header.num_sprites):
            raw = f.read(28)
            if len(raw) < 28:
                break
            (
                group,
                number,
                w,
                h,
                ax,
                ay,
                link,
                fmt,
                depth,
                ofs,
                size,
                palidx,
                flags,
            ) = struct.unpack("<HH H H h h H B B I I H H", raw)

            entry = SpriteEntry()
            entry.index = i
            entry.group = group
            entry.number = number
            entry.width = w
            entry.height = h
            entry.axis_x = ax
            entry.axis_y = ay
            entry.link = link
            entry.format = fmt
            entry.col_depth = depth
            entry.offset = ofs
            entry.size = size
            entry.pal_idx = palidx
            entry.flags = flags

            if size == 0:
                entry.is_linked = True
            else:
                base_ofs = self.header.tofs if (flags & 1) else self.header.lofs
                entry.real_offset = ofs + base_ofs

            self.sprites.append(entry)

    def _read_sprite_table_v1(self, f) -> None:
        cur_ofs = self.header.first_sprite_offset
        for i in range(self.header.num_sprites):
            f.seek(cur_ofs)
            raw = f.read(32)
            if len(raw) < 32:
                break
            next_ofs, sub_len, ax, ay, group, number, prev_idx, same_pal = struct.unpack(
                "<IIhhHHHB", raw[:25]
            )
            entry = SpriteEntry()
            entry.index = i
            entry.group = group
            entry.number = number
            entry.axis_x = ax
            entry.axis_y = ay
            entry.link = prev_idx
            entry.offset = cur_ofs + 32
            entry.size = sub_len
            entry.is_linked = (sub_len == 0)
            self.sprites.append(entry)
            if next_ofs == 0:
                break
            cur_ofs = next_ofs

    def export_all(
        self,
        out_dir: str,
        filter_group: Optional[int] = None,
        save_json: bool = True
    ) -> int:
        os.makedirs(out_dir, exist_ok=True)
        meta_list = []
        exported_bytes_cache: Dict[int, bytes] = {}
        count = 0

        with open(self.filepath, "rb") as f:
            self.read_header(f)
            self.read_sprite_table(f)

            for spr in self.sprites:
                if filter_group is not None and spr.group != filter_group:
                    continue

                png_data: Optional[bytes] = None

                if spr.is_linked:
                    if spr.link in exported_bytes_cache:
                        png_data = exported_bytes_cache[spr.link]
                    else:
                        print(f"[!] Peringatan: Linked sprite {spr.index} (link={spr.link}) tidak ditemukan dalam cache.")
                else:
                    ver_hi = self.header.version[3]
                    if ver_hi == 2:
                        if spr.format in (10, 11, 12):
                            f.seek(spr.real_offset + 4)
                            data = f.read(spr.size - 4)
                            if data.startswith(b"\x89PNG\r\n\x1a\n"):
                                png_data = data
                            else:
                                print(f"[!] Peringatan: Sprite {spr.group},{spr.number} bukan data PNG valid.")
                        else:
                            print(f"[!] Peringatan: Format kompresi {spr.format} belum didukung untuk ekspor langsung.")

                if png_data:
                    exported_bytes_cache[spr.index] = png_data

                    filename = f"{spr.group}_{spr.number}.png"
                    out_path = os.path.join(out_dir, filename)
                    with open(out_path, "wb") as out_f:
                        out_f.write(png_data)

                    count += 1
                    meta_list.append({
                        "index": spr.index,
                        "group": spr.group,
                        "number": spr.number,
                        "width": spr.width,
                        "height": spr.height,
                        "axis_x": spr.axis_x,
                        "axis_y": spr.axis_y,
                        "format": spr.format,
                        "col_depth": spr.col_depth,
                        "filename": filename,
                        "is_linked": spr.is_linked,
                        "link": spr.link if spr.is_linked else None,
                    })

        if save_json:
            meta_path = os.path.join(out_dir, "metadata.json")
            with open(meta_path, "w", encoding="utf-8") as jf:
                json.dump(
                    {
                        "source": os.path.basename(self.filepath),
                        "total_sprites": count,
                        "sprites": meta_list,
                    },
                    jf,
                    indent=2,
                )
            print(f"[+] Metadata tersimpan di {meta_path}")

        return count
