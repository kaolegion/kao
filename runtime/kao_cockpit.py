#!/usr/bin/env python3
import os, json

KROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SURFACE = os.path.join(KROOT, "state/surface/surface.state")
STREAM = os.path.join(KROOT, "state/stream/stream.state")

def load(path):
    if os.path.exists(path):
        return json.load(open(path))
    return {}

def show():
    surface = load(SURFACE)
    stream = load(STREAM)

    print("===== KAO COCKPIT =====")
    print("workspace :", surface.get("workspace"))
    print("events    :", surface.get("events"))
    print("intensity :", surface.get("intensity"))
    print("priority  :", surface.get("top_priority"))
    print("")
    print("last events:")
    for ev in stream.get("last_events", []):
        print("-", ev["type"], ev["ref"])
    print("")
    print("RUN STATUS : COMPLETED")

if __name__ == "__main__":
    show()
