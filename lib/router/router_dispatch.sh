#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/router/router_behavior_engine.sh"
source "${KROOT}/lib/runtime/kao-runtime.sh"
source "${KROOT}/lib/runtime/event_normalizer.sh"
source "${KROOT}/lib/router/gateway_intelligence.sh"
source "${KROOT}/lib/router/router_timeline.sh"

router_dispatch() {

    local intent="$*"
    local provider agent confidence

    # --- cognitive evaluation ---
    gateway_intelligence_evaluate "$intent"

    # --- behavioral cognition ---
    router_behavior_compute


    # values expected from gateway layer (safe defaults)
    provider="${GATEWAY_SELECTED_PROVIDER:-unknown}"
    agent="${GATEWAY_SELECTED_AGENT:-unknown}"
    confidence="${GATEWAY_ROUTE_CONFIDENCE:-0}"

    # --- canonical timeline pulse ---
    router_timeline_emit "$provider" "$agent" "$intent" "$confidence"

    # --- authority canonization pulse ---
    if [ "$provider" != "unknown" ]; then
        kao_runtime_authority_pulse \
            "router-canonized" \
            "provider=${provider};agent=${agent};intent=${intent};confidence=${confidence}"
    fi

    # --- legacy behaviour ---
    echo "ROUTER DISPATCH (legacy execution)"
}
