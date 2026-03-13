#!/usr/bin/env python3
import sys
from pathlib import Path
import subprocess

def preview_md(path):
    print("===== MARKDOWN PREVIEW =====")
    print(path.read_text())

def preview_html(path):
    print("===== HTML PREVIEW =====")
    print(path.read_text())

def preview_py(path):
    print("===== PYTHON SOURCE =====")
    print(path.read_text())

def preview_generic(path):
    print("===== GENERIC FILE =====")
    try:
        print(path.read_text())
    except:
        print("[binary or unreadable file]")

def main():
    if len(sys.argv) < 2:
        print("usage: kao-open <file>")
        sys.exit(1)

    target = Path(sys.argv[1])

    if not target.exists():
        print(f"[FAIL] file not found: {target}")
        sys.exit(1)

    ext = target.suffix.lower()

    if ext == ".md":
        preview_md(target)
    elif ext == ".html":
        preview_html(target)
    elif ext == ".py":
        preview_py(target)
    else:
        preview_generic(target)

if __name__ == "__main__":
    main()
