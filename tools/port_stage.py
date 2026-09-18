#!/usr/bin/env python3
"""
STARBLAST Mugen Stage Porting Tool
"""

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from PIL import Image

# Tambahkan direktori tools/ ke sys.path untuk import modul
tools_dir = Path(__file__).resolve().parent
if str(tools_dir) not in sys.path:
    sys.path.insert(0, str(tools_dir))

from modules.sff_parser import SffReader, SpriteEntry


class StageDefParser:
    """Parser lengkap file definisi stage Mugen/Ikemen (.def)."""

    def __init__(self, def_path: Path):
        self.def_path = def_path
        self.info: Dict[str, Any] = {}
        self.camera: Dict[str, Any] = {}
        self.playerinfo: Dict[str, Any] = {}
        self.bound: Dict[str, Any] = {}
        self.stageinfo: Dict[str, Any] = {}
        self.shadow: Dict[str, Any] = {}
        self.reflection: Dict[str, Any] = {}
        self.music: Dict[str, Any] = {}
        self.bgdef: Dict[str, Any] = {}
        self.bgctrldef: Dict[str, Any] = {"looptime": -1, "ctrlid": -1}
        self.bgctrls: List[Dict[str, Any]] = []
        self.layers: List[Dict[str, Any]] = []
        self.actions: Dict[int, List[Dict[str, Any]]] = {}

    def parse(self) -> None:
        if not self.def_path.is_file():
            raise FileNotFoundError(f"File def tidak ditemukan: {self.def_path}")

        with open(self.def_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()

        current_sec_name = ""
        current_action_no: Optional[int] = None
        current_sec_data: Dict[str, str] = {}
        bg_counter = 0

        for raw_line in lines:
            line = raw_line.strip()
            if not line or line.startswith(";") or line.startswith("#"):
                continue

            sec_match = re.match(r"^\[(.*?)\]", line)
            if sec_match:
                self._commit_section(current_sec_name, current_action_no, current_sec_data, bg_counter)
                if current_sec_name.lower().startswith("bg ") or current_sec_name.lower() == "bg":
                    bg_counter += 1

                header_content = sec_match.group(1).strip()
                current_sec_data = {}

                action_match = re.match(r"^begin\s+action\s+(\d+)", header_content, re.IGNORECASE)
                if action_match:
                    current_sec_name = "action"
                    current_action_no = int(action_match.group(1))
                    if current_action_no not in self.actions:
                        self.actions[current_action_no] = []
                else:
                    current_sec_name = header_content
                    current_action_no = None
                continue

            if current_action_no is not None:
                frame_data = self._parse_action_line(line)
                if frame_data:
                    self.actions[current_action_no].append(frame_data)
                continue

            if "=" in line:
                clean_line = re.split(r"[;#]", line, maxsplit=1)[0].strip()
                if "=" in clean_line:
                    k, v = clean_line.split("=", 1)
                    current_sec_data[k.strip().lower()] = v.strip().strip('"')

        self._commit_section(current_sec_name, current_action_no, current_sec_data, bg_counter)

    def _commit_section(
        self, sec_name: str, action_no: Optional[int], sec_data: Dict[str, str], bg_counter: int
    ) -> None:
        if not sec_name or action_no is not None or not sec_data:
            return

        sec_lower = sec_name.lower()

        if sec_lower == "info":
            self.info = {
                "name": sec_data.get("name", self.def_path.stem),
                "displayname": sec_data.get("displayname", sec_data.get("name", self.def_path.stem)),
                "author": sec_data.get("author", "Unknown"),
                "versiondate": sec_data.get("versiondate", ""),
                "mugenversion": sec_data.get("mugenversion", "1.0"),
            }
        elif sec_lower == "camera":
            self.camera = {
                "startx": self._parse_float(sec_data.get("startx", "0")),
                "starty": self._parse_float(sec_data.get("starty", "0")),
                "boundleft": self._parse_float(sec_data.get("boundleft", "-500")),
                "boundright": self._parse_float(sec_data.get("boundright", "500")),
                "boundhigh": self._parse_float(sec_data.get("boundhigh", "-450")),
                "boundlow": self._parse_float(sec_data.get("boundlow", "0")),
                "verticalfollow": self._parse_float(sec_data.get("verticalfollow", "0.85")),
                "floortension": self._parse_float(sec_data.get("floortension", "200")),
                "tension": self._parse_float(sec_data.get("tension", "200")),
                "overdrawhigh": self._parse_float(sec_data.get("overdrawhigh", "0")),
                "overdrawlow": self._parse_float(sec_data.get("overdrawlow", "0")),
                "cuthigh": self._parse_float(sec_data.get("cuthigh", "0")),
                "cutlow": self._parse_float(sec_data.get("cutlow", "0")),
                "zoomout": self._parse_float(sec_data.get("zoomout", "1.0")),
                "zoomin": self._parse_float(sec_data.get("zoomin", "1.0")),
            }
        elif sec_lower == "playerinfo":
            self.playerinfo = {
                "p1startx": self._parse_float(sec_data.get("p1startx", "-280")),
                "p1starty": self._parse_float(sec_data.get("p1starty", "0")),
                "p1facing": self._parse_int(sec_data.get("p1facing", "1")),
                "p2startx": self._parse_float(sec_data.get("p2startx", "280")),
                "p2starty": self._parse_float(sec_data.get("p2starty", "0")),
                "p2facing": self._parse_int(sec_data.get("p2facing", "-1")),
                "p3startx": self._parse_float(sec_data.get("p3startx", "-400")),
                "p3starty": self._parse_float(sec_data.get("p3starty", "0")),
                "p3facing": self._parse_int(sec_data.get("p3facing", "1")),
                "p4startx": self._parse_float(sec_data.get("p4startx", "400")),
                "p4starty": self._parse_float(sec_data.get("p4starty", "0")),
                "p4facing": self._parse_int(sec_data.get("p4facing", "-1")),
                "leftbound": self._parse_float(sec_data.get("leftbound", "-4000")),
                "rightbound": self._parse_float(sec_data.get("rightbound", "4000")),
            }
        elif sec_lower == "bound":
            self.bound = {
                "screenleft": self._parse_float(sec_data.get("screenleft", "60")),
                "screenright": self._parse_float(sec_data.get("screenright", "60")),
            }
        elif sec_lower == "stageinfo":
            localcoord = self._parse_int_list(sec_data.get("localcoord", "1280, 720"))
            if len(localcoord) < 2:
                localcoord = [1280, 720]
            self.stageinfo = {
                "zoffset": self._parse_float(sec_data.get("zoffset", "660")),
                "autoturn": bool(self._parse_int(sec_data.get("autoturn", "1"))),
                "resetBG": bool(self._parse_int(sec_data.get("resetbg", "1"))),
                "localcoord": localcoord,
                "xscale": self._parse_float(sec_data.get("xscale", "1.0")),
                "yscale": self._parse_float(sec_data.get("yscale", "1.0")),
                "hires": bool(self._parse_int(sec_data.get("hires", "0"))),
            }
        elif sec_lower == "shadow":
            self.shadow = {
                "intensity": self._parse_int(sec_data.get("intensity", "128")),
                "color": self._parse_int_list(sec_data.get("color", "0,0,0")),
                "yscale": self._parse_float(sec_data.get("yscale", "0.4")),
                "fade_range": self._parse_float_list(sec_data.get("fade.range", "0,0")),
            }
        elif sec_lower == "reflection":
            self.reflection = {
                "intensity": self._parse_int(sec_data.get("intensity", "0")),
            }
        elif sec_lower == "music":
            self.music = {
                "bgmusic": sec_data.get("bgmusic", ""),
                "bgmvolume": self._parse_int(sec_data.get("bgmvolume", "100")),
                "bgmloopstart": self._parse_int(sec_data.get("bgmloopstart", "0")),
                "bgmloopend": self._parse_int(sec_data.get("bgmloopend", "0")),
            }
        elif sec_lower == "bgdef":
            self.bgdef = {
                "spr": sec_data.get("spr", ""),
                "debugbg": self._parse_int(sec_data.get("debugbg", "0")),
            }
        elif sec_lower.startswith("bgctrldef"):
            self.bgctrldef = {
                "looptime": self._parse_int(sec_data.get("looptime", "-1")),
                "ctrlid": self._parse_int(sec_data.get("ctrlid", sec_data.get("ctrl_id", "-1"))),
            }
        elif sec_lower.startswith("bgctrl"):
            ctrl_type = sec_data.get("type", "VelSet")
            raw_ctrl_id = sec_data.get("ctrlid", sec_data.get("id", ""))
            ctrl_id = self._parse_int(raw_ctrl_id) if raw_ctrl_id else self.bgctrldef.get("ctrlid", -1)
            time_list = self._parse_int_list(sec_data.get("time", "0,0,-1"))
            loop_fallback = self.bgctrldef.get("looptime", -1)
            if len(time_list) == 1:
                time_spec = [time_list[0], time_list[0], loop_fallback]
            elif len(time_list) == 2:
                time_spec = [time_list[0], time_list[1], loop_fallback]
            elif len(time_list) >= 3:
                time_spec = [time_list[0], time_list[1], time_list[2]]
            else:
                time_spec = [0, 0, loop_fallback]

            x_val = self._parse_float(sec_data.get("x", "0")) if "x" in sec_data else None
            y_val = self._parse_float(sec_data.get("y", "0")) if "y" in sec_data else None

            ctrl_dict = {
                "name": sec_name,
                "type": ctrl_type,
                "ctrl_id": ctrl_id,
                "time": time_spec,
            }
            if x_val is not None:
                ctrl_dict["x"] = x_val
            if y_val is not None:
                ctrl_dict["y"] = y_val
            if "value" in sec_data:
                ctrl_dict["value"] = self._parse_int(sec_data["value"])
            self.bgctrls.append(ctrl_dict)
        elif sec_lower.startswith("bg ") or sec_lower == "bg" or sec_lower.startswith("bg_"):
            layer = self._parse_bg_section(sec_name, sec_data, bg_counter)
            self.layers.append(layer)

    def _parse_bg_section(self, sec_name: str, data: Dict[str, str], bg_counter: int) -> Dict[str, Any]:
        layer_type = data.get("type", "normal").lower()
        spriteno = self._parse_int_list(data.get("spriteno", "0, 0"))
        if len(spriteno) < 2:
            spriteno = [0, 0]

        start = self._parse_float_list(data.get("start", "0, 0"))
        if len(start) < 2:
            start = [0.0, 0.0]

        delta = self._parse_float_list(data.get("delta", "1, 1"))
        if len(delta) < 2:
            delta = [1.0, 1.0]

        tile = self._parse_int_list(data.get("tile", "0, 0"))
        if len(tile) < 2:
            tile = [0, 0]

        tilespacing = self._parse_int_list(data.get("tilespacing", "0, 0"))
        if len(tilespacing) < 2:
            tilespacing = [0, 0]

        window = self._parse_int_list(data.get("window", ""))
        windowdelta = self._parse_float_list(data.get("windowdelta", "0, 0"))
        velocity = self._parse_float_list(data.get("velocity", "0, 0"))
        if len(velocity) < 2:
            velocity = [0.0, 0.0]

        alpha = self._parse_int_list(data.get("alpha", "256, 0"))
        if len(alpha) < 2:
            alpha = [256, 0]

        scalestart = self._parse_float_list(data.get("scalestart", "1, 1"))
        if len(scalestart) < 2:
            scalestart = [1.0, 1.0]

        raw_id = data.get("id", data.get("ctrlid", ""))

        layer_dict: Dict[str, Any] = {
            "id": f"bg_{bg_counter}",
            "name": sec_name,
            "type": layer_type,
            "spriteno": spriteno,
            "layerno": self._parse_int(data.get("layerno", "0")),
            "start": start,
            "delta": delta,
            "scalestart": scalestart,
            "trans": data.get("trans", "none").lower(),
            "alpha": alpha,
            "mask": self._parse_int(data.get("mask", "0")),
            "tile": tile,
            "tilespacing": tilespacing,
            "velocity": velocity,
        }

        if raw_id:
            layer_dict["ctrl_id"] = self._parse_int(raw_id)

        if window and len(window) >= 4:
            layer_dict["window"] = window
            layer_dict["windowdelta"] = windowdelta if len(windowdelta) >= 2 else [0.0, 0.0]

        if "sin.x" in data:
            layer_dict["sin_x"] = self._parse_float_list(data["sin.x"])
        if "sin.y" in data:
            layer_dict["sin_y"] = self._parse_float_list(data["sin.y"])

        if layer_type == "parallax":
            xscale = self._parse_float_list(data.get("xscale", "1, 1"))
            if len(xscale) >= 2:
                layer_dict["xscale"] = xscale
            width = self._parse_int_list(data.get("width", ""))
            if len(width) >= 2:
                layer_dict["width"] = width
            layer_dict["yscalestart"] = self._parse_float(data.get("yscalestart", "100.0"))
            layer_dict["yscaledelta"] = self._parse_float(data.get("yscaledelta", "0.0"))
            if "zoomdelta" in data:
                layer_dict["zoomdelta"] = self._parse_float_list(data["zoomdelta"])

        if layer_type == "anim":
            layer_dict["actionno"] = self._parse_int(data.get("actionno", "0"))

        return layer_dict

    def _parse_action_line(self, line: str) -> Optional[Dict[str, Any]]:
        clean = re.split(r"[;#]", line, maxsplit=1)[0].strip()
        if not clean:
            return None
        parts = [p.strip() for p in clean.split(",")]
        if len(parts) < 5:
            return None
        try:
            return {
                "group": int(parts[0]),
                "number": int(parts[1]),
                "axis_x": int(parts[2]),
                "axis_y": int(parts[3]),
                "ticks": int(parts[4]),
                "flip": parts[5].upper() if len(parts) > 5 and parts[5] else "",
                "trans": parts[6].lower() if len(parts) > 6 and parts[6] else "none",
            }
        except ValueError:
            return None

    @staticmethod
    def _parse_int(val: Any) -> int:
        try:
            return int(float(str(val).strip()))
        except (ValueError, TypeError):
            return 0

    @staticmethod
    def _parse_float(val: Any) -> float:
        try:
            return float(str(val).strip())
        except (ValueError, TypeError):
            return 0.0

    @classmethod
    def _parse_int_list(cls, val: str) -> List[int]:
        if not val:
            return []
        parts = [p.strip() for p in val.split(",") if p.strip()]
        res = []
        for p in parts:
            try:
                res.append(int(float(p)))
            except ValueError:
                pass
        return res

    @classmethod
    def _parse_float_list(cls, val: str) -> List[float]:
        if not val:
            return []
        parts = [p.strip() for p in val.split(",") if p.strip()]
        res = []
        for p in parts:
            try:
                res.append(float(p))
            except ValueError:
                pass
        return res


class StageExporter:
    """Eksporter yang mengekstrak aset SFF dan menulis format JSON 1:1 STARBLAST."""

    def __init__(
        self,
        def_path: Path,
        out_dir: Path,
        target_res: Tuple[int, int] = (1280, 720),
        scale: Optional[float] = None,
        rescale: bool = False,
        rescale_images: bool = False,
        all_sprites: bool = False,
    ):
        self.def_path = def_path
        self.out_dir = out_dir
        self.target_res = target_res
        self.scale = scale
        self.rescale = rescale
        self.rescale_images = rescale_images
        self.all_sprites = all_sprites
        self.parser = StageDefParser(def_path)

    def run(self) -> Dict[str, Any]:
        print(f"[*] Parsing file def: {self.def_path}")
        self.parser.parse()

        localcoord = self.parser.stageinfo.get("localcoord", [1280, 720])
        src_w, src_h = localcoord[0], localcoord[1]

        # Mode default: 100% Pure 1:1 metadata tanpa modifikasi
        if self.rescale:
            if self.scale is not None:
                scale_x = self.scale
                scale_y = self.scale
            else:
                scale_x = self.target_res[0] / src_w if src_w > 0 else 1.0
                scale_y = self.target_res[1] / src_h if src_h > 0 else 1.0
            is_scaled = abs(scale_x - 1.0) > 0.001 or abs(scale_y - 1.0) > 0.001
        else:
            scale_x = 1.0
            scale_y = 1.0
            is_scaled = False

        print(f"[*] Localcoord: {src_w}x{src_h} | Target: {self.target_res[0]}x{self.target_res[1]}")
        print(f"[*] Scale Factor: X={scale_x:.4f}, Y={scale_y:.4f} (Pure 1:1: {not is_scaled})")

        self.out_dir.mkdir(parents=True, exist_ok=True)

        # Cari file SFF
        sff_filename = self.parser.bgdef.get("spr", "")
        if not sff_filename:
            sff_filename = f"{self.def_path.stem}.sff"
        sff_path = self.def_path.parent / sff_filename
        if not sff_path.is_file():
            # Coba cari file .sff apa saja di direktori yang sama
            sff_files = list(self.def_path.parent.glob("*.sff"))
            if sff_files:
                sff_path = sff_files[0]
            else:
                raise FileNotFoundError(f"File SFF tidak ditemukan: {sff_path}")

        print(f"[*] Membaca SFF: {sff_path}")
        reader = SffReader(str(sff_path))
        with open(sff_path, "rb") as f:
            reader.read_header(f)
            reader.read_palette_table(f)
            reader.read_sprite_table(f)

            sprite_map: Dict[Tuple[int, int], SpriteEntry] = {}
            for spr in reader.sprites:
                sprite_map[(spr.group, spr.number)] = spr

            # Kumpulkan sprite yang perlu diekstrak
            needed_sprites: set = set()
            if self.all_sprites:
                needed_sprites = set(sprite_map.keys())
            else:
                for layer in self.parser.layers:
                    sp_tuple = (layer["spriteno"][0], layer["spriteno"][1])
                    needed_sprites.add(sp_tuple)
                for act_frames in self.parser.actions.values():
                    for frame in act_frames:
                        needed_sprites.add((frame["group"], frame["number"]))

            print(f"[*] Mengekstrak {len(needed_sprites)} sprite dari {len(reader.sprites)} total sprite...")
            extracted_metadata: Dict[Tuple[int, int], Dict[str, Any]] = {}
            image_cache: Dict[int, Image.Image] = {}

            for spr in reader.sprites:
                sp_key = (spr.group, spr.number)
                if sp_key not in needed_sprites:
                    continue

                img: Optional[Image.Image] = None
                if spr.is_linked:
                    if spr.link in image_cache:
                        img = image_cache[spr.link]
                else:
                    img = reader.get_sprite_image(spr, f)

                if img:
                    image_cache[spr.index] = img

                    img_to_save = img
                    axis_x, axis_y = spr.axis_x, spr.axis_y
                    spr_w, spr_h = spr.width, spr.height

                    if is_scaled and self.rescale_images:
                        new_w = max(1, int(round(spr_w * scale_x)))
                        new_h = max(1, int(round(spr_h * scale_y)))
                        img_to_save = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
                        axis_x = int(round(axis_x * scale_x))
                        axis_y = int(round(axis_y * scale_y))
                        spr_w, spr_h = new_w, new_h

                    out_filename = f"{spr.group}_{spr.number}.png"
                    img_to_save.save(self.out_dir / out_filename, format="PNG", compress_level=1)

                    extracted_metadata[sp_key] = {
                        "filename": out_filename,
                        "width": spr_w,
                        "height": spr_h,
                        "axis_x": axis_x,
                        "axis_y": axis_y,
                    }

        # Proses seluruh frame aksi animasi terlebih dahulu
        processed_actions = {}
        for act_id, frames in self.parser.actions.items():
            act_list = []
            for fr in frames:
                f_copy = dict(fr)
                sp_key = (fr["group"], fr["number"])
                meta = extracted_metadata.get(sp_key, {})
                f_copy["img_ref"] = meta.get("filename", f"{fr['group']}_{fr['number']}.png")
                f_copy["width"] = meta.get("width", 0)
                f_copy["height"] = meta.get("height", 0)
                spr_axis_x = meta.get("axis_x", 0)
                spr_axis_y = meta.get("axis_y", 0)
                rel_x = fr.get("axis_x", 0)
                rel_y = fr.get("axis_y", 0)
                if is_scaled:
                    rel_x = int(round(rel_x * scale_x))
                    rel_y = int(round(rel_y * scale_y))
                f_copy["axis_x"] = spr_axis_x + rel_x
                f_copy["axis_y"] = spr_axis_y + rel_y
                act_list.append(f_copy)
            processed_actions[str(act_id)] = act_list

        # Perbarui koordinat layer dan mapping gambar
        processed_layers = []
        for layer in self.parser.layers:
            sp_key = (layer["spriteno"][0], layer["spriteno"][1])
            meta = extracted_metadata.get(sp_key, {})

            ly = dict(layer)
            if meta:
                ly["img_ref"] = meta.get("filename", f"{sp_key[0]}_{sp_key[1]}.png")
                ly["width"] = meta.get("width", 0)
                ly["height"] = meta.get("height", 0)
                ly["axis_x"] = meta.get("axis_x", 0)
                ly["axis_y"] = meta.get("axis_y", 0)
            elif ly.get("type") == "anim" and str(ly.get("actionno")) in processed_actions:
                first_frame = processed_actions[str(ly["actionno"])][0]
                ly["img_ref"] = first_frame["img_ref"]
                ly["width"] = first_frame["width"]
                ly["height"] = first_frame["height"]
                ly["axis_x"] = first_frame["axis_x"]
                ly["axis_y"] = first_frame["axis_y"]
            else:
                ly["img_ref"] = f"{sp_key[0]}_{sp_key[1]}.png"
                ly["width"] = 0
                ly["height"] = 0
                ly["axis_x"] = 0
                ly["axis_y"] = 0

            if is_scaled:
                ly["start"] = [ly["start"][0] * scale_x, ly["start"][1] * scale_y]
                ly["velocity"] = [ly["velocity"][0] * scale_x, ly["velocity"][1] * scale_y]
                ly["tilespacing"] = [int(round(ly["tilespacing"][0] * scale_x)), int(round(ly["tilespacing"][1] * scale_y))]
                if "window" in ly:
                    ly["window"] = [
                        int(round(ly["window"][0] * scale_x)),
                        int(round(ly["window"][1] * scale_y)),
                        int(round(ly["window"][2] * scale_x)),
                        int(round(ly["window"][3] * scale_y)),
                    ]
                if not self.rescale_images and (abs(scale_x - 1.0) > 0.001 or abs(scale_y - 1.0) > 0.001):
                    ly["scale"] = [scale_x, scale_y]

            processed_layers.append(ly)

        # Salin musik BGM jika ada
        bgm_file = self.parser.music.get("bgmusic", "")
        if bgm_file:
            clean_bgm_name = Path(bgm_file.replace("\\", "/")).name
            bgm_src = self.def_path.parent / bgm_file
            if not bgm_src.is_file():
                bgm_src = self.def_path.parent / clean_bgm_name
            if bgm_src.is_file():
                dest_bgm = self.out_dir / bgm_src.name
                shutil.copy2(bgm_src, dest_bgm)
                print(f"[+] Audio BGM disalin: {dest_bgm.name}")
                self.parser.music["bgmusic"] = dest_bgm.name

        # Skala data kamera, player, dan stage
        camera_data = dict(self.parser.camera)
        player_data = dict(self.parser.playerinfo)
        bound_data = dict(self.parser.bound)
        stage_data = dict(self.parser.stageinfo)
        shadow_data = dict(self.parser.shadow)

        if is_scaled:
            camera_data["boundleft"] *= scale_x
            camera_data["boundright"] *= scale_x
            camera_data["boundhigh"] *= scale_y
            camera_data["boundlow"] *= scale_y
            camera_data["floortension"] *= scale_y
            camera_data["tension"] *= scale_x
            camera_data["overdrawhigh"] *= scale_y
            camera_data["overdrawlow"] *= scale_y

            player_data["p1startx"] *= scale_x
            player_data["p1starty"] *= scale_y
            player_data["p2startx"] *= scale_x
            player_data["p2starty"] *= scale_y
            player_data["p3startx"] *= scale_x
            player_data["p3starty"] *= scale_y
            player_data["p4startx"] *= scale_x
            player_data["p4starty"] *= scale_y
            player_data["leftbound"] *= scale_x
            player_data["rightbound"] *= scale_x

            bound_data["screenleft"] *= scale_x
            bound_data["screenright"] *= scale_x

            stage_data["zoffset"] *= scale_y
            stage_data["localcoord"] = [self.target_res[0], self.target_res[1]]

        stage_json_data = {
            "format": "starblast_stage_v1",
            "info": self.parser.info,
            "camera": camera_data,
            "playerinfo": player_data,
            "bound": bound_data,
            "stageinfo": stage_data,
            "shadow": shadow_data,
            "reflection": self.parser.reflection,
            "music": self.parser.music,
            "controllers": self.parser.bgctrls,
            "layers": processed_layers,
            "actions": processed_actions,
        }

        # Buat preview 300x720 untuk select stage portrait
        preview_path = self.out_dir / "preview.jpg"
        if not preview_path.is_file():
            preview_src = None
            for cand_layer in processed_layers:
                cand_file = self.out_dir / cand_layer.get("img_ref", "")
                if cand_file.is_file():
                    preview_src = cand_file
                    break
            if preview_src:
                try:
                    p_img = Image.open(preview_src)
                    cw = int(300 * p_img.height / 720)
                    if cw > p_img.width:
                        cw = p_img.width
                    cx = (p_img.width - cw) // 2
                    p_crop = p_img.crop((cx, 0, cx + cw, p_img.height))
                    p_thumb = p_crop.resize((300, 720), Image.Resampling.LANCZOS)
                    p_thumb.convert("RGB").save(preview_path, quality=90)
                    print(f"[+] Preview portrait 300x720 dibuat: {preview_path.name}")
                except Exception as e:
                    pass

        json_path = self.out_dir / "stage.json"
        with open(json_path, "w", encoding="utf-8") as jf:
            json.dump(stage_json_data, jf, indent=2)

        print(f"[+] File stage.json berhasil disimpan di: {json_path}")
        print(f"[+] Total layer: {len(processed_layers)} | Total sprite diekstrak: {len(extracted_metadata)}")
        return stage_json_data


def main():
    parser = argparse.ArgumentParser(description="Tool CLI Porting Stage Mugen ke Format 1:1 STARBLAST.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Subcommand: port
    p_port = subparsers.add_parser("port", help="Port stage .def & .sff ke folder stage.json")
    p_port.add_argument("def_file", help="Jalur ke file stage .def")
    p_port.add_argument("-o", "--out", help="Direktori tujuan output (default: assets/stages/<id>/)")
    p_port.add_argument("--id", help="ID panggung (default: nama file def)")
    p_port.add_argument("--scale", type=float, help="Faktor skala manual (default: auto dari localcoord)")
    p_port.add_argument("--rescale", action="store_true", help="Skalakan angka metadata koordinat ke target_res (default: False, pure 1:1)")
    p_port.add_argument("--rescale-images", action="store_true", help="Resample gambar PNG menggunakan Lanczos")
    p_port.add_argument("--all-sprites", action="store_true", help="Ekstrak seluruh sprite dalam file SFF")

    # Subcommand: info
    p_info = subparsers.add_parser("info", help="Tampilkan detail konfigurasi stage .def")
    p_info.add_argument("def_file", help="Jalur ke file stage .def")

    args = parser.parse_args()

    if args.command == "info":
        def_path = Path(args.def_file)
        stg_parser = StageDefParser(def_path)
        stg_parser.parse()
        print("=" * 60)
        print(f"STAGE INFO: {stg_parser.info.get('displayname', def_path.stem)}")
        print(f"Author: {stg_parser.info.get('author', 'Unknown')}")
        print(f"LocalCoord: {stg_parser.stageinfo.get('localcoord')}")
        print(f"Ground Z-Offset: {stg_parser.stageinfo.get('zoffset')}")
        print(f"Camera Bounds: L={stg_parser.camera.get('boundleft')} R={stg_parser.camera.get('boundright')} H={stg_parser.camera.get('boundhigh')} Low={stg_parser.camera.get('boundlow')}")
        print(f"P1 Start: X={stg_parser.playerinfo.get('p1startx')} Y={stg_parser.playerinfo.get('p1starty')}")
        print(f"P2 Start: X={stg_parser.playerinfo.get('p2startx')} Y={stg_parser.playerinfo.get('p2starty')}")
        print(f"Total Background Layers: {len(stg_parser.layers)}")
        for idx, ly in enumerate(stg_parser.layers):
            print(f"  [{idx}] {ly.get('name')}: Type={ly.get('type')}, Sprite={ly.get('spriteno')}, Delta={ly.get('delta')}, Start={ly.get('start')}")
        print("=" * 60)

    elif args.command == "port":
        def_path = Path(args.def_file)
        stage_id = args.id if args.id else def_path.stem.lower().replace("-", "_")

        if args.out:
            out_dir = Path(args.out)
        else:
            out_dir = Path("assets/stages") / stage_id

        exporter = StageExporter(
            def_path=def_path,
            out_dir=out_dir,
            target_res=(1280, 720),
            scale=args.scale,
            rescale=args.rescale,
            rescale_images=args.rescale_images,
            all_sprites=args.all_sprites,
        )
        exporter.run()


if __name__ == "__main__":
    main()
