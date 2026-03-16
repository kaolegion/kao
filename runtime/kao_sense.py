#!/usr/bin/env python3
import os
import sys
import json
import time

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_DIR = os.path.join(KROOT, "state", "sense")
REGISTRY = os.path.join(STATE_DIR, "signals.log")

def ensure():
    os.makedirs(STATE_DIR, exist_ok=True)

def capture(msg):
    ensure()
    event = {
        "ts": int(time.time()),
        "type": "operator",
        "message": msg
    }
    with open(REGISTRY, "a") as f:
        f.write(json.dumps(event) + "\n")
    print("sense captured")

def list_signals():
    ensure()
    if not os.path.exists(REGISTRY):
        print("no signals")
        return
    with open(REGISTRY) as f:
        for line in f:
            print(line.strip())

def state():
    ensure()
    count = 0
    if os.path.exists(REGISTRY):
        with open(REGISTRY) as f:
            count = len(f.readlines())
    print("sense_state")
    print("signals:", count)

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else None

    if cmd == "capture":
        capture(" ".join(sys.argv[2:]))
    elif cmd == "list":
        list_signals()
    elif cmd == "state":
        state()
    else:
        print("usage: sense [capture|list|state]")
