# Generator otomatis definisi CNS dan CMD karakter BVN untuk STARBLAST C++.

import os
import sys
import json
import argparse
from pathlib import Path

def parse_air_actions(air_path: Path):
    actions = set()
    if not air_path.exists():
        return actions
    with open(air_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if line.startswith("[Begin Action") and "]" in line:
                try:
                    num_str = line.split("[Begin Action")[1].split("]")[0].strip()
                    actions.add(int(num_str))
                except Exception:
                    pass
    return actions

def estimate_height_from_air(air_path: Path):
    max_height = 0
    if not air_path.exists():
        return 70
    with open(air_path, "r", encoding="utf-8", errors="ignore") as f:
        in_stand = False
        for line in f:
            line = line.strip()
            if line.startswith("[Begin Action 0]"):
                in_stand = True
                continue
            elif line.startswith("[Begin Action") and in_stand:
                break
            if in_stand and line.startswith("Clsn2"):
                parts = line.split("=")
                if len(parts) > 1:
                    coords = [int(p.strip()) for p in parts[1].split(",") if p.strip().lstrip("-").isdigit()]
                    if len(coords) >= 4:
                        h = abs(coords[3] - coords[1])
                        if h > max_height:
                            max_height = h
    return max_height if max_height > 20 else 70

def generate_cns_content(char_id: str, char_name: str, localcoord_x: int, localcoord_y: int, actions: set) -> str:
    lines = [
        f"; Character CNS Definition for {char_name} ({char_id})",
        f"[Data]",
        f"life = 1000",
        f"power = 3000",
        f"attack = 100",
        f"defence = 100",
        f"[Size]",
        f"xscale = 1",
        f"yscale = 1",
        f"ground.back = 15",
        f"ground.front = 16",
        f"air.back = 12",
        f"air.front = 12",
        f"height = 60",
        f"localcoord = {localcoord_x}, {localcoord_y}",
        f"[Velocity]",
        f"walk.fwd = 2.4",
        f"walk.back = -2.2",
        f"run.fwd = 6.5, 0",
        f"jump.neu = 0, -8.5",
        f"jump.back = -2.55",
        f"jump.fwd = 2.55",
        f"[Movement]",
        f"airjump.num = 1",
        f"yaccel = 0.52",
        f"stand.friction = 0.85",
        f"crouch.friction = 0.82\n"
    ]

    has_atk2 = (210 in actions)
    has_atk3 = (220 in actions)

    lines.extend([
        ";---------------------------------------------------------------------------",
        "; Attack 1 (J)",
        ";---------------------------------------------------------------------------",
        "[Statedef 200]",
        "type = S",
        "movetype = A",
        "physics = S",
        "anim = 200",
        "ctrl = 0",
        "velset = 0, 0",
        "",
        "[State 200, HitBox]",
        "type = HitDef",
        "trigger1 = time = 2 && !movecontact",
        "attr = S, NA",
        "damage = 25, 0",
        "animtype = Light",
        "guardflag = M",
        "hitflag = MAF",
        "pausetime = 8, 8",
        "sparkno = 7000",
        "guard.sparkno = 7010",
        "hitsound = 5, 0",
        "ground.type = High",
        "ground.slidetime = 10",
        "ground.hittime = 15",
        "ground.velocity = -2.0, 0",
        "air.velocity = -2.0, -3.0",
        ""
    ])
    if has_atk2:
        lines.extend([
            "[State 200, Chain Attack 2]",
            "type = ChangeState",
            "trigger1 = movecontact && command = \"attack\"",
            "value = 210",
            ""
        ])
    lines.extend([
        "[State 200, End]",
        "type = ChangeState",
        "trigger1 = animtime = 0",
        "value = 0",
        "ctrl = 1\n"
    ])

    if has_atk2:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Attack 2 (JJ)",
            ";---------------------------------------------------------------------------",
            "[Statedef 210]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 210",
            "ctrl = 0",
            "velset = 1.0, 0",
            "",
            "[State 210, HitBox]",
            "type = HitDef",
            "trigger1 = time = 2 && !movecontact",
            "attr = S, NA",
            "damage = 30, 0",
            "animtype = Medium",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 8, 8",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.type = High",
            "ground.slidetime = 12",
            "ground.hittime = 16",
            "ground.velocity = -2.5, 0",
            "air.velocity = -2.5, -3.0",
            ""
        ])
        if has_atk3:
            lines.extend([
                "[State 210, Chain Attack 3]",
                "type = ChangeState",
                "trigger1 = movecontact && command = \"attack\"",
                "value = 220",
                ""
            ])
        lines.extend([
            "[State 210, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if has_atk3:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Attack 3 Finisher (JJJ)",
            ";---------------------------------------------------------------------------",
            "[Statedef 220]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 220",
            "ctrl = 0",
            "velset = 2.0, 0",
            "",
            "[State 220, HitBox Finisher]",
            "type = HitDef",
            "trigger1 = time = 3 && !movecontact",
            "attr = S, NA",
            "damage = 45, 0",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 12, 12",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.type = Trip",
            "ground.slidetime = 15",
            "ground.hittime = 20",
            "ground.velocity = -6.5, -2.0",
            "air.velocity = -6.5, -3.5",
            "fall = 1",
            "",
            "[State 220, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if 600 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Jump Attack (Air J)",
            ";---------------------------------------------------------------------------",
            "[Statedef 600]",
            "type = A",
            "movetype = A",
            "physics = A",
            "anim = 600",
            "ctrl = 0",
            "",
            "[State 600, HitBox]",
            "type = HitDef",
            "trigger1 = time = 2 && !movecontact",
            "attr = A, NA",
            "damage = 35, 0",
            "animtype = Medium",
            "guardflag = HA",
            "hitflag = MAF",
            "pausetime = 8, 8",
            "sparkno = 7000",
            "hitsound = 5, 0",
            "ground.velocity = -3.0, 0",
            "air.velocity = -3.0, -2.5",
            "",
            "[State 600, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 41\n"
        ])

    if 1000 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Skill 1 (U)",
            ";---------------------------------------------------------------------------",
            "[Statedef 1000]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 1000",
            "ctrl = 0",
            "",
            "[State 1000, HitBox]",
            "type = HitDef",
            "trigger1 = time = 4 && !movecontact",
            "attr = S, SA",
            "damage = 75, 5",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 10, 10",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.velocity = -5.0, -2.0",
            "air.velocity = -5.0, -3.0",
            "fall = 1",
            "",
            "[State 1000, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if 1010 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Skill 2 (W+U)",
            ";---------------------------------------------------------------------------",
            "[Statedef 1010]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 1010",
            "ctrl = 0",
            "",
            "[State 1010, HitBox]",
            "type = HitDef",
            "trigger1 = time = 4 && !movecontact",
            "attr = S, SA",
            "damage = 85, 5",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 10, 10",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.velocity = -3.0, -6.5",
            "air.velocity = -3.0, -6.0",
            "fall = 1",
            "",
            "[State 1010, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if 1020 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Skill 3 (S+U)",
            ";---------------------------------------------------------------------------",
            "[Statedef 1020]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 1020",
            "ctrl = 0",
            "",
            "[State 1020, HitBox]",
            "type = HitDef",
            "trigger1 = time = 4 && !movecontact",
            "attr = S, SA",
            "damage = 90, 5",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 10, 10",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.velocity = -6.0, 0",
            "air.velocity = -6.0, -2.0",
            "fall = 1",
            "",
            "[State 1020, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if 3000 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Bisha 1-Bar (Super I)",
            ";---------------------------------------------------------------------------",
            "[Statedef 3000]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 3000",
            "ctrl = 0",
            "",
            "[State 3000, SuperPause]",
            "type = SuperPause",
            "trigger1 = time = 0",
            "time = 30",
            "movetime = 30",
            "darken = 1",
            "",
            "[State 3000, Drain Power]",
            "type = PowerAdd",
            "trigger1 = time = 0",
            "value = -1000",
            "",
            "[State 3000, HitBox]",
            "type = HitDef",
            "trigger1 = time = 10 && !movecontact",
            "attr = S, HA",
            "damage = 200, 20",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 15, 15",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.velocity = -8.0, -3.0",
            "air.velocity = -8.0, -3.5",
            "fall = 1",
            "",
            "[State 3000, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    if 3100 in actions:
        lines.extend([
            ";---------------------------------------------------------------------------",
            "; Bisha Super 3-Bar (Ultra W+I)",
            ";---------------------------------------------------------------------------",
            "[Statedef 3100]",
            "type = S",
            "movetype = A",
            "physics = S",
            "anim = 3100",
            "ctrl = 0",
            "",
            "[State 3100, SuperPause Darken]",
            "type = SuperPause",
            "trigger1 = time = 0",
            "time = 60",
            "movetime = 60",
            "darken = 1",
            "",
            "[State 3100, Drain Power 3-Bar]",
            "type = PowerAdd",
            "trigger1 = time = 0",
            "value = -3000",
            "",
            "[State 3100, HitBox Ultra]",
            "type = HitDef",
            "trigger1 = time = 15 && !movecontact",
            "attr = S, HA",
            "damage = 380, 40",
            "animtype = Heavy",
            "guardflag = M",
            "hitflag = MAF",
            "pausetime = 20, 20",
            "sparkno = 7000",
            "guard.sparkno = 7010",
            "hitsound = 5, 0",
            "ground.velocity = -12.0, -4.0",
            "air.velocity = -12.0, -4.5",
            "fall = 1",
            "",
            "[State 3100, End]",
            "type = ChangeState",
            "trigger1 = animtime = 0",
            "value = 0",
            "ctrl = 1\n"
        ])

    return "\n".join(lines)

def generate_cmd_content(char_id: str) -> str:
    return f"""; Command Definitions for {char_id} (STARBLAST C++)
[Remap]
x = x
y = y
z = z
a = a
b = b
c = c
s = s

[Defaults]
command.time = 15
command.buffer.time = 1

[Command]
name = "wankai"
command = y+b
time = 10

[Command]
name = "bisha_super"
command = D, y
time = 12

[Command]
name = "bisha"
command = y
time = 1

[Command]
name = "skill3"
command = D, x
time = 10

[Command]
name = "skill2"
command = U, x
time = 10

[Command]
name = "skill1"
command = x
time = 1

[Command]
name = "ghost_step"
command = D, c
time = 10

[Command]
name = "dash"
command = c
time = 1

[Command]
name = "attack"
command = a
time = 1

[Command]
name = "jump"
command = b
time = 1

[Command]
name = "assist"
command = z
time = 1

[Command]
name = "hold_assist"
command = /z
time = 1

[Command]
name = "holdfwd"
command = /F
time = 1

[Command]
name = "holdback"
command = /B
time = 1

[Command]
name = "holdup"
command = /U
time = 1

[Command]
name = "holddown"
command = /D
time = 1
"""

def process_character_dir(char_dir: Path):
    char_id = char_dir.name
    char_name = char_id.capitalize()

    json_path = char_dir / "character.json"
    if json_path.exists():
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                char_name = data.get("name", char_name)
        except Exception:
            pass

    air_path = char_dir / f"{char_id}.air"
    actions = parse_air_actions(air_path)
    height = estimate_height_from_air(air_path)

    lc_x = int(round(height * 320.0 / 200.0))
    lc_y = int(round(height * 240.0 / 200.0))
    if lc_x < 80: lc_x = 112
    if lc_y < 60: lc_y = 84

    print(f"[{char_id}] Tinggi berdiri terdeteksi: ~{height}px -> localcoord = {lc_x}, {lc_y}")

    cns_path = char_dir / f"{char_id}.cns"
    cns_content = generate_cns_content(char_id, char_name, lc_x, lc_y, actions)
    with open(cns_path, "w", encoding="utf-8") as f:
        f.write(cns_content)
    print(f"[{char_id}] Menghasilkan {cns_path} ({len(cns_content.splitlines())} baris)")

    cmd_path = char_dir / f"{char_id}.cmd"
    cmd_content = generate_cmd_content(char_id)
    with open(cmd_path, "w", encoding="utf-8") as f:
        f.write(cmd_content)
    print(f"[{char_id}] Menghasilkan {cmd_path}")

def main():
    parser = argparse.ArgumentParser(description="Generator CNS & CMD Karakter BVN STARBLAST")
    parser.add_argument("char_dir", help="Path ke direktori karakter")
    args = parser.parse_args()

    p = Path(args.char_dir).resolve()
    if not p.exists() or not p.is_dir():
        print(f"Direktori tidak ditemukan: {p}")
        sys.exit(1)

    process_character_dir(p)

if __name__ == "__main__":
    main()
