#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
ROUTER_STATE_DIR="${KROOT}/state/router"
ROUTER_STATE_FILE="${ROUTER_STATE_DIR}/router.cognitive.state"

router_state_init() {
mkdir -p "${ROUTER_STATE_DIR}"
if [ ! -f "${ROUTER_STATE_FILE}" ]; then
echo "router cognitive state missing"
fi
}

router_state_read() {
[ -f "${ROUTER_STATE_FILE}" ] && cat "${ROUTER_STATE_FILE}"
}

router_state_write() {
key="$1"
value="$2"

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
