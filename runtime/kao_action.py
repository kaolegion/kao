import os, json, time, uuid, subprocess, sys

BASE = "/home/kao/state/actions"
REGISTRY = os.path.join(BASE, "registry.json")
LOGDIR = os.path.join(BASE, "logs")

def load_registry():
    if not os.path.exists(REGISTRY):
        return {}
    return json.load(open(REGISTRY))

def save_registry(reg):
    json.dump(reg, open(REGISTRY, "w"), indent=2)

def register_action(name, command):
    reg = load_registry()
    aid = "action_" + uuid.uuid4().hex[:8]

    reg[aid] = {
        "name": name,
        "command": command,
        "created": int(time.time())
    }

    save_registry(reg)
    print(aid)

def list_actions():
    reg = load_registry()
    for aid, data in reg.items():
        print(f'{aid}\t{data["name"]}\t{data["command"]}')

def run_action(aid):
    reg = load_registry()
    if aid not in reg:
        print("not found")
        return

    cmd = reg[aid]["command"]
    ts = int(time.time())

    try:
        result = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, timeout=60)
        status = "success"
        output = result.decode()
    except Exception as e:
        status = "error"
        output = str(e)

    log = {
        "action": aid,
        "ts": ts,
        "status": status,
        "output": output
    }

    os.makedirs(LOGDIR, exist_ok=True)
    json.dump(log, open(os.path.join(LOGDIR, f"log_{ts}.json"), "w"), indent=2)

    print(status)

def main():
    cmd = sys.argv[1]

    if cmd == "register":
        register_action(sys.argv[2], " ".join(sys.argv[3:]))

    elif cmd == "list":
        list_actions()

    elif cmd == "run":
        run_action(sys.argv[2])

if __name__ == "__main__":
    main()
