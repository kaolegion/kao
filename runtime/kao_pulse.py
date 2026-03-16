#!/usr/bin/env python3
import os, json, time

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMELINE = os.path.join(KROOT, "state/timeline/timeline.state")

STATE_DIR = os.path.join(KROOT, "state/pulse")
STATE_FILE = os.path.join(STATE_DIR, "pulse.state")

def compute():
    if not os.path.exists(TIMELINE):
        return 0, 0, 0

    data = json.load(open(TIMELINE))
    count = len(data)

    if count == 0:
        return 0, 0, 0

    last_ts = data[-1]["ts"]
    now = int(time.time())

    recency = max(1, now - last_ts)
    intensity = count / recency

    return count, recency, intensity

def show():
    os.makedirs(STATE_DIR, exist_ok=True)

    count, recency, intensity = compute()

    state = {
        "events": count,
        "recency": recency,
        "intensity": intensity
    }

    json.dump(state, open(STATE_FILE, "w"), indent=2)

    print("pulse")
    print("events:", count)
    print("recency:", recency)
    print("intensity:", intensity)

if __name__ == "__main__":
    show()
