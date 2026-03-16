#!/usr/bin/env python3
import os, json, time

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

GOALS_INDEX = os.path.join(KROOT, "state/goals/index.json")
FEEDBACK_LOG = os.path.join(KROOT, "state/feedback/feedback.log")
SIGNALS_LOG = os.path.join(KROOT, "state/sense/signals.log")

STATE_DIR = os.path.join(KROOT, "state/priority")
STATE_FILE = os.path.join(STATE_DIR, "priority.state")

def load_goals():
    if not os.path.exists(GOALS_INDEX):
        return []
    idx = json.load(open(GOALS_INDEX))
    goals = []
    for gid, path in idx.items():
        try:
            data = json.load(open(path))
            goals.append((gid, data.get("created", 0)))
        except:
            pass
    return goals

def feedback_score():
    if not os.path.exists(FEEDBACK_LOG):
        return 0
    return sum(1 for l in open(FEEDBACK_LOG) if '"result": "success"' in l)

def signal_score():
    if not os.path.exists(SIGNALS_LOG):
        return 0
    return sum(1 for _ in open(SIGNALS_LOG))

def compute():
    now = int(time.time())
    fb = feedback_score() * 10
    sg = signal_score() * 5

    scored = []
    for gid, created in load_goals():
        recency = max(1, now - created)
        score = (1000000 // recency) + fb + sg
        scored.append((gid, score))

    scored.sort(key=lambda x: x[1], reverse=True)
    return scored

def list_priority():
    os.makedirs(STATE_DIR, exist_ok=True)
    scored = compute()
    json.dump(scored, open(STATE_FILE, "w"), indent=2)
    for gid, sc in scored:
        print(f"{gid}\t{sc}")

def state():
    os.makedirs(STATE_DIR, exist_ok=True)
    if not os.path.exists(STATE_FILE):
        print("no_priority_state")
        return
    print(open(STATE_FILE).read())

if __name__ == "__main__":
    import sys
    cmd = sys.argv[1] if len(sys.argv) > 1 else None
    if cmd == "list":
        list_priority()
    elif cmd == "state":
        state()
    else:
        print("usage: priority [list|state]")
