#!/usr/bin/env python3
import sys
import time
import shutil
import argparse
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List

PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tools.modules.swf_lib import SwfCompiler, SwfXml

ORIG_SWF = PROJECT_ROOT / "common/swf/select.swf"
BACKUP_SWF = PROJECT_ROOT / "common/swf/select.swf.orig"
WORK_DIR = PROJECT_ROOT / "scratch/select_xml"
XML_FILE = WORK_DIR / "select.xml"
BASE_XML = WORK_DIR / "select_base.xml"
BASE_ASSETS_DIR = WORK_DIR / "select_base_assets"
WORK_ASSETS_DIR = WORK_DIR / "select_assets"

EXPECTED_CLASSES = [
    "ctmc",
    "select_item_mc",
    "select_map_mc",
    "select_map_txt_mc",
    "selected_item_p1_mc",
    "selected_item_p2_mc",
    "slt_item_mc",
    "stg_select",
    "load_item_p1",
    "load_item_p2",
    "load_item_p1_group",
    "load_item_p2_group",
    "stg_selectmap",
    "select_bg_anim103",
    "select_bg_anim124",
    "mbtl_font",
    "select_arrow_left",
    "select_arrow_right",
]

def prepare_base_xml(force: bool = False, clean: bool = False) -> Path:
    if clean and WORK_DIR.exists():
        print(f"[*] Membersihkan direktori kerja: {WORK_DIR}...")
        shutil.rmtree(WORK_DIR, ignore_errors=True)

    if not BACKUP_SWF.exists():
        if ORIG_SWF.exists():
            print(f"[*] Membuat backup select.swf asli -> {BACKUP_SWF.name}...")
            shutil.copy2(ORIG_SWF, BACKUP_SWF)
        else:
            raise FileNotFoundError(f"File {ORIG_SWF} maupun {BACKUP_SWF} tidak ditemukan!")

    source_swf = BACKUP_SWF

    if force or not BASE_XML.exists():
        print(f"[*] Ekspor snapshot XML baseline dari {source_swf.name}...")
        SwfCompiler.export_xml(
            swf_path=source_swf,
            out_xml_path=BASE_XML,
            external=True,
            force=True,
        )

    WORK_DIR.mkdir(parents=True, exist_ok=True)
    print(f"[*] Menyalin {BASE_XML.name} -> {XML_FILE.name}...")
    shutil.copy2(BASE_XML, XML_FILE)

    if BASE_ASSETS_DIR.exists():
        print(f"[*] Menyalin {BASE_ASSETS_DIR.name} -> {WORK_ASSETS_DIR.name}...")
        shutil.copytree(BASE_ASSETS_DIR, WORK_ASSETS_DIR, dirs_exist_ok=True)
        with open(XML_FILE, "r", encoding="utf-8") as f:
            xml_text = f.read()
        xml_text = xml_text.replace("select_base_assets/", "select_assets/")
        with open(XML_FILE, "w", encoding="utf-8") as f:
            f.write(xml_text)

    return XML_FILE


def set_identity_matrix(place_obj: ET.Element):
    place_obj.set("placeFlagHasMatrix", "true")
    mat = place_obj.find("matrix")
    if mat is None:
        mat = ET.SubElement(
            place_obj,
            "matrix",
            {
                "type": "MATRIX",
                "hasRotate": "true",
                "hasScale": "true",
                "nRotateBits": "0",
                "nScaleBits": "18",
                "nTranslateBits": "0",
                "rotateSkew0": "0.0",
                "rotateSkew1": "0.0",
                "scaleX": "1.0",
                "scaleY": "1.0",
                "translateX": "0",
                "translateY": "0",
            },
        )
    else:
        mat.set("type", "MATRIX")
        mat.set("hasRotate", "true")
        mat.set("hasScale", "true")
        mat.set("nRotateBits", "0")
        mat.set("nScaleBits", "18")
        mat.set("nTranslateBits", "0")
        mat.set("rotateSkew0", "0.0")
        mat.set("rotateSkew1", "0.0")
        mat.set("scaleX", "1.0")
        mat.set("scaleY", "1.0")
        mat.set("translateX", "0")
        mat.set("translateY", "0")


def patch_select_xml(xml_path: Path):
    print(f"[*] Patching struktur XML select screen di {xml_path.name}...")
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Sprite 7 (stg_select): hapus penempatan background raster lama 75 (Sprite 6 / depth 2) & 484 (depth 1)
    s7 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='7']")
    if s7 is not None:
        subtags = s7.find("subTags")
        if subtags is not None:
            for child in list(subtags):
                if child.get("characterId") == "6" or child.get("depth") == "2":
                    subtags.remove(child)
                    print("    [-] Hapus background 75 lama (Sprite 6 / depth 2) dari stg_select")
                elif child.get("characterId") == "484" or child.get("depth") == "1":
                    subtags.remove(child)
                    print("    [-] Hapus background raster 484 lama (depth 1) dari stg_select")

    # Hapus tag Sprite 6, 484, dan sub-sprite map lama (13, 16, 20)
    tags = root.find("tags")
    if tags is not None:
        for sid in ["6", "484", "13", "16", "20"]:
            sp = tags.find(f".//item[@type='DefineSpriteTag'][@spriteId='{sid}']")
            if sp is not None:
                tags.remove(sp)
                print(f"    [-] Hapus DefineSpriteTag spriteId {sid}")

    # Sprite 21 (select_map_mc) & Sprite 10 (select_map_txt_mc): kosongkan subTags agar gambar lama 65, 68, 468, 66 terhapus
    s21 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='21']")
    if s21 is not None:
        subtags = s21.find("subTags")
        if subtags is not None:
            subtags.clear()
            subtags.append(ET.Element("item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"}))
            print("    [-] Kosongkan isi select_map_mc (Sprite 21)")

    s10 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='10']")
    if s10 is not None:
        subtags = s10.find("subTags")
        if subtags is not None:
            subtags.clear()
            subtags.append(ET.Element("item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"}))
            print("    [-] Kosongkan isi select_map_txt_mc (Sprite 10)")

    # Sprite 36 (ctmc): hapus characterId 34 (clipping mask)
    s36 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='36']")
    if s36 is not None:
        subtags = s36.find("subTags")
        if subtags is not None:
            for child in list(subtags):
                if child.get("characterId") == "34":
                    subtags.remove(child)
                    print("    [-] Hapus rectangular clipping mask (characterId 34) dari Sprite 36")
                elif child.get("characterId") == "35":
                    child.set("depth", "1")
                    child.set("placeFlagHasClipDepth", "false")
                    if "clipDepth" in child.attrib:
                        del child.attrib["clipDepth"]
                    set_identity_matrix(child)
                    print("    [+] Sesuaikan kontainer portrait di Sprite 36 (depth 1, matriks identitas)")

    # Sprite 39 (selected_item_p2_mc): hapus border kartu Shape 38
    s39 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='39']")
    if s39 is not None:
        subtags = s39.find("subTags")
        if subtags is not None:
            for child in list(subtags):
                if child.get("characterId") == "38":
                    subtags.remove(child)
                    print("    [-] Hapus border kartu P2 (Shape 38) dari Sprite 39")
                elif child.get("characterId") == "36":
                    child.set("depth", "1")
                    set_identity_matrix(child)
                    print("    [+] Sesuaikan kontainer portrait P2 di Sprite 39 (depth 1, matriks identitas)")

    # Sprite 42 (selected_item_p1_mc): hapus border kartu Shape 41
    s42 = root.find(".//item[@type='DefineSpriteTag'][@spriteId='42']")
    if s42 is not None:
        subtags = s42.find("subTags")
        if subtags is not None:
            for child in list(subtags):
                if child.get("characterId") == "41":
                    subtags.remove(child)
                    print("    [-] Hapus border kartu P1 (Shape 41) dari Sprite 42")
                elif child.get("characterId") == "36":
                    child.set("depth", "1")
                    set_identity_matrix(child)
                    print("    [+] Sesuaikan kontainer portrait P1 di Sprite 42 (depth 1, matriks identitas)")

    tree.write(xml_path, encoding="utf-8", xml_declaration=True)
    print(f"[OK] Berhasil menyimpan XML yang telah di-patch ke {xml_path}")


def prune_dead_assets(xml_path: Path):
    print(f"[*] Analisis & bersihkan aset mati di {xml_path.name}...")
    tree = ET.parse(xml_path)
    root = tree.getroot()
    tags = root.find("tags")
    if tags is None:
        return

    entry_cids = set()
    for sym in tags.findall("./item[@type='SymbolClassTag']//tags/item"):
        if sym.text:
            entry_cids.add(sym.text)

    children_map = {}
    tag_by_id = {}

    for it in tags:
        cid = (
            it.get("spriteId")
            or it.get("shapeId")
            or it.get("characterID")
            or it.get("characterId")
            or it.get("fontId")
        )
        if cid:
            tag_by_id[cid] = it
            deps = set()
            for po in it.findall(".//item[@type='PlaceObject2Tag']") + it.findall(".//item[@type='PlaceObject3Tag']"):
                c = po.get("characterId")
                if c:
                    deps.add(c)
            for fs in it.findall(".//item[@type='FILLSTYLE']"):
                bm = fs.get("bitmapId")
                if bm:
                    deps.add(bm)
            children_map[cid] = deps

    reachable = set(entry_cids)
    queue = list(entry_cids)
    while queue:
        curr = queue.pop(0)
        for dep in children_map.get(curr, []):
            if dep not in reachable:
                reachable.add(dep)
                queue.append(dep)

    dead_cids = set(tag_by_id.keys()) - reachable
    removed_tags_count = 0
    removed_files_count = 0

    for dc in list(dead_cids):
        it = tag_by_id[dc]
        tag_type = it.get("type", "")
        ext_file = it.get("_externalFile", "")

        # Hanya bersihkan Bitmap dan Shape
        if "Bits" in tag_type or "Shape" in tag_type:
            tags.remove(it)
            removed_tags_count += 1
            if ext_file:
                file_to_remove = WORK_DIR / ext_file
                if file_to_remove.exists():
                    file_to_remove.unlink()
                    removed_files_count += 1
                if file_to_remove.name.endswith(".jpg"):
                    alpha_file = file_to_remove.with_name(file_to_remove.stem + ".alpha.png")
                    if alpha_file.exists():
                        alpha_file.unlink()
                        removed_files_count += 1

    tree.write(xml_path, encoding="utf-8", xml_declaration=True)
    print(f"    [OK] Dihapus {removed_tags_count} tag tak terpakai dan {removed_files_count} file sisa!")


def inject_mugen_action103(xml_path: Path):
    """Injeksi border overlay Mugen Action 103 ke dalam select.xml."""
    sprites_src = PROJECT_ROOT / "tools/mugen/system_sprites"
    if not sprites_src.exists():
        print(f"    [!] Peringatan: Direktori sprite {sprites_src} tidak ditemukan!")
        return

    print(f"[*] Injeksi Mugen Action 103 ke {xml_path.name}...")
    dest_images_dir = WORK_ASSETS_DIR / "images"
    dest_images_dir.mkdir(parents=True, exist_ok=True)

    swf_xml = SwfXml(xml_path)

    # 1. Daftarkan 41 lossless image (IDs 501..582)
    shape_map = {}
    for i in range(41):
        src_png = sprites_src / f"103_{i}.png"
        cid = 501 + i * 2
        sid = 502 + i * 2
        swf_xml.add_lossless_image(
            src_image_path=src_png,
            dest_assets_dir=dest_images_dir,
            char_id=cid,
            shape_id=sid,
        )
        shape_map[i] = sid

    for i in range(41, 48):
        shape_map[i] = shape_map[40]

    # 2. Bangun Sprite 600 (DefineSpriteTag)
    sprite600 = ET.Element("item", {
        "type": "DefineSpriteTag",
        "forceWriteAsLong": "true",
        "frameCount": "63",
        "hasEndTag": "true",
        "spriteId": "600",
    })
    subtags = ET.SubElement(sprite600, "subTags")

    # Frame 1: fade in start
    ET.SubElement(subtags, "item", {"type": "FrameLabelTag", "forceWriteAsLong": "false", "name": "fade_in"})
    p1 = ET.SubElement(subtags, "item", {
        "type": "PlaceObject2Tag",
        "characterId": str(shape_map[0]),
        "depth": "1",
        "forceWriteAsLong": "false",
        "placeFlagHasCharacter": "true",
        "placeFlagHasClipActions": "false",
        "placeFlagHasClipDepth": "false",
        "placeFlagHasColorTransform": "true",
        "placeFlagHasMatrix": "false",
        "placeFlagHasName": "false",
        "placeFlagHasRatio": "false",
        "placeFlagMove": "false",
    })
    ET.SubElement(p1, "colorTransform", {
        "type": "CXFORMWITHALPHA",
        "alphaMultTerm": "17",
        "blueMultTerm": "256",
        "greenMultTerm": "256",
        "hasAddTerms": "false",
        "hasMultTerms": "true",
        "nbits": "10",
        "redMultTerm": "256",
    })
    ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    # Frames 2..15: interpolasi fade in
    for f in range(2, 16):
        alpha_val = str(round(256 * f / 15))
        p = ET.SubElement(subtags, "item", {
            "type": "PlaceObject2Tag",
            "depth": "1",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "false",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "true",
            "placeFlagHasMatrix": "false",
            "placeFlagHasName": "false",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "true",
        })
        ET.SubElement(p, "colorTransform", {
            "type": "CXFORMWITHALPHA",
            "alphaMultTerm": alpha_val,
            "blueMultTerm": "256",
            "greenMultTerm": "256",
            "hasAddTerms": "false",
            "hasMultTerms": "true",
            "nbits": "10",
            "redMultTerm": "256",
        })
        ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    # Frame 16: animasi sequence, 100% alpha
    ET.SubElement(subtags, "item", {"type": "FrameLabelTag", "forceWriteAsLong": "false", "name": "anim"})
    ET.SubElement(subtags, "item", {
        "type": "PlaceObject2Tag",
        "characterId": str(shape_map[0]),
        "depth": "1",
        "forceWriteAsLong": "false",
        "placeFlagHasCharacter": "true",
        "placeFlagHasClipActions": "false",
        "placeFlagHasClipDepth": "false",
        "placeFlagHasColorTransform": "false",
        "placeFlagHasMatrix": "false",
        "placeFlagHasName": "false",
        "placeFlagHasRatio": "false",
        "placeFlagMove": "true",
    })
    ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    # Frames 17..62: urutan frame 1..46
    for num in range(1, 47):
        ET.SubElement(subtags, "item", {
            "type": "PlaceObject2Tag",
            "characterId": str(shape_map[num]),
            "depth": "1",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "false",
            "placeFlagHasMatrix": "false",
            "placeFlagHasName": "false",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "true",
        })
        ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    # Frame 63: frame akhir (47) dengan stop permanen
    ET.SubElement(subtags, "item", {"type": "FrameLabelTag", "forceWriteAsLong": "false", "name": "end"})
    ET.SubElement(subtags, "item", {
        "type": "PlaceObject2Tag",
        "characterId": str(shape_map[47]),
        "depth": "1",
        "forceWriteAsLong": "false",
        "placeFlagHasCharacter": "true",
        "placeFlagHasClipActions": "false",
        "placeFlagHasClipDepth": "false",
        "placeFlagHasColorTransform": "false",
        "placeFlagHasMatrix": "false",
        "placeFlagHasName": "false",
        "placeFlagHasRatio": "false",
        "placeFlagMove": "true",
    })
    ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    swf_xml.remove_tag("DefineSpriteTag", "spriteId", "600")
    idx = swf_xml._get_insert_index()
    swf_xml.tags_container.insert(idx, sprite600)
    swf_xml.used_ids.add(600)

    # 3. Hubungkan kelas ActionScript 3 dengan stop pada frame 63 (index 62 = 0x3e)
    swf_xml.add_as3_class(class_name="select_bg_anim103", symbol_id=600, stop_on_frame=62)

    # 4. Tempatkan Sprite 600 di stg_select (Sprite 7) pada Depth 3
    sp7 = swf_xml.tags_container.find(".//item[@type='DefineSpriteTag'][@spriteId='7']")
    if sp7 is not None:
        s7_sub = sp7.find("subTags")
        for c in list(s7_sub):
            if c.get("depth") == "3":
                s7_sub.remove(c)

        insert_pos = len(s7_sub) - 1
        for i, c in enumerate(s7_sub):
            d = c.get("depth")
            if d and d.isdigit() and int(d) > 3:
                insert_pos = i
                break

        p_bg = ET.Element("item", {
            "type": "PlaceObject2Tag",
            "characterId": "600",
            "depth": "3",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "false",
            "placeFlagHasMatrix": "true",
            "placeFlagHasName": "true",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "false",
            "name": "anim103_mc",
        })
        ET.SubElement(p_bg, "matrix", {
            "type": "MATRIX",
            "hasRotate": "false",
            "hasScale": "false",
            "nRotateBits": "0",
            "nScaleBits": "0",
            "nTranslateBits": "12",
            "scaleX": "1.0",
            "scaleY": "1.0",
            "translateX": "-400",
            "translateY": "0",
        })
        s7_sub.insert(insert_pos, p_bg)

    swf_xml.save()
    print(f"    [OK] Berhasil menginjeksi Sprite 600 & kelas select_bg_anim103 ke {xml_path.name}!")


def inject_mugen_action124(xml_path: Path):
    """Injeksi animasi bar futuristik Mugen Action 124 ke dalam select.xml."""
    sprites_src = PROJECT_ROOT / "tools/mugen/system_sprites"
    if not sprites_src.exists():
        print(f"    [!] Peringatan: Direktori sprite {sprites_src} tidak ditemukan!")
        return

    print(f"[*] Injeksi Mugen Action 124 ke {xml_path.name}...")
    dest_images_dir = WORK_ASSETS_DIR / "images"
    dest_images_dir.mkdir(parents=True, exist_ok=True)

    swf_xml = SwfXml(xml_path)

    # 1. Daftarkan 21 lossless image (IDs 701..742)
    shape_map = {}
    for i in range(21):
        src_png = sprites_src / f"124_{i}.png"
        cid = 701 + i * 2
        sid = 702 + i * 2
        swf_xml.add_lossless_image(
            src_image_path=src_png,
            dest_assets_dir=dest_images_dir,
            char_id=cid,
            shape_id=sid,
        )
        shape_map[i] = sid

    # 2. Bangun Sprite 700 (DefineSpriteTag dengan 105 frame)
    sprite700 = ET.Element("item", {
        "type": "DefineSpriteTag",
        "forceWriteAsLong": "true",
        "frameCount": "105",
        "hasEndTag": "true",
        "spriteId": "700",
    })
    subtags = ET.SubElement(sprite700, "subTags")

    anim_json = PROJECT_ROOT / "scratch/anim_124/action_124.json"
    frames_data = []
    if anim_json.exists():
        import json
        with open(anim_json, "r", encoding="utf-8") as jf:
            frames_data = json.load(jf).get("frames", [])

    for idx in range(105):
        spr_idx = idx % 21
        is_first = (idx == 0)

        if idx == 0:
            ET.SubElement(subtags, "item", {"type": "FrameLabelTag", "forceWriteAsLong": "false", "name": "fade_in"})
        elif idx == 84:
            ET.SubElement(subtags, "item", {"type": "FrameLabelTag", "forceWriteAsLong": "false", "name": "loop"})

        place_obj = ET.SubElement(subtags, "item", {
            "type": "PlaceObject2Tag",
            "characterId": str(shape_map[spr_idx]),
            "depth": "1",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasMatrix": "false",
            "placeFlagHasName": "false",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "false" if is_first else "true",
        })

        if idx < 84:
            if idx < len(frames_data) and "blend" in frames_data[idx]:
                blend_str = frames_data[idx]["blend"]
                alpha_mult = int(blend_str.replace("AS", "").split("D")[0])
            else:
                alpha_mult = round(3 + (251 - 3) * idx / 83)

            place_obj.set("placeFlagHasColorTransform", "true")
            ET.SubElement(place_obj, "colorTransform", {
                "type": "CXFORMWITHALPHA",
                "alphaMultTerm": str(alpha_mult),
                "blueMultTerm": "256",
                "greenMultTerm": "256",
                "hasAddTerms": "false",
                "hasMultTerms": "true",
                "nbits": "10",
                "redMultTerm": "256",
            })
        else:
            place_obj.set("placeFlagHasColorTransform", "false")

        ET.SubElement(subtags, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})

    swf_xml.remove_tag("DefineSpriteTag", "spriteId", "700")
    insert_idx = swf_xml._get_insert_index()
    swf_xml.tags_container.insert(insert_idx, sprite700)
    swf_xml.used_ids.add(700)

    # 3. Hubungkan kelas ActionScript 3 (stop di frame terakhir: frame 105 / index 104)
    swf_xml.add_as3_class(class_name="select_bg_anim124", symbol_id=700, stop_on_frame=104)

    # 4. Tempatkan Sprite 700 di stg_select (Sprite 7) pada Depth 4
    sp7 = swf_xml.tags_container.find(".//item[@type='DefineSpriteTag'][@spriteId='7']")
    if sp7 is not None:
        s7_sub = sp7.find("subTags")
        for c in list(s7_sub):
            if c.get("depth") == "4":
                s7_sub.remove(c)

        insert_pos = len(s7_sub) - 1
        for i, c in enumerate(s7_sub):
            d = c.get("depth")
            if d and d.isdigit() and int(d) > 4:
                insert_pos = i
                break

        p_bg = ET.Element("item", {
            "type": "PlaceObject2Tag",
            "characterId": "700",
            "depth": "4",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "false",
            "placeFlagHasMatrix": "true",
            "placeFlagHasName": "true",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "false",
            "name": "anim124_mc",
        })
        ET.SubElement(p_bg, "matrix", {
            "type": "MATRIX",
            "hasRotate": "false",
            "hasScale": "false",
            "nRotateBits": "0",
            "nScaleBits": "0",
            "nTranslateBits": "15",
            "scaleX": "1.0",
            "scaleY": "1.0",
            "translateX": "-1360",
            "translateY": "12160",
        })
        s7_sub.insert(insert_pos, p_bg)

    swf_xml.save()
    print(f"    [OK] Berhasil menginjeksi Sprite 700 & kelas select_bg_anim124 ke {xml_path.name}!")


def inject_mugen_arrows(xml_path: Path):
    """Injeksi panah seleksi Mugen/MBTL (180_1.png untuk kiri, 180_0.png untuk kanan) ke dalam select.xml."""
    sprites_src = PROJECT_ROOT / "tools/mugen/system_sprites"
    dest_images_dir = WORK_ASSETS_DIR / "images"
    dest_images_dir.mkdir(parents=True, exist_ok=True)

    swf_xml = SwfXml(xml_path)

    # 1. Panah kiri (180_1.png) -> char_id=751, shape_id=752, sprite_id=750 -> class "select_arrow_left"
    src_left = sprites_src / "180_1.png"
    if src_left.exists():
        swf_xml.add_lossless_image(
            src_image_path=src_left,
            dest_assets_dir=dest_images_dir,
            char_id=751,
            shape_id=752,
        )
        swf_xml.remove_tag("DefineSpriteTag", "spriteId", "750")
        sp_left = ET.Element("item", {
            "type": "DefineSpriteTag",
            "forceWriteAsLong": "true",
            "frameCount": "1",
            "hasEndTag": "true",
            "spriteId": "750",
        })
        sub_left = ET.SubElement(sp_left, "subTags")
        ET.SubElement(sub_left, "item", {
            "type": "PlaceObject2Tag",
            "characterId": "752",
            "depth": "1",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "false",
            "placeFlagHasMatrix": "false",
            "placeFlagHasName": "false",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "false",
        })
        ET.SubElement(sub_left, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})
        insert_idx = swf_xml._get_insert_index()
        swf_xml.tags_container.insert(insert_idx, sp_left)
        swf_xml.used_ids.add(750)
        swf_xml.add_as3_class(class_name="select_arrow_left", symbol_id=750, stop_on_frame=None)

    # 2. Panah kanan (180_0.png) -> char_id=761, shape_id=762, sprite_id=760 -> class "select_arrow_right"
    src_right = sprites_src / "180_0.png"
    if src_right.exists():
        swf_xml.add_lossless_image(
            src_image_path=src_right,
            dest_assets_dir=dest_images_dir,
            char_id=761,
            shape_id=762,
        )
        swf_xml.remove_tag("DefineSpriteTag", "spriteId", "760")
        sp_right = ET.Element("item", {
            "type": "DefineSpriteTag",
            "forceWriteAsLong": "true",
            "frameCount": "1",
            "hasEndTag": "true",
            "spriteId": "760",
        })
        sub_right = ET.SubElement(sp_right, "subTags")
        ET.SubElement(sub_right, "item", {
            "type": "PlaceObject2Tag",
            "characterId": "762",
            "depth": "1",
            "forceWriteAsLong": "false",
            "placeFlagHasCharacter": "true",
            "placeFlagHasClipActions": "false",
            "placeFlagHasClipDepth": "false",
            "placeFlagHasColorTransform": "false",
            "placeFlagHasMatrix": "false",
            "placeFlagHasName": "false",
            "placeFlagHasRatio": "false",
            "placeFlagMove": "false",
        })
        ET.SubElement(sub_right, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})
        insert_idx = swf_xml._get_insert_index()
        swf_xml.tags_container.insert(insert_idx, sp_right)
        swf_xml.used_ids.add(760)
        swf_xml.add_as3_class(class_name="select_arrow_right", symbol_id=760, stop_on_frame=None)

    swf_xml.save()
    print(f"    [OK] Berhasil menginjeksi panah MBTL select_arrow_left & select_arrow_right ke {xml_path.name}!")


def _trace_glyph(png_path: Path, scale: int = 1024, baseline_y: int = 17):
    from PIL import Image
    from collections import defaultdict

    im = Image.open(png_path)
    w, h = im.size
    pixels = im.load()

    def is_solid(x, y):
        if 0 <= x < w and 0 <= y < h:
            a = pixels[x, y][3] if len(pixels[x, y]) > 3 else 255
            return a > 128
        return False

    segments = []
    min_x, max_x = w, 0
    min_y, max_y = h, 0
    solid_count = 0

    for y in range(h):
        for x in range(w):
            if is_solid(x, y):
                solid_count += 1
                min_x = min(min_x, x)
                max_x = max(max_x, x + 1)
                min_y = min(min_y, y)
                max_y = max(max_y, y + 1)
                if not is_solid(x, y - 1):
                    segments.append(((x + 1, y), (x, y)))
                if not is_solid(x, y + 1):
                    segments.append(((x, y + 1), (x + 1, y + 1)))
                if not is_solid(x - 1, y):
                    segments.append(((x, y), (x, y + 1)))
                if not is_solid(x + 1, y):
                    segments.append(((x + 1, y + 1), (x + 1, y)))

    if solid_count == 0:
        shape = ET.Element("item", {"type": "SHAPE", "numFillBits": "0", "numLineBits": "0"})
        recs = ET.SubElement(shape, "shapeRecords")
        ET.SubElement(recs, "item", {"type": "EndShapeRecord", "endOfShape": "0"})
        return shape, 8 * scale, (0, 0, 0, 0)

    adj = defaultdict(list)
    for p1, p2 in segments:
        adj[p1].append(p2)

    loops = []
    visited_edges = set()
    for p1, p2 in segments:
        if (p1, p2) in visited_edges:
            continue
        loop = [p1]
        curr = p1
        next_p = p2
        visited_edges.add((curr, next_p))
        while next_p != p1:
            loop.append(next_p)
            curr = next_p
            candidates = [p for p in adj[curr] if (curr, p) not in visited_edges]
            if not candidates:
                break
            next_p = candidates[0]
            visited_edges.add((curr, next_p))
        loops.append(loop)

    simplified_loops = []
    for loop in loops:
        simplified = []
        n = len(loop)
        for j in range(n):
            p_prev = loop[(j - 1) % n]
            p_curr = loop[j]
            p_next = loop[(j + 1) % n]
            d1 = (p_curr[0] - p_prev[0], p_curr[1] - p_prev[1])
            d2 = (p_next[0] - p_curr[0], p_next[1] - p_curr[1])
            if d1[0] * d2[1] == d1[1] * d2[0] and (d1[0]*d2[0] >= 0 and d1[1]*d2[1] >= 0):
                continue
            simplified.append(p_curr)
        if len(simplified) >= 3:
            simplified_loops.append(simplified)

    shape = ET.Element("item", {"type": "SHAPE", "numFillBits": "1", "numLineBits": "0"})
    shape_recs = ET.SubElement(shape, "shapeRecords")

    for loop in simplified_loops:
        start_x = loop[0][0] * scale
        start_y = (loop[0][1] - baseline_y) * scale
        ET.SubElement(shape_recs, "item", {
            "type": "StyleChangeRecord",
            "fillStyle0": "1",
            "moveBits": "16",
            "moveDeltaX": str(start_x),
            "moveDeltaY": str(start_y),
            "stateFillStyle0": "true",
            "stateFillStyle1": "false",
            "stateLineStyle": "false",
            "stateMoveTo": "true",
            "stateNewStyles": "false"
        })
        n = len(loop)
        for j in range(n):
            p1 = loop[j]
            p2 = loop[(j + 1) % n]
            dx = (p2[0] - p1[0]) * scale
            dy = (p2[1] - p1[1]) * scale
            if dx != 0 and dy != 0:
                ET.SubElement(shape_recs, "item", {
                    "type": "StraightEdgeRecord",
                    "deltaX": str(dx),
                    "deltaY": str(dy),
                    "generalLineFlag": "true",
                    "numBits": "16"
                })
            elif dx != 0:
                ET.SubElement(shape_recs, "item", {
                    "type": "StraightEdgeRecord",
                    "deltaX": str(dx),
                    "generalLineFlag": "false",
                    "numBits": "16",
                    "vertLineFlag": "false"
                })
            elif dy != 0:
                ET.SubElement(shape_recs, "item", {
                    "type": "StraightEdgeRecord",
                    "deltaY": str(dy),
                    "generalLineFlag": "false",
                    "numBits": "16",
                    "vertLineFlag": "true"
                })

    ET.SubElement(shape_recs, "item", {"type": "EndShapeRecord", "endOfShape": "0"})
    advance = (w + 1) * scale
    bounds = (min_x * scale, max_x * scale, (min_y - baseline_y) * scale, (max_y - baseline_y) * scale)
    return shape, advance, bounds


def inject_mbtl_name_font(xml_path: Path, font_id: int = 900, font_name: str = "MBTL_Name"):
    """Injeksi font vektor MBTL_Name sebagai DefineFont3Tag resmi ke dalam folder fonts di SWF."""
    sprites_dir = PROJECT_ROOT / "tools/mugen/MBTL_Name_sprites"
    if not sprites_dir.exists():
        print(f"    [!] Peringatan: Direktori {sprites_dir} tidak ditemukan!")
        return

    print(f"[*] Injeksi font vektor {font_name} (DefineFont3) ke {xml_path.name}...")
    swf_xml = SwfXml(xml_path)

    # 1. Hapus tag font lama jika ada
    swf_xml.remove_tag("DefineFont3Tag", "fontID", str(font_id))
    swf_xml.remove_tag("DefineFontNameTag", "fontId", str(font_id))

    # 2. Bangun tag DefineFont3Tag
    font_tag = ET.Element("item", {
        "type": "DefineFont3Tag",
        "fontFlagsANSI": "false",
        "fontFlagsBold": "false",
        "fontFlagsHasLayout": "true",
        "fontFlagsItalic": "false",
        "fontFlagsShiftJIS": "false",
        "fontFlagsSmallText": "false",
        "fontFlagsWideCodes": "true",
        "fontFlagsWideOffsets": "true",
        "fontID": str(font_id),
        "fontName": f"{font_name}\\u0000",
        "forceWriteAsLong": "true",
        "fontAscent": "17408",
        "fontDescent": "3072",
        "fontLeading": "0",
    })

    ET.SubElement(font_tag, "languageCode", {"type": "LANGCODE", "languageCode": "1"})
    glyph_table = ET.SubElement(font_tag, "glyphShapeTable")
    code_table = ET.SubElement(font_tag, "codeTable")
    adv_table = ET.SubElement(font_tag, "fontAdvanceTable")
    bounds_table = ET.SubElement(font_tag, "fontBoundsTable")
    ET.SubElement(font_tag, "fontKerningTable")

    sprites = sorted(
        sprites_dir.glob("*.png"),
        key=lambda f: int(f.stem.split("_")[1]) if "_" in f.stem else 0
    )

    for sp in sprites:
        code = int(sp.stem.split("_")[1])
        shape, adv, bounds = _trace_glyph(sp)
        glyph_table.append(shape)
        ET.SubElement(code_table, "item").text = str(code)
        ET.SubElement(adv_table, "item").text = str(adv)
        ET.SubElement(bounds_table, "item", {
            "type": "RECT",
            "Xmin": str(bounds[0]),
            "Xmax": str(bounds[1]),
            "Ymin": str(bounds[2]),
            "Ymax": str(bounds[3]),
            "nbits": "16"
        })

    # 3. Bangun tag DefineFontNameTag
    font_name_tag = ET.Element("item", {
        "type": "DefineFontNameTag",
        "fontCopyright": "Melty Blood Type Lumina",
        "fontId": str(font_id),
        "fontName": font_name,
        "forceWriteAsLong": "true"
    })

    # 4. Masukkan tag font sebelum ShowFrameTag terakhir
    insert_idx = swf_xml._get_insert_index()
    swf_xml.tags_container.insert(insert_idx, font_tag)
    swf_xml.tags_container.insert(insert_idx + 1, font_name_tag)
    swf_xml.used_ids.add(font_id)

    # 5. Injeksi kelas Font AVM2 (DoABC2Tag + SymbolClassTag) agar bisa diregistrasi lewat Font.registerFont di AS3
    swf_xml.add_as3_font_class(class_name="mbtl_font", symbol_id=font_id)

    swf_xml.save()
    print(f"    [OK] Berhasil menginjeksi font {font_name} ({len(sprites)} glyph) ke folder fonts di {xml_path.name}!")


def verify_as3(swf_path: Path):
    print(f"[*] Verifikasi kelas ActionScript 3 di {swf_path.name}...")
    raw_lines = SwfCompiler.dump_as3(swf_path)
    classes = [line.split()[0] for line in raw_lines if line.strip()]
    missing = [c for c in EXPECTED_CLASSES if c not in classes]
    if missing:
        raise RuntimeError(f"Verifikasi GAGAL! Kelas AVM2 hilang di {swf_path.name}: {missing}")
    print(f"[OK] Seluruh {len(classes)} kelas AVM2 terverifikasi di {swf_path.name}!")


def verify_font(swf_path: Path, expected_font_name: str = "MBTL_Name"):
    print(f"[*] Verifikasi tag font di {swf_path.name}...")
    res = SwfCompiler.run_cmd(["-dumpSwf", str(swf_path)])
    found = False
    for line in res.stdout.splitlines():
        if "DefineFont3" in line and expected_font_name in line:
            found = True
            break
    if not found:
        raise RuntimeError(f"Verifikasi GAGAL! Font {expected_font_name} tidak ditemukan di {swf_path.name}!")
    print(f"[OK] Font {expected_font_name} (DefineFont3) terverifikasi di {swf_path.name}!")


def main():
    parser = argparse.ArgumentParser(description="Builder otomatis select.swf STARBLAST")
    parser.add_argument("--force", action="store_true", help="Paksa ekspor ulang baseline XML dari select.swf.orig")
    parser.add_argument("--clean", action="store_true", help="Bersihkan scratch/select_xml sebelum build")
    parser.add_argument("--no-verify", action="store_true", help="Lewati verifikasi bytecode kelas AVM2 dan font")
    parser.add_argument("--output", type=str, default=str(ORIG_SWF), help="Jalur file tujuan select.swf")
    args = parser.parse_args()

    start_time = time.time()
    out_swf = Path(args.output).resolve()

    print("=" * 60)
    print("STARBLAST Select Screen SWF Builder")
    print("=" * 60)

    xml_path = prepare_base_xml(force=args.force, clean=args.clean)
    patch_select_xml(xml_path)
    prune_dead_assets(xml_path)
    inject_mugen_action103(xml_path)
    inject_mugen_action124(xml_path)
    inject_mbtl_name_font(xml_path)
    inject_mugen_arrows(xml_path)

    print(f"[*] Kompilasi {xml_path.name} -> {out_swf.name}...")
    SwfCompiler.build_swf(xml_path=xml_path, out_swf_path=out_swf)

    if not args.no_verify:
        verify_as3(out_swf)
        verify_font(out_swf)

    elapsed = time.time() - start_time
    file_size_kb = out_swf.stat().st_size / 1024
    print("=" * 60)
    print(f"[OK] select.swf berhasil dibangun dalam {elapsed:.2f}s ({file_size_kb:.1f} KB)")
    print(f"Tujuan: {out_swf}")
    print("=" * 60)


if __name__ == "__main__":
    main()
