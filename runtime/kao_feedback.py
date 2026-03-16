#!/usr/bin/env python3
import os
import sys
import json
import time

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_DIR = os.path.join(KROOT, "state", "feedback")
LOGFILE = os.path.join(STATE_DIR, "feedback.log")

def ensure():
    os.makedirs(STATE_DIR, exist_ok=True)

def record(aid, result):
    ensure()

    if result not in ["success", "failure", "neutral"]:
        print("invalid_result")
        return

    entry = {
        "ts": int(time.time()),
        "action": aid,
        "result": result
    }

    with open(LOGFILE, "a") as f:
        f.write(json.dumps(entry) + "\n")

    print("feedback_recorded")

def show_log():
    ensure()
    if not os.path.exists(LOGFILE):
        print("no_feedback")
        return
    with open(LOGFILE) as f:
        for line in f:
            print(line.strip())

def state():
    ensure()
    count = 0
    if os.path.exists(LOGFILE):
        with open(LOGFILE) as f:
            count = len(f.readlines())
    print("feedback_state")
    print("entries:", count)

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else None

    if cmd == "record":
        record(sys.argv[2], sys.argv[3])
    elif cmd == "log":
        show_log()
    elif cmd == "state":
        state()
    else:
        print("usage: feedback [record|log|state]")
