#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ORBITS = [
    "/home/kao/bin",
    "/opt/kaobox/bin"
]

STATE_DIR = os.path.join(KROOT, "state/tools")
STATE_FILE = os.path.join(STATE_DIR, "tools.state")

def scan():
    tools = []
    for orbit in ORBITS:
        if os.path.exists(orbit):
            for f in os.listdir(orbit):
                path = os.path.join(orbit, f)
                if os.access(path, os.X_OK):
                    tools.append({
                        "name": f,
                        "path": path
                    })
    return tools

def show():
    os.makedirs(STATE_DIR, exist_ok=True)

    tools = scan()

    json.dump(tools, open(STATE_FILE, "w"), indent=2)

    print("orbital_tools:", len(tools))
    for t in tools:
        print(t["name"], "->", t["path"])

if __name__ == "__main__":
    show()
