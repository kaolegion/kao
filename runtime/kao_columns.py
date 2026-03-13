#!/usr/bin/env python3
from pathlib import Path
import sys

HOME = Path.home().resolve()

def fmt_entry(path: Path) -> str:
    return f"[D] {path.name}" if path.is_dir() else f"[F] {path.name}"

def children(path: Path):
    if not path.exists() or not path.is_dir():
        return []
    return sorted(path.iterdir(), key=lambda p: (p.is_file(), p.name.lower()))

def first_dir(entries):
    for entry in entries:
        if entry.is_dir():
            return entry
    return None

def pad(lines, size):
    lines = lines[:size]
    while len(lines) < size:
        lines.append("")
    return lines

def main() -> int:
    target = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) >= 2 else HOME

    if not target.exists():
        print(f"[FAIL] path not found: {target}")
        return 1

    root_entries = children(target) if target.is_dir() else [target]
    col1 = [fmt_entry(p) for p in root_entries]

    first = first_dir(root_entries) if target.is_dir() else None
    second_entries = children(first) if first else []
    col2 = [fmt_entry(p) for p in second_entries]

    second = first_dir(second_entries)
    third_entries = children(second) if second else []
    col3 = [fmt_entry(p) for p in third_entries]

    height = max(12, len(col1), len(col2), len(col3))
    col1 = pad(col1, height)
    col2 = pad(col2, height)
    col3 = pad(col3, height)

    print("===== KAO COLUMNS =====")
    print(f"TARGET          : {target}")
    print("COLUMN 1        : target children")
    print("COLUMN 2        : first directory children")
    print("COLUMN 3        : nested directory children")
    print()

    print(f"{'COL1':<32} {'COL2':<32} {'COL3':<32}")
    print(f"{'-'*32} {'-'*32} {'-'*32}")
    for a, b, c in zip(col1, col2, col3):
        print(f"{a:<32} {b:<32} {c:<32}")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
