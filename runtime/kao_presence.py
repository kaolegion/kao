#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PULSE = os.path.join(KROOT, "state/pulse/pulse.state")
TIMELINE = os.path.join(KROOT, "state/timeline/timeline.state")
WORKSPACE = os.path.join(KROOT, "state/workspace/workspace.state")
PRIORITY = os.path.join(KROOT, "state/priority/priority.state")

STATE_DIR = os.path.join(KROOT, "state/presence")
STATE_FILE = os.path.join(STATE_DIR, "presence.state")

def load_json(path):
    if os.path.exists(path):
        return json.load(open(path))
    return None

def build():
    pulse = load_json(PULSE)
    timeline = load_json(TIMELINE)
    workspace = load_json(WORKSPACE)
    priority = load_json(PRIORITY)

    presence = {
        "events": len(timeline) if timeline else 0,
        "intensity": pulse.get("intensity") if pulse else 0,
        "workspace": workspace.get("workspace") if workspace else None,
        "top_priority": priority[0][0] if priority else None
    }

    return presence

def show():
    os.makedirs(STATE_DIR, exist_ok=True)
    state = build()
    json.dump(state, open(STATE_FILE, "w"), indent=2)

    print("presence")
    for k,v in state.items():
        print(k, ":", v)

def state():
    if not os.path.exists(STATE_FILE):
        print("no_presence_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "state":
        state()
    else:
        show()
