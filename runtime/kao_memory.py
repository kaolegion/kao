import os, json, time, uuid, sys

BASE = "/home/kao/state/memory"
INDEX = os.path.join(BASE, "index.json")
MEMDIR = os.path.join(BASE, "memories")

def load_index():
    if not os.path.exists(INDEX):
        return {}
    with open(INDEX, "r", encoding="utf-8") as f:
        return json.load(f)

def save_index(idx):
    with open(INDEX, "w", encoding="utf-8") as f:
        json.dump(idx, f, indent=2, ensure_ascii=False)

def add(text):
    os.makedirs(MEMDIR, exist_ok=True)
    idx = load_index()
    mid = "mem_" + uuid.uuid4().hex[:8]
    path = os.path.join(MEMDIR, mid + ".json")

    payload = {
        "id": mid,
        "text": text,
        "ts": int(time.time())
    }

    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    idx[mid] = path
    save_index(idx)
    print(mid)

def search(query):
    idx = load_index()
    query_l = query.lower()
    for mid, path in idx.items():
        with open(path, "r", encoding="utf-8") as f:
            payload = json.load(f)
        if query_l in payload["text"].lower():
            print(mid)

def recall(mid):
    idx = load_index()
    path = idx.get(mid)
    if not path or not os.path.exists(path):
        print("not found")
        return

    with open(path, "r", encoding="utf-8") as f:
        print(f.read())

def main():
    if len(sys.argv) < 2:
        print("usage: python3 runtime/kao_memory.py [add|search|recall] ...")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "add":
        if len(sys.argv) < 3:
            print("usage: python3 runtime/kao_memory.py add \"text\"")
            sys.exit(1)
        add(" ".join(sys.argv[2:]))

    elif cmd == "search":
        if len(sys.argv) < 3:
            print("usage: python3 runtime/kao_memory.py search \"query\"")
            sys.exit(1)
        search(" ".join(sys.argv[2:]))

    elif cmd == "recall":
        if len(sys.argv) != 3:
            print("usage: python3 runtime/kao_memory.py recall <memory_id>")
            sys.exit(1)
        recall(sys.argv[2])

    else:
        print("unknown command")
        sys.exit(1)

if __name__ == "__main__":
    main()
