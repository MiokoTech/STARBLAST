"""
STARBLAST Sprite (.sbs) Format Module
Spesifikasi format binary sprite kustom berbasis Texture Atlas untuk engine STARBLAST.
"""

import io
import os
import struct
import zlib
from typing import Dict, List, Optional, Tuple, BinaryIO
from PIL import Image

SBS_MAGIC = b"SBS1"
SBS_VERSION = 1

# Format Atlas
ATLAS_FMT_PNG = 1         # Kompresi stream PNG
ATLAS_FMT_ZLIB_RGBA = 2   # Kompresi raw RGBA8888 via zlib stream

HEADER_STRUCT = "<4sHH I H B B I I I I"
HEADER_SIZE = struct.calcsize(HEADER_STRUCT)  # 32 bytes

SPRITE_ENTRY_STRUCT = "<ii H H H H H H h h"
SPRITE_ENTRY_SIZE = struct.calcsize(SPRITE_ENTRY_STRUCT)  # 24 bytes

SHEET_HEADER_STRUCT = "<HHI"
SHEET_HEADER_SIZE = struct.calcsize(SHEET_HEADER_STRUCT)  # 8 bytes


class SbsHeader:
    def __init__(self):
        self.magic = SBS_MAGIC
        self.version = SBS_VERSION
        self.flags = 0
        self.total_sprites = 0
        self.total_sheets = 0
        self.atlas_format = ATLAS_FMT_PNG
        self.sprite_table_offset = 0
        self.atlas_table_offset = 0

    def pack(self) -> bytes:
        return struct.pack(
            HEADER_STRUCT,
            self.magic,
            self.version,
            self.flags,
            self.total_sprites,
            self.total_sheets,
            self.atlas_format,
            0,  # reserved1
            self.sprite_table_offset,
            self.atlas_table_offset,
            0,  # reserved2
            0   # reserved3
        )

    @classmethod
    def unpack(cls, data: bytes) -> "SbsHeader":
        if len(data) < HEADER_SIZE:
            raise ValueError("Data terlalu pendek untuk header SBS.")
        unpacked = struct.unpack(HEADER_STRUCT, data[:HEADER_SIZE])
        magic, ver, flags, spr_count, sheet_count, fmt, _, spr_ofs, atlas_ofs, _, _ = unpacked
        if magic != SBS_MAGIC:
            raise ValueError(f"Bukan file SBS valid. Magic: {magic}")
        h = cls()
        h.magic = magic
        h.version = ver
        h.flags = flags
        h.total_sprites = spr_count
        h.total_sheets = sheet_count
        h.atlas_format = fmt
        h.sprite_table_offset = spr_ofs
        h.atlas_table_offset = atlas_ofs
        return h


class SbsSpriteEntry:
    def __init__(
        self,
        group: int = 0,
        number: int = 0,
        sheet_id: int = 0,
        flags: int = 0,
        atlas_x: int = 0,
        atlas_y: int = 0,
        width: int = 0,
        height: int = 0,
        axis_x: int = 0,
        axis_y: int = 0
    ):
        self.group = group
        self.number = number
        self.sheet_id = sheet_id
        self.flags = flags
        self.atlas_x = atlas_x
        self.atlas_y = atlas_y
        self.width = width
        self.height = height
        self.axis_x = axis_x
        self.axis_y = axis_y

    def pack(self) -> bytes:
        return struct.pack(
            SPRITE_ENTRY_STRUCT,
            self.group,
            self.number,
            self.sheet_id,
            self.flags,
            self.atlas_x,
            self.atlas_y,
            self.width,
            self.height,
            self.axis_x,
            self.axis_y
        )

    @classmethod
    def unpack(cls, data: bytes) -> "SbsSpriteEntry":
        unpacked = struct.unpack(SPRITE_ENTRY_STRUCT, data[:SPRITE_ENTRY_SIZE])
        return cls(*unpacked)

    def to_dict(self) -> dict:
        return {
            "group": self.group,
            "number": self.number,
            "sheet_id": self.sheet_id,
            "flags": self.flags,
            "atlas_x": self.atlas_x,
            "atlas_y": self.atlas_y,
            "width": self.width,
            "height": self.height,
            "axis_x": self.axis_x,
            "axis_y": self.axis_y
        }


class SbsAtlasSheet:
    def __init__(self, width: int = 2048, height: int = 2048):
        self.width = width
        self.height = height
        self.image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        self.data: bytes = b""

    def encode(self, atlas_format: int = ATLAS_FMT_PNG) -> bytes:
        if atlas_format == ATLAS_FMT_PNG:
            bio = io.BytesIO()
            self.image.save(bio, format="PNG", optimize=True)
            self.data = bio.getvalue()
        elif atlas_format == ATLAS_FMT_ZLIB_RGBA:
            raw_rgba = self.image.tobytes("raw", "RGBA")
            self.data = zlib.compress(raw_rgba, level=6)
        else:
            raise ValueError(f"Atlas format {atlas_format} tidak dikenal.")
        return self.data


class ShelfBinPacker:
    """Algoritma Shelf Bin Packing untuk menyusun ribuan sprite ke beberapa lembar atlas."""
    def __init__(self, max_width: int = 2048, max_height: int = 2048, padding: int = 1):
        self.max_width = max_width
        self.max_height = max_height
        self.padding = padding
        self.sheets: List[SbsAtlasSheet] = []
        self._cur_sheet_idx = -1
        self._cur_x = padding
        self._cur_y = padding
        self._shelf_h = 0
        self._new_sheet()

    def _new_sheet(self):
        self.sheets.append(SbsAtlasSheet(self.max_width, self.max_height))
        self._cur_sheet_idx = len(self.sheets) - 1
        self._cur_x = self.padding
        self._cur_y = self.padding
        self._shelf_h = 0

    def insert(self, w: int, h: int) -> Tuple[int, int, int]:
        """Memasukkan kotak w x h ke atlas. Mengembalikan (sheet_id, x, y)."""
        if w <= 0 or h <= 0:
            return (0, 0, 0)

        alloc_w = w + self.padding
        alloc_h = h + self.padding

        if self._cur_x + alloc_w > self.max_width:
            self._cur_y += self._shelf_h
            self._cur_x = self.padding
            self._shelf_h = 0

        if self._cur_y + alloc_h > self.max_height:
            self._new_sheet()

        sheet_id = self._cur_sheet_idx
        res_x = self._cur_x
        res_y = self._cur_y

        self._cur_x += alloc_w
        if alloc_h > self._shelf_h:
            self._shelf_h = alloc_h

        return (sheet_id, res_x, res_y)


class SbsWriter:
    """Builder file biner .sbs dari sekumpulan sprite."""
    def __init__(self, atlas_format: int = ATLAS_FMT_PNG, max_atlas_size: int = 2048, padding: int = 1):
        self.atlas_format = atlas_format
        self.max_atlas_size = max_atlas_size
        self.padding = padding
        self.packer = ShelfBinPacker(max_atlas_size, max_atlas_size, padding)
        self.entries: List[SbsSpriteEntry] = []

    def pack_sprites(self, sprite_items: List[dict]) -> None:
        """
        sprite_items: list of dict berisi:
          - 'group': int
          - 'number': int
          - 'image': PIL.Image.Image (RGBA) atau None jika linked/kosong
          - 'axis_x': int
          - 'axis_y': int
          - 'link_idx': Optional[int] indeks item target jika sprite linked
        """
        # Pisahkan sprite unik dengan gambar nyata vs sprite linked
        placed_map: Dict[int, Tuple[int, int, int, int, int]] = {} # item_idx -> (sheet_id, x, y, w, h)

        # Sortir sprite berbobot berdasarkan tinggi gambar (descending) untuk efisiensi packing optimal
        sortable = []
        for i, item in enumerate(sprite_items):
            img = item.get("image")
            if img and item.get("link_idx") is None and img.width > 0 and img.height > 0:
                sortable.append((img.height, img.width, i))
            else:
                sortable.append((-1, -1, i))

        # Hanya urutkan yang punya gambar fisik nyata
        valid_items = sorted([x for x in sortable if x[0] > 0], key=lambda k: k[0], reverse=True)

        for _, _, idx in valid_items:
            item = sprite_items[idx]
            img: Image.Image = item["image"]
            w, h = img.size
            sheet_id, ax, ay = self.packer.insert(w, h)
            # Tempelkan gambar ke atlas sheet
            self.packer.sheets[sheet_id].image.paste(img, (ax, ay))
            placed_map[idx] = (sheet_id, ax, ay, w, h)

        # Bangun entries sesuai urutan asli
        self.entries = []
        for i, item in enumerate(sprite_items):
            group = item["group"]
            number = item["number"]
            axis_x = item["axis_x"]
            axis_y = item["axis_y"]
            link_idx = item.get("link_idx")

            target_idx = link_idx if link_idx is not None and link_idx in placed_map else i

            if target_idx in placed_map:
                sheet_id, ax, ay, w, h = placed_map[target_idx]
                flags = 1 if (link_idx is not None) else 0
                entry = SbsSpriteEntry(
                    group=group,
                    number=number,
                    sheet_id=sheet_id,
                    flags=flags,
                    atlas_x=ax,
                    atlas_y=ay,
                    width=w,
                    height=h,
                    axis_x=axis_x,
                    axis_y=axis_y
                )
            else:
                # Sprite kosong / dimensi 0
                entry = SbsSpriteEntry(
                    group=group,
                    number=number,
                    sheet_id=0,
                    flags=0,
                    atlas_x=0,
                    atlas_y=0,
                    width=0,
                    height=0,
                    axis_x=axis_x,
                    axis_y=axis_y
                )
            self.entries.append(entry)

    def write(self, out_path: str) -> None:
        """Mengompilasi dan menyimpan file biner .sbs ke disk."""
        header = SbsHeader()
        header.total_sprites = len(self.entries)
        header.total_sheets = len(self.packer.sheets)
        header.atlas_format = self.atlas_format
        header.sprite_table_offset = HEADER_SIZE

        # Hitung offset tabel atlas
        sprite_table_bytes = b"".join(e.pack() for e in self.entries)
        header.atlas_table_offset = header.sprite_table_offset + len(sprite_table_bytes)

        # Encode tiap sheet atlas
        encoded_sheets = []
        for sheet in self.packer.sheets:
            sheet_data = sheet.encode(self.atlas_format)
            encoded_sheets.append((sheet.width, sheet.height, sheet_data))

        with open(out_path, "wb") as f:
            # Header
            f.write(header.pack())

            # Tabel Sprite Metadata
            f.write(sprite_table_bytes)

            # Chunk Atlas
            for w, h, data in encoded_sheets:
                sheet_hdr = struct.pack(SHEET_HEADER_STRUCT, w, h, len(data))
                f.write(sheet_hdr)
                f.write(data)


class SbsReader:
    """Reader file biner .sbs untuk membaca metadata dan mengekstrak gambar sprite."""
    def __init__(self, filepath: str):
        self.filepath = filepath
        self.header = SbsHeader()
        self.entries: List[SbsSpriteEntry] = []
        self.sheets: List[Image.Image] = []
        self._map: Dict[Tuple[int, int], SbsSpriteEntry] = {}
        self._load()

    def _load(self):
        with open(self.filepath, "rb") as f:
            header_bytes = f.read(HEADER_SIZE)
            self.header = SbsHeader.unpack(header_bytes)

            # Baca tabel sprite
            f.seek(self.header.sprite_table_offset)
            spr_bytes = f.read(self.header.total_sprites * SPRITE_ENTRY_SIZE)
            self.entries = []
            for i in range(self.header.total_sprites):
                chunk = spr_bytes[i * SPRITE_ENTRY_SIZE : (i + 1) * SPRITE_ENTRY_SIZE]
                entry = SbsSpriteEntry.unpack(chunk)
                self.entries.append(entry)
                self._map[(entry.group, entry.number)] = entry

            f.seek(self.header.atlas_table_offset)
            self.sheets = []
            for _ in range(self.header.total_sheets):
                hdr_bytes = f.read(SHEET_HEADER_SIZE)
                if len(hdr_bytes) < SHEET_HEADER_SIZE:
                    break
                w, h, data_len = struct.unpack(SHEET_HEADER_STRUCT, hdr_bytes)
                sheet_data = f.read(data_len)
                if self.header.atlas_format == ATLAS_FMT_PNG:
                    img = Image.open(io.BytesIO(sheet_data)).convert("RGBA")
                    self.sheets.append(img)
                elif self.header.atlas_format == ATLAS_FMT_ZLIB_RGBA:
                    raw_rgba = zlib.decompress(sheet_data)
                    img = Image.frombytes("RGBA", (w, h), raw_rgba)
                    self.sheets.append(img)
                else:
                    raise ValueError(f"Atlas format {self.header.atlas_format} tidak didukung.")

    def get_entry(self, group: int, number: int) -> Optional[SbsSpriteEntry]:
        return self._map.get((group, number))

    def get_sprite_image(self, entry: SbsSpriteEntry) -> Optional[Image.Image]:
        if entry.width <= 0 or entry.height <= 0:
            return None
        if entry.sheet_id >= len(self.sheets):
            return None
        sheet = self.sheets[entry.sheet_id]
        box = (entry.atlas_x, entry.atlas_y, entry.atlas_x + entry.width, entry.atlas_y + entry.height)
        return sheet.crop(box)
