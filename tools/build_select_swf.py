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

from tools.modules.swf_lib import SwfCompiler

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


def clean_background_black_boxes():
    """Hapus kotak hitam transparan pada background select screen (75.png)."""
    img_path = WORK_ASSETS_DIR / "images" / "75.png"
    if not img_path.exists():
        print(f"    [!] Peringatan: {img_path} tidak ditemukan, lewati pembersihan kotak")
        return

    print(f"[*] Membersihkan kotak hitam foto karakter lama dari {img_path.name}...")
    from PIL import Image
    im = Image.open(img_path).convert("RGBA")
    pixels = im.load()
    w, h = im.size

    cleaned_count = 0
    # Area kotak P1: X=[30..360], Y=[50..380]
    # Area kotak P2: X=[920..1260], Y=[50..380]
    for y in range(50, 380):
        for x in range(w):
            if (30 <= x <= 360) or (920 <= x <= 1260):
                r, g, b, a = pixels[x, y]
                if r == 0 and g == 0 and b == 0 and a > 0:
                    pixels[x, y] = (0, 0, 0, 0)
                    cleaned_count += 1

    im.save(img_path)
    print(f"    [OK] Dihapus {cleaned_count} pixel bingkai hitam dari {img_path.name}!")


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


def verify_as3(swf_path: Path):
    print(f"[*] Verifikasi kelas ActionScript 3 di {swf_path.name}...")
    raw_lines = SwfCompiler.dump_as3(swf_path)
    classes = [line.split()[0] for line in raw_lines if line.strip()]
    missing = [c for c in EXPECTED_CLASSES if c not in classes]
    if missing:
        raise RuntimeError(f"Verifikasi GAGAL! Kelas AVM2 hilang di {swf_path.name}: {missing}")
    print(f"[OK] Seluruh {len(classes)} kelas AVM2 terverifikasi di {swf_path.name}!")


def main():
    parser = argparse.ArgumentParser(description="Builder otomatis select.swf STARBLAST")
    parser.add_argument("--force", action="store_true", help="Paksa ekspor ulang baseline XML dari select.swf.orig")
    parser.add_argument("--clean", action="store_true", help="Bersihkan scratch/select_xml sebelum build")
    parser.add_argument("--no-verify", action="store_true", help="Lewati verifikasi bytecode kelas AVM2")
    parser.add_argument("--output", type=str, default=str(ORIG_SWF), help="Jalur file tujuan select.swf")
    args = parser.parse_args()

    start_time = time.time()
    out_swf = Path(args.output).resolve()

    print("=" * 60)
    print("STARBLAST Select Screen SWF Builder")
    print("=" * 60)

    xml_path = prepare_base_xml(force=args.force, clean=args.clean)
    clean_background_black_boxes()
    patch_select_xml(xml_path)
    prune_dead_assets(xml_path)

    print(f"[*] Kompilasi {xml_path.name} -> {out_swf.name}...")
    SwfCompiler.build_swf(xml_path=xml_path, out_swf_path=out_swf)

    if not args.no_verify:
        verify_as3(out_swf)

    elapsed = time.time() - start_time
    file_size_kb = out_swf.stat().st_size / 1024
    print("=" * 60)
    print(f"[OK] select.swf berhasil dibangun dalam {elapsed:.2f}s ({file_size_kb:.1f} KB)")
    print(f"Tujuan: {out_swf}")
    print("=" * 60)


if __name__ == "__main__":
    main()
