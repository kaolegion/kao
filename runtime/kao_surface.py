#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PRESENCE = os.path.join(KROOT, "state/presence/presence.state")
PULSE = os.path.join(KROOT, "state/pulse/pulse.state")
PRIORITY = os.path.join(KROOT, "state/priority/priority.state")
WORKSPACE = os.path.join(KROOT, "state/workspace/workspace.state")

STATE_DIR = os.path.join(KROOT, "state/surface")
STATE_FILE = os.path.join(STATE_DIR, "surface.state")

def load(path):
    if os.path.exists(path):
        return json.load(open(path))
    return None

def build():
    presence = load(PRESENCE) or {}
    pulse = load(PULSE) or {}
    priority = load(PRIORITY) or []
    workspace = load(WORKSPACE) or {}

    surface = {
        "workspace": workspace.get("workspace"),
        "events": presence.get("events"),
        "intensity": pulse.get("intensity"),
        "top_priority": priority[0][0] if priority else None
    }

    return surface

def show():
    os.makedirs(STATE_DIR, exist_ok=True)
    state = build()
    json.dump(state, open(STATE_FILE, "w"), indent=2)

    print("surface")
    for k, v in state.items():
        print(k, ":", v)

def state():
    if not os.path.exists(STATE_FILE):
        print("no_surface_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "state":
        state()
    else:
        show()
