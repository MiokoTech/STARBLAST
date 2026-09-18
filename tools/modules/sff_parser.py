#!/usr/bin/env python3
import io
import json
import os
import struct
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from PIL import Image

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
        self.palettes: List[bytes] = []
        self.pal_map: Dict[Tuple[int, int], int] = {}

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

    def read_palette_table(self, f) -> None:
        self.palettes = []
        self.pal_map = {}
        ver_hi = self.header.version[3]
        if ver_hi == 2:
            self._read_palette_table_v2(f)

    def _read_palette_table_v2(self, f) -> None:
        f.seek(self.header.first_palette_offset)
        raw_headers = [f.read(16) for _ in range(self.header.num_palettes)]

        for i, raw in enumerate(raw_headers):
            if len(raw) < 16:
                break
            group, number, cols, link, ofs, pl_size = struct.unpack("<HHHHII", raw)
            self.pal_map[(group, number)] = i

            if pl_size == 0:
                if link < len(self.palettes):
                    self.palettes.append(self.palettes[link])
                else:
                    self.palettes.append(bytes(1024))
            else:
                f.seek(self.header.lofs + ofs)
                pal_raw = f.read(pl_size)
                pal_flat = bytearray(1024)
                num_colors = min(len(pal_raw) // 4, 256)
                for c_idx in range(num_colors):
                    r = pal_raw[c_idx * 4]
                    g = pal_raw[c_idx * 4 + 1]
                    b = pal_raw[c_idx * 4 + 2]
                    a = pal_raw[c_idx * 4 + 3]
                    if self.header.version[2] == 0:
                        a = 0 if c_idx == 0 else 255
                    pal_flat[c_idx * 4 : c_idx * 4 + 4] = bytes([r, g, b, a])
                self.palettes.append(bytes(pal_flat))

    @staticmethod
    def decode_rle8(rle_data: bytes, expected_len: int) -> bytes:
        p = bytearray(expected_len)
        i = 0
        j = 0
        rle_len = len(rle_data)
        while j < expected_len and i < rle_len:
            d = rle_data[i]
            i += 1
            n = 1
            if (d & 0xC0) == 0x40:
                n = d & 0x3F
                if i < rle_len:
                    d = rle_data[i]
                    i += 1
                else:
                    d = 0
            end_j = min(j + n, expected_len)
            p[j:end_j] = bytes([d]) * (end_j - j)
            j = end_j
        return bytes(p)

    def get_sprite_image(self, spr: SpriteEntry, f) -> Optional[Image.Image]:
        if spr.is_linked:
            return None

        ver_hi = self.header.version[3]
        if ver_hi == 2:
            if spr.format == 2:
                f.seek(spr.real_offset)
                uncompressed_len = struct.unpack("<I", f.read(4))[0]
                rle_data = f.read(spr.size - 4)
                indices = self.decode_rle8(rle_data, uncompressed_len)
                pal_bytes = self.palettes[spr.pal_idx] if spr.pal_idx < len(self.palettes) else bytes(1024)
                img = Image.frombytes("P", (spr.width, spr.height), indices)
                img.putpalette(pal_bytes, rawmode="RGBA")
                return img.convert("RGBA")
            elif spr.format == 10:
                f.seek(spr.real_offset + 4)
                data = f.read(spr.size - 4)
                if data.startswith(b"\x89PNG\r\n\x1a\n"):
                    img = Image.open(io.BytesIO(data))
                    pal_bytes = self.palettes[spr.pal_idx] if spr.pal_idx < len(self.palettes) else bytes(1024)
                    img.putpalette(pal_bytes, rawmode="RGBA")
                    return img.convert("RGBA")
            elif spr.format in (11, 12):
                f.seek(spr.real_offset + 4)
                data = f.read(spr.size - 4)
                if data.startswith(b"\x89PNG\r\n\x1a\n"):
                    return Image.open(io.BytesIO(data)).convert("RGBA")
        return None

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
        exported_images: Dict[int, Image.Image] = {}
        count = 0

        with open(self.filepath, "rb") as f:
            self.read_header(f)
            self.read_palette_table(f)
            self.read_sprite_table(f)

            for spr in self.sprites:
                if filter_group is not None and spr.group != filter_group:
                    continue

                img: Optional[Image.Image] = None

                if spr.is_linked:
                    if spr.link in exported_images:
                        img = exported_images[spr.link]
                    else:
                        print(f"[!] Peringatan: Linked sprite {spr.index} (link={spr.link}) tidak ditemukan dalam cache.")
                else:
                    img = self.get_sprite_image(spr, f)

                if img:
                    exported_images[spr.index] = img

                    filename = f"{spr.group}_{spr.number}.png"
                    out_path = os.path.join(out_dir, filename)
                    img.save(out_path, format="PNG", compress_level=1)

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
