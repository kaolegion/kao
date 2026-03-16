#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_DIR = os.path.join(KROOT, "state/workspace")
STATE_FILE = os.path.join(STATE_DIR, "workspace.state")

def detect():
    return os.getcwd()

def show():
    os.makedirs(STATE_DIR, exist_ok=True)

    ws = detect()

    state = {
        "workspace": ws
    }

    json.dump(state, open(STATE_FILE, "w"), indent=2)

    print("workspace:", ws)

def state():
    if not os.path.exists(STATE_FILE):
        print("no_workspace_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "state":
        state()
    else:
        show()
