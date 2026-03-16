#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ACTIONS = os.path.join(KROOT, "state/actions/logs")
FEEDBACK = os.path.join(KROOT, "state/feedback/feedback.log")
SIGNALS = os.path.join(KROOT, "state/sense/signals.log")
GOALS = os.path.join(KROOT, "state/goals/goals")

STATE_DIR = os.path.join(KROOT, "state/timeline")
STATE_FILE = os.path.join(STATE_DIR, "timeline.state")

def collect():
    events = []

    # actions
    if os.path.exists(ACTIONS):
        for f in os.listdir(ACTIONS):
            data = json.load(open(os.path.join(ACTIONS, f)))
            events.append({
                "ts": data["ts"],
                "type": "action",
                "ref": data["action"]
            })

    # feedback
    if os.path.exists(FEEDBACK):
        for line in open(FEEDBACK):
            data = json.loads(line)
            events.append({
                "ts": data["ts"],
                "type": "feedback",
                "ref": data["action"]
            })

    # signals
    if os.path.exists(SIGNALS):
        for line in open(SIGNALS):
            data = json.loads(line)
            events.append({
                "ts": data["ts"],
                "type": "signal",
                "ref": data["message"]
            })

    # goals
    if os.path.exists(GOALS):
        for f in os.listdir(GOALS):
            data = json.load(open(os.path.join(GOALS, f)))
            events.append({
                "ts": data.get("created_at", 0),
                "type": "goal",
                "ref": data["id"]
            })

    events.sort(key=lambda x: x["ts"])
    return events

def show():
    os.makedirs(STATE_DIR, exist_ok=True)
    ev = collect()
    json.dump(ev, open(STATE_FILE, "w"), indent=2)
    for e in ev:
        print(f'{e["ts"]}\t{e["type"]}\t{e["ref"]}')

def state():
    if not os.path.exists(STATE_FILE):
        print("no_timeline_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    cmd = sys.argv[1] if len(sys.argv) > 1 else None
    if cmd == "show":
        show()
    elif cmd == "state":
        state()
    else:
        print("usage: timeline [show|state]")
