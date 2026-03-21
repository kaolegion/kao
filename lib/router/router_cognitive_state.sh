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
ROUTER_SOVEREIGN_STATE=LOCAL_FIRST
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

# =========================================================
# KAO ROUTER — COGNITIVE SCORING V0
# atomic minimal sovereign decision helper
# =========================================================

kao_router_score_provider() {

    local provider="$1"
    local local_available="$2"
    local cloud_allowed="$3"
    local operator_pref="$4"

    local score=0
    local reason=""

    if [ "$provider" = "local" ] && [ "$local_available" = "1" ]; then
        score=$((score+50))
        reason="local_available"
    fi

    if [ "$provider" = "cloud" ] && [ "$cloud_allowed" = "1" ]; then
        score=$((score+20))
        reason="$reason cloud_allowed"
    fi

    if [ "$provider" = "$operator_pref" ]; then
        score=$((score+15))
        reason="$reason operator_pref"
    fi

    echo "$score|$reason"
}


# KAO-CANON-POLICY-FALLBACK: sovereign router selection policy surface.
# TODO(REKON): replace fallback with direct canonical projection once router selection integration is unified.
kao_router_selection_policy() {
    printf 'best-available-by-state\n'
}
