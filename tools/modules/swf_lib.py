#!/usr/bin/env python3
import os
import sys
import copy
import shutil
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Union
from PIL import Image

DEFAULT_FFDEC_JAR = Path("/data/data/com.termux/files/home/ffdec/ffdec.jar")
if not DEFAULT_FFDEC_JAR.exists():
    home = Path(os.environ.get("HOME", "/data/data/com.termux/files/home"))
    DEFAULT_FFDEC_JAR = home / "ffdec" / "ffdec.jar"


def get_ffdec_jar() -> Path:
    if DEFAULT_FFDEC_JAR.exists():
        return DEFAULT_FFDEC_JAR
    env_jar = os.environ.get("FFDEC_JAR")
    if env_jar and Path(env_jar).exists():
        return Path(env_jar)
    raise FileNotFoundError(f"ffdec.jar tidak ditemukan di {DEFAULT_FFDEC_JAR} atau melalui env var FFDEC_JAR")


class SwfCompiler:
    """Wrapper CLI FFDec untuk konversi dan inspeksi SWF/XML."""

    @staticmethod
    def run_cmd(args: List[str], check: bool = True) -> subprocess.CompletedProcess:
        jar = get_ffdec_jar()
        cmd = ["java", "-Xmx512m", "-jar", str(jar)] + args
        res = subprocess.run(cmd, capture_output=True, text=True)
        if check and res.returncode != 0:
            err = res.stderr.strip() or res.stdout.strip()
            raise RuntimeError(f"Perintah FFDec gagal (kode {res.returncode}): {' '.join(cmd)}\n{err}")
        return res

    @classmethod
    def export_xml(
        cls,
        swf_path: Union[str, Path],
        out_xml_path: Optional[Union[str, Path]] = None,
        external: bool = True,
        force: bool = False,
    ) -> Path:
        """Ekspor SWF ke XML dan ekstrak aset eksternal."""
        swf = Path(swf_path).resolve()
        if not swf.exists():
            raise FileNotFoundError(f"SWF tidak ditemukan: {swf}")

        if out_xml_path is None:
            out_xml = swf.parent / f"{swf.stem}.xml"
        else:
            out_xml = Path(out_xml_path).resolve()

        out_xml.parent.mkdir(parents=True, exist_ok=True)

        if not force and out_xml.exists():
            if out_xml.stat().st_mtime >= swf.stat().st_mtime:
                print(f"[INFO] Menggunakan XML cache: {out_xml.name} (gunakan force=True untuk ekspor ulang)")
                return out_xml

        print(f"[*] Mengekspor SWF -> XML: {swf.name} -> {out_xml.name}...")
        args = ["-swf2xml"]
        if external:
            args.extend(["-external", "all"])
        args.extend([str(swf), str(out_xml)])
        cls.run_cmd(args)
        print(f"[OK] Berhasil diekspor: {out_xml}")
        return out_xml

    @classmethod
    def build_swf(
        cls,
        xml_path: Union[str, Path],
        out_swf_path: Optional[Union[str, Path]] = None,
    ) -> Path:
        """Kompilasi XML kembali menjadi file SWF."""
        xml_file = Path(xml_path).resolve()
        if not xml_file.exists():
            raise FileNotFoundError(f"XML tidak ditemukan: {xml_file}")

        if out_swf_path is None:
            out_swf = xml_file.parent / f"{xml_file.stem}.swf"
        else:
            out_swf = Path(out_swf_path).resolve()

        out_swf.parent.mkdir(parents=True, exist_ok=True)
        print(f"[*] Kompilasi XML -> SWF: {xml_file.name} -> {out_swf.name}...")
        args = ["-xml2swf", str(xml_file), str(out_swf)]
        cls.run_cmd(args)
        size_kb = out_swf.stat().st_size / 1024
        print(f"[OK] Selesai membangun {out_swf.name} ({size_kb:.1f} KB)")
        return out_swf

    @classmethod
    def dump_as3(cls, swf_path: Union[str, Path]) -> List[str]:
        """Ekstrak daftar nama kelas AS3 yang terdaftar pada file SWF."""
        swf = Path(swf_path).resolve()
        if not swf.exists():
            raise FileNotFoundError(f"SWF tidak ditemukan: {swf}")
        res = cls.run_cmd(["-dumpAS3", str(swf)], check=False)
        classes = []
        for line in res.stdout.strip().splitlines():
            line = line.strip()
            if line and not line.startswith("Failed to load") and not line.startswith("JPEXS"):
                classes.append(line)
        return classes


SOUND_CLASS_TEMPLATE = """
<item type="DoABC2Tag" flags="1" forceWriteAsLong="true" name="snd_menu1">
  <abc type="ABC">
    <version type="ABCVersion" major="46" minor="16" />
    <constants type="AVM2ConstantPool">
      <constant_int />
      <constant_uint />
      <constant_double />
      <constant_decimal />
      <constant_float />
      <constant_float4 />
      <constant_string>
        <item isNull="true" />
        <item>snd_menu1</item>
        <item />
        <item>flash.media</item>
        <item>Sound</item>
        <item>Object</item>
        <item>EventDispatcher</item>
        <item>flash.events</item>
        <item>__go_to_definition_help</item>
        <item>file</item>
        <item>E:\\\\fb_workspace\\\\play\\\\死神VS火影_绊_assets\\\\fla\\\\</item>
        <item>pos</item>
        <item>0</item>
      </constant_string>
      <constant_namespace>
        <item isNull="true" />
        <item type="Namespace" kind="5" name_index="1" />
        <item type="Namespace" kind="22" name_index="2" />
        <item type="Namespace" kind="22" name_index="3" />
        <item type="Namespace" kind="24" name_index="1" />
        <item type="Namespace" kind="22" name_index="7" />
      </constant_namespace>
      <constant_namespace_set />
      <constant_multiname>
        <item isNull="true" />
        <item type="Multiname" kind="7" name_index="1" namespace_index="2" namespace_set_index="0" qname_index="0" />
        <item type="Multiname" kind="7" name_index="4" namespace_index="3" namespace_set_index="0" qname_index="0" />
        <item type="Multiname" kind="7" name_index="5" namespace_index="2" namespace_set_index="0" qname_index="0" />
        <item type="Multiname" kind="7" name_index="6" namespace_index="5" namespace_set_index="0" qname_index="0" />
      </constant_multiname>
    </constants>
    <method_info>
      <item type="MethodInfo" flags="0" name_index="2" ret_type="0">
        <param_types />
        <optional />
        <paramNames />
      </item>
      <item type="MethodInfo" flags="0" name_index="2" ret_type="0">
        <param_types />
        <optional />
        <paramNames />
      </item>
      <item type="MethodInfo" flags="0" name_index="2" ret_type="0">
        <param_types />
        <optional />
        <paramNames />
      </item>
    </method_info>
    <metadata_info>
      <item type="MetadataInfo" name_index="8">
        <keys>
          <item>9</item>
          <item>11</item>
        </keys>
        <values>
          <item>10</item>
          <item>12</item>
        </values>
      </item>
    </metadata_info>
    <instance_info>
      <item type="InstanceInfo" flags="8" iinit_index="1" name_index="1" protectedNS="4" super_index="2">
        <interfaces />
        <instance_traits type="Traits">
          <traits />
        </instance_traits>
      </item>
    </instance_info>
    <class_info>
      <item type="ClassInfo" cinit_index="0">
        <static_traits type="Traits">
          <traits />
        </static_traits>
      </item>
    </class_info>
    <script_info>
      <item type="ScriptInfo" init_index="2">
        <traits type="Traits">
          <traits>
            <item type="TraitClass" bytes="014401000100" class_info="0" deleted="false" fileOffset="226189" kindFlags="4" kindType="4" name_index="1" slot_id="1">
              <metadata>
                <item>0</item>
              </metadata>
            </item>
          </traits>
        </traits>
      </item>
    </script_info>
    <bodies>
      <item type="MethodBody" codeBytes="d03047" init_scope_depth="5" max_regs="1" max_scope_depth="6" max_stack="1" method_info="0">
        <exceptions />
        <traits type="Traits">
          <traits />
        </traits>
      </item>
      <item type="MethodBody" codeBytes="d030d0490047" init_scope_depth="6" max_regs="1" max_scope_depth="7" max_stack="1" method_info="1">
        <exceptions />
        <traits type="Traits">
          <traits />
        </traits>
      </item>
      <item type="MethodBody" codeBytes="d03065005d036603305d046604305d026602305d02660258001d1d1d680147" init_scope_depth="1" max_regs="1" max_scope_depth="5" max_stack="2" method_info="2">
        <exceptions />
        <traits type="Traits">
          <traits />
        </traits>
      </item>
    </bodies>
  </abc>
</item>
"""


class SwfXml:
    """Manipulator struktur tag XML SWF hasil dekompilasi FFDec."""

    def __init__(self, xml_path: Union[str, Path]):
        self.xml_path = Path(xml_path).resolve()
        if not self.xml_path.exists():
            raise FileNotFoundError(f"XML tidak ditemukan: {self.xml_path}")
        self.tree = ET.parse(self.xml_path)
        self.root = self.tree.getroot()
        self.tags_container = self.root.find("tags")
        if self.tags_container is None:
            raise ValueError("SWF XML tidak valid: tag <tags> tidak ditemukan")
        self._index_tags()

    def _index_tags(self):
        self.used_ids = set()
        self.symbol_class_tag = None
        self.symbol_map: Dict[str, str] = {}  # id -> nama_kelas
        self.do_abc_tags: Dict[str, ET.Element] = {}

        for tag in self.tags_container:
            tp = tag.get("type", "")
            for attr in ("characterID", "shapeId", "spriteId", "soundId"):
                val = tag.get(attr)
                if val and val.isdigit():
                    self.used_ids.add(int(val))

            if tp == "SymbolClassTag":
                self.symbol_class_tag = tag
                tags_elem = tag.find("tags")
                names_elem = tag.find("names")
                if tags_elem is not None and names_elem is not None:
                    t_list = [t.text for t in tags_elem.findall("item") if t.text]
                    n_list = [n.text for n in names_elem.findall("item") if n.text]
                    for tid, name in zip(t_list, n_list):
                        self.symbol_map[tid] = name
                        if tid.isdigit():
                            self.used_ids.add(int(tid))

            elif tp == "DoABC2Tag":
                name = tag.get("name", "")
                if name:
                    self.do_abc_tags[name] = tag

    def remove_tag(self, tag_type: str, attr_name: str, attr_val: str) -> bool:
        """Hapus tag yang sesuai dengan tipe dan nilai atribut."""
        removed = False
        to_remove = []
        for tag in self.tags_container:
            if tag.get("type") == tag_type and tag.get(attr_name) == str(attr_val):
                to_remove.append(tag)
        for tag in to_remove:
            self.tags_container.remove(tag)
            removed = True
            if tag_type == "DoABC2Tag" and attr_name == "name" and attr_val in self.do_abc_tags:
                del self.do_abc_tags[attr_val]
        return removed

    def get_next_available_id(self, start_id: int = 100) -> int:
        """Dapatkan ID numerik berikutnya yang belum digunakan."""
        cur = start_id
        while cur in self.used_ids:
            cur += 1
        self.used_ids.add(cur)
        return cur

    def add_lossless_image(
        self,
        src_image_path: Union[str, Path],
        dest_assets_dir: Union[str, Path],
        char_id: Optional[int] = None,
        shape_id: Optional[int] = None,
        max_width: Optional[int] = None,
        max_height: Optional[int] = None,
    ) -> Dict[str, Union[int, str]]:
        """Sematkan gambar lossless (DefineBitsLossless2Tag + DefineShape2Tag)."""
        src_path = Path(src_image_path).resolve()
        if not src_path.exists():
            raise FileNotFoundError(f"File gambar tidak ditemukan: {src_path}")

        dest_dir = Path(dest_assets_dir).resolve()
        dest_dir.mkdir(parents=True, exist_ok=True)

        if char_id is None:
            char_id = self.get_next_available_id(100)
        else:
            self.used_ids.add(char_id)

        if shape_id is None:
            shape_id = self.get_next_available_id(char_id + 1)
        else:
            self.used_ids.add(shape_id)

        dest_png = dest_dir / f"{char_id}.png"

        with Image.open(src_path) as im:
            orig_w, orig_h = im.size
            if max_width and max_height and (orig_w > max_width or orig_h > max_height):
                ratio = min(max_width / orig_w, max_height / orig_h)
                new_w = round(orig_w * ratio)
                new_h = round(orig_h * ratio)
                resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
                resized.save(dest_png, "PNG", optimize=True)
                final_w, final_h = new_w, new_h
            else:
                im.save(dest_png, "PNG", optimize=True)
                final_w, final_h = orig_w, orig_h

        try:
            rel_path = dest_png.relative_to(self.xml_path.parent).as_posix()
        except ValueError:
            rel_path = dest_png.as_posix()

        cid_str = str(char_id)
        sid_str = str(shape_id)
        w_twips = str(final_w * 20)
        h_twips = str(final_h * 20)

        # DefineBitsLossless2Tag
        bmp_tag = ET.Element("item", {
            "type": "DefineBitsLossless2Tag",
            "_externalFile": rel_path,
            "characterID": cid_str
        })

        # DefineShape2Tag
        shape_tag = ET.Element("item", {
            "type": "DefineShape2Tag",
            "forceWriteAsLong": "false",
            "shapeId": sid_str
        })
        ET.SubElement(shape_tag, "shapeBounds", {
            "type": "RECT",
            "Xmax": w_twips,
            "Xmin": "0",
            "Ymax": h_twips,
            "Ymin": "0",
            "nbits": "16"
        })
        shapes = ET.SubElement(shape_tag, "shapes", {
            "type": "SHAPEWITHSTYLE",
            "numFillBits": "1",
            "numLineBits": "0"
        })
        fill_styles_array = ET.SubElement(shapes, "fillStyles", {"type": "FILLSTYLEARRAY"})
        fill_styles_list = ET.SubElement(fill_styles_array, "fillStyles")
        fill_item = ET.SubElement(fill_styles_list, "item", {
            "type": "FILLSTYLE",
            "bitmapId": cid_str,
            "fillStyleType": "64"
        })
        ET.SubElement(fill_item, "bitmapMatrix", {
            "type": "MATRIX",
            "hasRotate": "false",
            "hasScale": "true",
            "nRotateBits": "0",
            "nScaleBits": "22",
            "nTranslateBits": "0",
            "scaleX": "20.0",
            "scaleY": "20.0",
            "translateX": "0",
            "translateY": "0"
        })
        ET.SubElement(shapes, "lineStyles", {"type": "LINESTYLEARRAY"})
        shape_records = ET.SubElement(shapes, "shapeRecords")
        ET.SubElement(shape_records, "item", {
            "type": "StyleChangeRecord",
            "fillStyle0": "1",
            "moveBits": "0",
            "moveDeltaX": "0",
            "moveDeltaY": "0",
            "stateFillStyle0": "true",
            "stateFillStyle1": "false",
            "stateLineStyle": "false",
            "stateMoveTo": "true",
            "stateNewStyles": "false"
        })
        ET.SubElement(shape_records, "item", {
            "type": "StraightEdgeRecord",
            "deltaX": w_twips,
            "deltaY": "0",
            "generalLineFlag": "true",
            "numBits": "16"
        })
        ET.SubElement(shape_records, "item", {
            "type": "StraightEdgeRecord",
            "deltaX": "0",
            "deltaY": h_twips,
            "generalLineFlag": "true",
            "numBits": "16"
        })
        ET.SubElement(shape_records, "item", {
            "type": "StraightEdgeRecord",
            "deltaX": f"-{w_twips}",
            "deltaY": "0",
            "generalLineFlag": "true",
            "numBits": "16"
        })
        ET.SubElement(shape_records, "item", {
            "type": "StraightEdgeRecord",
            "deltaX": "0",
            "deltaY": f"-{h_twips}",
            "generalLineFlag": "true",
            "numBits": "16"
        })
        ET.SubElement(shape_records, "item", {"type": "EndShapeRecord", "endOfShape": "0"})

        self.remove_tag("DefineBitsLossless2Tag", "characterID", cid_str)
        self.remove_tag("DefineShape2Tag", "shapeId", sid_str)

        insert_idx = self._get_insert_index()
        self.tags_container.insert(insert_idx, bmp_tag)
        self.tags_container.insert(insert_idx + 1, shape_tag)

        return {
            "char_id": char_id,
            "shape_id": shape_id,
            "width": final_w,
            "height": final_h,
            "w_twips": final_w * 20,
            "h_twips": final_h * 20,
            "file": rel_path
        }

    def add_multi_frame_sprite(
        self,
        sprite_id: int,
        frame_specs: List[Dict[str, Union[str, int]]],
    ) -> ET.Element:
        """Sematkan MovieClip multi-frame (DefineSpriteTag)."""
        self.used_ids.add(sprite_id)
        sprite_tag = ET.Element("item", {
            "type": "DefineSpriteTag",
            "forceWriteAsLong": "true",
            "frameCount": str(len(frame_specs)),
            "hasEndTag": "true",
            "spriteId": str(sprite_id)
        })
        sub_tags = ET.SubElement(sprite_tag, "subTags")

        for i, spec in enumerate(frame_specs):
            label = spec.get("label", f"frame{i+1}")
            char_id = str(spec.get("char_id") or spec.get("shape_id"))
            depth = str(spec.get("depth", 1))

            ET.SubElement(sub_tags, "item", {
                "type": "FrameLabelTag",
                "forceWriteAsLong": "false",
                "name": label
            })
            ET.SubElement(sub_tags, "item", {
                "type": "PlaceObject2Tag",
                "characterId": char_id,
                "depth": depth,
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
            ET.SubElement(sub_tags, "item", {
                "type": "ShowFrameTag",
                "forceWriteAsLong": "false"
            })

        self.remove_tag("DefineSpriteTag", "spriteId", str(sprite_id))

        insert_idx = self._get_insert_index()
        self.tags_container.insert(insert_idx, sprite_tag)
        return sprite_tag

    def add_as3_class(
        self,
        class_name: str,
        symbol_id: Optional[int] = None,
        stop_on_frame: Optional[int] = 0,
        template_class: Optional[str] = None,
    ) -> ET.Element:
        """Sematkan bytecode kelas MovieClip AS3 (DoABC2Tag)."""
        template_tag = None
        if template_class and template_class in self.do_abc_tags:
            template_tag = self.do_abc_tags[template_class]
        elif self.do_abc_tags:
            template_tag = next(iter(self.do_abc_tags.values()))

        if template_tag is None:
            raise RuntimeError("Template DoABC2Tag tidak ditemukan di SWF XML untuk dikloning")

        orig_name = template_tag.attrib.get("name", "")
        new_abc = copy.deepcopy(template_tag)
        new_abc.attrib["name"] = class_name

        for s in new_abc.findall(".//constant_string/item"):
            if s.text:
                if orig_name:
                    s.text = s.text.replace(orig_name, class_name)
                elif "frame" in s.text:
                    pass

        if stop_on_frame is not None:
            # 24 00 = pushbyte 0, 24 0f = pushbyte 15, dll.
            hex_byte = f"24{stop_on_frame:02x}"
            for mb in new_abc.findall(".//bodies/item"):
                cb = mb.attrib.get("codeBytes", "")
                if "24" in cb and "5d0c" in cb:
                    # Ganti operand pushbyte
                    import re
                    mb.attrib["codeBytes"] = re.sub(r"24[0-9a-fA-F]{2}", hex_byte, cb, count=1)

        self.remove_tag("DoABC2Tag", "name", class_name)

        insert_idx = self._get_insert_index()
        self.tags_container.insert(insert_idx, new_abc)
        self.do_abc_tags[class_name] = new_abc

        if symbol_id is not None:
            self.register_symbol(symbol_id, class_name)

        return new_abc

    def add_sound(
        self,
        src_sound_path: Union[str, Path],
        dest_sounds_dir: Union[str, Path],
        sound_id: int,
    ) -> Dict[str, Union[int, str]]:
        """Sematkan file audio MP3 sebagai DefineSoundTag."""
        src_path = Path(src_sound_path).resolve()
        if not src_path.exists():
            raise FileNotFoundError(f"File suara tidak ditemukan: {src_path}")

        dest_dir = Path(dest_sounds_dir).resolve()
        dest_dir.mkdir(parents=True, exist_ok=True)

        dest_mp3 = dest_dir / f"{sound_id}.mp3"
        if not dest_mp3.exists() or dest_mp3.stat().st_mtime < src_path.stat().st_mtime:
            shutil.copy2(src_path, dest_mp3)

        try:
            rel_path = dest_mp3.relative_to(self.xml_path.parent).as_posix()
        except ValueError:
            rel_path = dest_mp3.as_posix()

        sid_str = str(sound_id)
        self.remove_tag("DefineSoundTag", "soundId", sid_str)

        snd_tag = ET.Element("item", {
            "type": "DefineSoundTag",
            "_externalFile": rel_path,
            "soundId": sid_str,
        })

        insert_idx = self._get_insert_index()
        self.tags_container.insert(insert_idx, snd_tag)
        self.used_ids.add(sound_id)

        return {
            "sound_id": sound_id,
            "file": rel_path,
        }

    def add_as3_sound_class(
        self,
        class_name: str,
        symbol_id: int,
    ) -> ET.Element:
        """Sematkan bytecode kelas Sound AS3 (DoABC2Tag) yang extend flash.media.Sound."""
        snd_xml_str = SOUND_CLASS_TEMPLATE.strip()
        new_abc = ET.fromstring(snd_xml_str)
        new_abc.attrib["name"] = class_name
        for s in new_abc.findall(".//constant_string/item"):
            if s.text == "snd_menu1":
                s.text = class_name

        self.remove_tag("DoABC2Tag", "name", class_name)
        insert_idx = self._get_insert_index()
        self.tags_container.insert(insert_idx, new_abc)
        self.do_abc_tags[class_name] = new_abc

        self.register_symbol(symbol_id, class_name)
        return new_abc

    def register_symbol(self, tag_id: int, class_name: str):
        """Daftarkan relasi symbol_id ke nama kelas pada SymbolClassTag."""
        tid_str = str(tag_id)
        if self.symbol_class_tag is None:
            self.symbol_class_tag = ET.SubElement(self.tags_container, "item", {
                "type": "SymbolClassTag"
            })
            ET.SubElement(self.symbol_class_tag, "tags")
            ET.SubElement(self.symbol_class_tag, "names")

        tags_elem = self.symbol_class_tag.find("tags")
        names_elem = self.symbol_class_tag.find("names")

        existing_tags = [t.text for t in tags_elem.findall("item")]
        if tid_str in existing_tags:
            idx = existing_tags.index(tid_str)
            names_elem.findall("item")[idx].text = class_name
        else:
            ET.SubElement(tags_elem, "item").text = tid_str
            ET.SubElement(names_elem, "item").text = class_name

        self.symbol_map[tid_str] = class_name
        self.used_ids.add(tag_id)

    def _get_insert_index(self) -> int:
        """Cari indeks penyisipan sebelum SymbolClassTag."""
        for i, tag in enumerate(self.tags_container):
            if tag.get("type") == "SymbolClassTag":
                return i
        return len(self.tags_container) - 1

    def save(self, out_xml_path: Optional[Union[str, Path]] = None) -> Path:
        """Simpan perubahan dokumen XML ke file."""
        target = Path(out_xml_path or self.xml_path).resolve()
        self.tree.write(target, encoding="UTF-8", xml_declaration=True)
        return target
