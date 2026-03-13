#!/usr/bin/env python3
import sys
from pathlib import Path

HOME = Path.home()
TEMPLATES = HOME / "templates"

def create_from_template(kind, name):
    if kind == "md":
        tpl = TEMPLATES / "md" / "base.md"
        target = Path(f"{name}.md")

    elif kind == "html":
        target_dir = Path(name)
        target_dir.mkdir(exist_ok=True)
        tpl = TEMPLATES / "html" / "index.html"
        target = target_dir / "index.html"

    elif kind == "py":
        tpl = TEMPLATES / "py" / "script.py"
        target = Path(f"{name}.py")

    else:
        print(f"[FAIL] unknown kind: {kind}")
        sys.exit(1)

    if target.exists():
        print(f"[WARN] target exists: {target}")
        return

    content = tpl.read_text()
    target.write_text(content)
    print(f"[OK] created {target}")

def main():
    if len(sys.argv) < 4:
        print("usage: kao new <type> <name>")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "new":
        kind = sys.argv[2]
        name = sys.argv[3]
        create_from_template(kind, name)
    else:
        print(f"[FAIL] unknown command {cmd}")

if __name__ == "__main__":
    main()
