#!/usr/bin/env bash

# REKON-TRANSITIONAL-DISPATCH: current dispatch layer emits timeline and authority pulses but still ends in legacy execution.
# TODO(REKON): replace legacy tail with a canonical router execution contract once router-core is declared.
# TODO(REKON-TEST): preserve pulse emission and provider/agent/confidence propagation during dispatch canonisation.

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

# --- cognitive router decision trace ---
kao_router_log_decision() {
    local provider="$1"
    local score="$2"
    local reason="$3"
    echo "[KAO][ROUTER][DECISION] provider=${provider} score=${score} reason=${reason}"
}

