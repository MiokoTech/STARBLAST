#!/usr/bin/env python3
import json
import os
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from PIL import Image


class MugenDefParser:
    def __init__(self, def_path: str, sprites_dir: Optional[str] = None):
        self.def_path = Path(def_path)
        self.sprites_dir = Path(sprites_dir) if sprites_dir else self.def_path.parent / "system_sprites"
        self.sections: Dict[str, Dict[str, Any]] = {}
        self.bg_defs: Dict[str, List[Dict[str, Any]]] = {}
        self.actions: Dict[int, List[Dict[str, Any]]] = {}
        self.raw_sections: List[Tuple[str, Dict[str, str]]] = []

    def parse(self) -> None:
        if not self.def_path.is_file():
            raise FileNotFoundError(f"File def '{self.def_path}' tidak ditemukan.")

        with open(self.def_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()

        current_sec_name = ""
        current_action_no: Optional[int] = None
        current_sec_data: Dict[str, str] = {}

        for line_idx, raw_line in enumerate(lines):
            line = raw_line.strip()
            if not line or line.startswith(";") or line.startswith("#"):
                continue

            # Deteksi awal section
            sec_match = re.match(r"^\[(.*?)\]", line)
            if sec_match:
                self._commit_section(current_sec_name, current_action_no, current_sec_data)
                header_content = sec_match.group(1).strip()
                current_sec_data = {}

                # Deteksi blok animasi
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

            # Parse frame animasi
            if current_action_no is not None:
                frame_data = self._parse_action_line(line)
                if frame_data:
                    self.actions[current_action_no].append(frame_data)
                continue

            # Parse key = value
            if "=" in line:
                clean_line = re.split(r"[;#]", line, maxsplit=1)[0].strip()
                if "=" in clean_line:
                    k, v = clean_line.split("=", 1)
                    k = k.strip().lower()
                    v = v.strip().strip('"')
                    current_sec_data[k] = v

        self._commit_section(current_sec_name, current_action_no, current_sec_data)

    def _commit_section(self, sec_name: str, action_no: Optional[int], sec_data: Dict[str, str]) -> None:
        """Menyimpan data section ke dalam dictionary terstruktur."""
        if not sec_name or action_no is not None:
            return

        sec_lower = sec_name.lower()

        # Deteksi layer background berulang: TitleBG, SelectBG, VersusBG, dll.
        bg_match = re.match(r"^([a-z]+bg)\s*(?:\d+)?$", sec_lower)
        if bg_match and not sec_lower.endswith("def") and not sec_lower.endswith("ctrl"):
            bg_key = bg_match.group(1)
            if bg_key not in self.bg_defs:
                self.bg_defs[bg_key] = []
            parsed_layer = self._parse_bg_layer(sec_data)
            self.bg_defs[bg_key].append(parsed_layer)
        else:
            if sec_lower not in self.sections:
                self.sections[sec_lower] = {}
            self.sections[sec_lower].update(sec_data)

        self.raw_sections.append((sec_name, sec_data))

    def _parse_bg_layer(self, data: Dict[str, str]) -> Dict[str, Any]:
        layer: Dict[str, Any] = {
            "type": data.get("type", "normal").lower(),
            "layerno": int(data.get("layerno", "0")),
            "mask": int(data.get("mask", "0")),
            "trans": data.get("trans", "none").lower(),
            "raw": data,
        }

        # Sprite: spr = group, number
        if "spr" in data:
            parts = [int(x.strip()) for x in data["spr"].split(",") if x.strip().lstrip("-").isdigit()]
            if len(parts) >= 2:
                layer["group"] = parts[0]
                layer["number"] = parts[1]

        # Action: actionno = X
        if "actionno" in data:
            try:
                layer["actionno"] = int(data["actionno"])
            except ValueError:
                pass

        # Posisi mulai: start = x, y
        if "start" in data:
            parts = [float(x.strip()) for x in data["start"].split(",") if x.strip()]
            if len(parts) >= 2:
                layer["start_x"] = parts[0]
                layer["start_y"] = parts[1]
            elif len(parts) == 1:
                layer["start_x"] = parts[0]
                layer["start_y"] = 0.0
        else:
            layer["start_x"] = 0.0
            layer["start_y"] = 0.0

        # Skala: scalestart = sx, sy
        if "scalestart" in data:
            parts = [float(x.strip()) for x in data["scalestart"].split(",") if x.strip()]
            if len(parts) >= 2:
                layer["scale_x"] = parts[0]
                layer["scale_y"] = parts[1]
            elif len(parts) == 1:
                layer["scale_x"] = parts[0]
                layer["scale_y"] = parts[0]
        else:
            layer["scale_x"] = 1.0
            layer["scale_y"] = 1.0

        # Window crop: window = x1, y1, x2, y2
        if "window" in data:
            parts = [int(x.strip()) for x in data["window"].split(",") if x.strip().lstrip("-").isdigit()]
            if len(parts) >= 4:
                layer["window"] = parts

        return layer

    def _parse_action_line(self, line: str) -> Optional[Dict[str, Any]]:
        """Parse satu baris keyframe animasi pada [Begin Action X]."""
        clean_line = re.split(r"[;#]", line, maxsplit=1)[0].strip()
        if not clean_line:
            return None

        # Abaikan instruksi kontrol khusus
        if clean_line.lower().startswith("interpolate") or clean_line.lower().startswith("loopstart"):
            return None

        parts = [p.strip() for p in clean_line.split(",")]
        if len(parts) < 5:
            return None

        try:
            group = int(parts[0])
            number = int(parts[1])
            x_ofs = int(parts[2])
            y_ofs = int(parts[3])
            duration = int(parts[4])
        except ValueError:
            return None

        flip = parts[5].upper() if len(parts) > 5 and parts[5] else "NONE"
        blend = parts[6].upper() if len(parts) > 6 and parts[6] else "NONE"

        scale_x = 1.0
        scale_y = 1.0
        if len(parts) > 8 and parts[7] and parts[8]:
            try:
                scale_x = float(parts[7])
                scale_y = float(parts[8])
            except ValueError:
                pass

        sprite_file = f"{group}_{number}.png"
        sprite_exists = (self.sprites_dir / sprite_file).is_file() if self.sprites_dir else False

        return {
            "group": group,
            "number": number,
            "x_offset": x_ofs,
            "y_offset": y_ofs,
            "duration": duration,
            "flip": flip,
            "blend": blend,
            "scale_x": scale_x,
            "scale_y": scale_y,
            "sprite_file": sprite_file,
            "sprite_exists": sprite_exists,
        }

    def get_sprite_path(self, group: int, number: int) -> Optional[Path]:
        filename = f"{group}_{number}.png"
        p = self.sprites_dir / filename
        if p.is_file():
            return p
        return None

    def export_summary_json(self, out_path: str) -> None:
        out_file = Path(out_path)
        out_file.parent.mkdir(parents=True, exist_ok=True)

        data = {
            "source_def": str(self.def_path),
            "sprites_dir": str(self.sprites_dir),
            "sections": self.sections,
            "bg_layers": self.bg_defs,
            "actions": self.actions,
        }
        with open(out_file, "w", encoding="utf-8") as jf:
            json.dump(data, jf, indent=2)
        print(f"[+] Data UI berhasil diekspor ke: {out_file}")

    def compose_background(
        self,
        bg_name: str = "titlebg",
        canvas_w: int = 1280,
        canvas_h: int = 720,
        out_image: Optional[str] = None
    ) -> Optional[Image.Image]:
        bg_key = bg_name.lower()
        if not bg_key.endswith("bg"):
            bg_key += "bg"

        layers = self.bg_defs.get(bg_key, [])
        if not layers:
            print(f"[!] Peringatan: Tidak ada layer background untuk '{bg_key}'")
            return None

        # Urutkan layer berdasarkan layerno
        layers = sorted(layers, key=lambda l: l.get("layerno", 0))

        # Buat canvas RGBA transparan 1280x720
        canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 255))

        rendered_count = 0
        for idx, layer in enumerate(layers):
            layer_type = layer.get("type", "normal")
            spr_path: Optional[Path] = None
            scale_x = layer.get("scale_x", 1.0)
            scale_y = layer.get("scale_y", 1.0)
            start_x = int(layer.get("start_x", 0))
            start_y = int(layer.get("start_y", 0))

            if layer_type == "normal":
                g = layer.get("group")
                n = layer.get("number")
                if g is not None and n is not None:
                    spr_path = self.get_sprite_path(g, n)
            elif layer_type == "anim":
                act_no = layer.get("actionno")
                if act_no in self.actions and self.actions[act_no]:
                    first_frame = self.actions[act_no][0]
                    spr_path = self.get_sprite_path(first_frame["group"], first_frame["number"])
                    start_x += first_frame.get("x_offset", 0)
                    start_y += first_frame.get("y_offset", 0)
                    scale_x *= first_frame.get("scale_x", 1.0)
                    scale_y *= first_frame.get("scale_y", 1.0)

            if not spr_path or not spr_path.is_file():
                continue

            try:
                img = Image.open(spr_path).convert("RGBA")
            except Exception as e:
                print(f"[!] Gagal membaca sprite {spr_path}: {e}")
                continue

            # Terapkan penskalaan
            if scale_x != 1.0 or scale_y != 1.0:
                new_w = max(1, int(round(img.width * scale_x)))
                new_h = max(1, int(round(img.height * scale_y)))
                if new_w > 4000 or new_h > 4000:
                    new_w = min(new_w, canvas_w)
                    new_h = min(new_h, canvas_h)
                img = img.resize((new_w, new_h), Image.Resampling.BILINEAR)

            # Alpha composite ke atas canvas
            canvas.alpha_composite(img, (start_x, start_y))
            rendered_count += 1

        print(f"[+] Berhasil mengomposisi {rendered_count} layer untuk background '{bg_key}'")

        if out_image:
            out_p = Path(out_image)
            out_p.parent.mkdir(parents=True, exist_ok=True)
            canvas.save(out_p, format="PNG")
            print(f"[OK] Gambar background tersimpan di: {out_p}")

        return canvas

    def export_action_frames(self, action_no: int, out_dir: str) -> List[Dict[str, Any]]:
        if action_no not in self.actions:
            print(f"[!] Action {action_no} tidak ditemukan.")
            return []

        out_path = Path(out_dir)
        out_path.mkdir(parents=True, exist_ok=True)

        frames = self.actions[action_no]
        exported = []

        for idx, f in enumerate(frames):
            spr_path = self.get_sprite_path(f["group"], f["number"])
            if not spr_path:
                continue

            dest_filename = f"frame_{idx:03d}_{f['group']}_{f['number']}.png"
            dest_file = out_path / dest_filename

            img = Image.open(spr_path).convert("RGBA")
            if f.get("flip") == "H":
                img = img.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            elif f.get("flip") == "V":
                img = img.transpose(Image.Transpose.FLIP_TOP_BOTTOM)

            if f.get("scale_x", 1.0) != 1.0 or f.get("scale_y", 1.0) != 1.0:
                nw = max(1, int(round(img.width * f["scale_x"])))
                nh = max(1, int(round(img.height * f["scale_y"])))
                img = img.resize((nw, nh), Image.Resampling.BILINEAR)

            img.save(dest_file, format="PNG")
            exported.append({
                "frame_index": idx,
                "file": dest_filename,
                "duration": f["duration"],
                "x_offset": f["x_offset"],
                "y_offset": f["y_offset"],
                "blend": f["blend"],
            })

        desc_file = out_path / f"action_{action_no}.json"
        with open(desc_file, "w", encoding="utf-8") as df:
            json.dump({
                "action_no": action_no,
                "total_frames": len(exported),
                "frames": exported
            }, df, indent=2)

        print(f"[OK] {len(exported)} frame dari Action {action_no} diekspor ke {out_path}")
        return exported

    def generate_as3_layout_constants(self) -> str:
        """Ekstrak konstanta layout Select & Title screen untuk diimplementasikan di ActionScript 3."""
        sel = self.sections.get("select info", {})
        title = self.sections.get("title info", {})

        as3_code = []
        as3_code.append("// ==========================================================")
        as3_code.append("// Nilai Layout diekstrak dari Mugen system.def untuk STARBLAST")
        as3_code.append("// ==========================================================")
        as3_code.append("")
        as3_code.append("public static const MUGEN_CANVAS_WIDTH:int = 1280;")
        as3_code.append("public static const MUGEN_CANVAS_HEIGHT:int = 720;")
        as3_code.append("")

        if sel:
            as3_code.append("// --- Select Screen Grid ---")
            if "rows" in sel:
                as3_code.append(f"public static const SELECT_GRID_ROWS:int = {sel['rows']};")
            if "columns" in sel:
                as3_code.append(f"public static const SELECT_GRID_COLS:int = {sel['columns']};")
            if "pos" in sel:
                parts = sel["pos"].split(",")
                as3_code.append(f"public static const SELECT_GRID_X:Number = {parts[0].strip()};")
                if len(parts) > 1:
                    as3_code.append(f"public static const SELECT_GRID_Y:Number = {parts[1].strip()};")
            if "cell.size" in sel:
                parts = sel["cell.size"].split(",")
                as3_code.append(f"public static const SELECT_CELL_WIDTH:Number = {parts[0].strip()};")
                if len(parts) > 1:
                    as3_code.append(f"public static const SELECT_CELL_HEIGHT:Number = {parts[1].strip()};")
            if "cell.spacing" in sel:
                as3_code.append(f"public static const SELECT_CELL_SPACING:Number = {sel['cell.spacing']};")
            if "p1.face.offset" in sel:
                parts = sel["p1.face.offset"].split(",")
                as3_code.append(f"public static const P1_FACE_OFFSET_X:Number = {parts[0].strip()};")
                if len(parts) > 1:
                    as3_code.append(f"public static const P1_FACE_OFFSET_Y:Number = {parts[1].strip()};")
            if "p2.face.offset" in sel:
                parts = sel["p2.face.offset"].split(",")
                as3_code.append(f"public static const P2_FACE_OFFSET_X:Number = {parts[0].strip()};")
                if len(parts) > 1:
                    as3_code.append(f"public static const P2_FACE_OFFSET_Y:Number = {parts[1].strip()};")

        if title:
            as3_code.append("")
            as3_code.append("// --- Title Menu ---")
            if "menu.pos" in title:
                parts = title["menu.pos"].split(",")
                as3_code.append(f"public static const MENU_POS_X:Number = {parts[0].strip()};")
                if len(parts) > 1:
                    as3_code.append(f"public static const MENU_POS_Y:Number = {parts[1].strip()};")

        return "\n".join(as3_code)
