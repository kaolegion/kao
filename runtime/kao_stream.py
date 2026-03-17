#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TIMELINE = os.path.join(KROOT, "state/timeline/timeline.state")
PRESENCE = os.path.join(KROOT, "state/presence/presence.state")
PULSE = os.path.join(KROOT, "state/pulse/pulse.state")

STATE_DIR = os.path.join(KROOT, "state/stream")
STATE_FILE = os.path.join(STATE_DIR, "stream.state")

def load(path):
    if os.path.exists(path):
        return json.load(open(path))
    return None

def build():
    timeline = load(TIMELINE) or []
    presence = load(PRESENCE) or {}
    pulse = load(PULSE) or {}

    last_events = timeline[-5:] if len(timeline) >= 5 else timeline

    stream = {
        "presence": presence,
        "pulse": pulse,
        "last_events": last_events
    }

    return stream

def show():
    os.makedirs(STATE_DIR, exist_ok=True)
    state = build()
    json.dump(state, open(STATE_FILE, "w"), indent=2)

    print("stream")
    print("events:", len(state["last_events"]))
    print("intensity:", state["pulse"].get("intensity"))

def state():
    if not os.path.exists(STATE_FILE):
        print("no_stream_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "state":
        state()
    else:
        show()
