#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
ROUTER_STATE_DIR="${KROOT}/state/router"
ROUTER_STATE_FILE="${ROUTER_STATE_DIR}/router.cognitive.state"

router_state_init() {
mkdir -p "${ROUTER_STATE_DIR}"
if [ ! -f "${ROUTER_STATE_FILE}" ]; then
cat <<'EOF_STATE' > "${ROUTER_STATE_FILE}"
ROUTER_MODE=UNKNOWN
ROUTER_NETWORK=UNKNOWN
ROUTER_PROVIDER=UNKNOWN
ROUTER_AGENT=UNKNOWN
ROUTER_INTENT=UNKNOWN
ROUTER_COGNITIVE_LEVEL=0
ROUTER_CONFIDENCE=0
ROUTER_LATENCY=0
ROUTER_HEALTH=INIT
EOF_STATE
fi
}

router_state_read() {
router_state_init
cat "${ROUTER_STATE_FILE}"
}

router_state_write() {
key="$1"
value="$2"

router_state_init

tmp="$(mktemp)"

while IFS= read -r line; do
if echo "$line" | grep -q "^${key}="; then
echo "${key}=${value}" >> "$tmp"
else
echo "$line" >> "$tmp"
fi
done < "${ROUTER_STATE_FILE}"

mv "$tmp" "${ROUTER_STATE_FILE}"
}

router_state_health_ok() {
router_state_write ROUTER_HEALTH STABLE
}
