#!/usr/bin/env python3
import sys
from pathlib import Path

def list_dir(target: Path) -> int:
    if not target.exists():
        print(f"[FAIL] path not found: {target}")
        return 1

    if target.is_file():
        print("===== KAO LIST =====")
        print(f"TARGET          : {target}")
        print("TYPE            : file")
        print(f"NAME            : {target.name}")
        return 0

    print("===== KAO LIST =====")
    print(f"TARGET          : {target}")
    print("TYPE            : directory")

    entries = sorted(target.iterdir(), key=lambda p: (p.is_file(), p.name.lower()))
    if not entries:
        print("[INFO] empty directory")
        return 0

    for entry in entries:
        kind = "dir " if entry.is_dir() else "file"
        print(f"{kind:4}  {entry.name}")
    return 0

def tree_dir(target: Path, depth: int = 2, level: int = 0) -> None:
    if level == 0:
        print("===== KAO TREE =====")
        print(f"TARGET          : {target}")

    if not target.exists():
        print(f"[FAIL] path not found: {target}")
        return

    if target.is_file():
        print(target.name)
        return

    entries = sorted(target.iterdir(), key=lambda p: (p.is_file(), p.name.lower()))
    for entry in entries:
        indent = "  " * level
        prefix = "▣" if entry.is_dir() else "•"
        print(f"{indent}{prefix} {entry.name}")
        if entry.is_dir() and level + 1 < depth:
            tree_dir(entry, depth=depth, level=level + 1)

def main() -> int:
    if len(sys.argv) < 2:
        print("usage: kao-list <path> [list|tree] [depth]")
        return 1

    target = Path(sys.argv[1]).expanduser().resolve()
    mode = sys.argv[2] if len(sys.argv) >= 3 else "list"

    if mode == "list":
        return list_dir(target)

    if mode == "tree":
        depth = int(sys.argv[3]) if len(sys.argv) >= 4 else 2
        tree_dir(target, depth=depth)
        return 0

    print(f"[FAIL] unsupported mode: {mode}")
    return 1

if __name__ == "__main__":
    raise SystemExit(main())
