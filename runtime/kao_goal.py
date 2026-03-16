import os, json, time, uuid, sys

BASE = "/home/kao/state/goals"
INDEX = os.path.join(BASE, "index.json")
GOALDIR = os.path.join(BASE, "goals")

def load_index():
    if not os.path.exists(INDEX):
        return {}
    with open(INDEX, "r", encoding="utf-8") as f:
        return json.load(f)

def save_index(idx):
    with open(INDEX, "w", encoding="utf-8") as f:
        json.dump(idx, f, indent=2, ensure_ascii=False)

def create_goal(description, priority=0):
    os.makedirs(GOALDIR, exist_ok=True)
    idx = load_index()

    gid = "goal_" + uuid.uuid4().hex[:8]
    path = os.path.join(GOALDIR, gid + ".json")

    payload = {
        "id": gid,
        "description": description,
        "created_at": int(time.time()),
        "completed": False,
        "priority": int(priority)
    }

    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    idx[gid] = path
    save_index(idx)
    print(gid)

def list_goals():
    idx = load_index()
    active = []

    for gid, path in idx.items():
        if not os.path.exists(path):
            continue
        with open(path, "r", encoding="utf-8") as f:
            payload = json.load(f)
        if not payload.get("completed", False):
            active.append(payload)

    active.sort(key=lambda g: (-int(g.get("priority", 0)), int(g.get("created_at", 0))))

    for goal in active:
        print(f'{goal["id"]}\tP{goal["priority"]}\t{goal["description"]}')

def complete_goal(gid):
    idx = load_index()
    path = idx.get(gid)

    if not path or not os.path.exists(path):
        print("not found")
        return

    with open(path, "r", encoding="utf-8") as f:
        payload = json.load(f)

    payload["completed"] = True
    payload["completed_at"] = int(time.time())

    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    print(gid)

def main():
    if len(sys.argv) < 2:
        print("usage: python3 /home/kao/runtime/kao_goal.py [create|list|complete] ...")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "create":
        if len(sys.argv) < 3:
            print("usage: python3 /home/kao/runtime/kao_goal.py create \"description\" [priority]")
            sys.exit(1)

        if len(sys.argv) >= 4 and sys.argv[-1].isdigit():
            priority = int(sys.argv[-1])
            description = " ".join(sys.argv[2:-1])
        else:
            priority = 0
            description = " ".join(sys.argv[2:])

        create_goal(description, priority)

    elif cmd == "list":
        list_goals()

    elif cmd == "complete":
        if len(sys.argv) != 3:
            print("usage: python3 /home/kao/runtime/kao_goal.py complete <goal_id>")
            sys.exit(1)
        complete_goal(sys.argv[2])

    else:
        print("unknown command")
        sys.exit(1)

if __name__ == "__main__":
    main()
