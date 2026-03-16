#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/event_normalizer.sh"

router_timeline_emit() {

    local provider="$1"
    local agent="$2"
    local intent="$3"
    local confidence="$4"

    if [ -n "${ROUTER_BEHAVIOR_MODE}" ]; then
        event_normalizer_emit_router_dispatch \
            "behavior" \
            "${ROUTER_BEHAVIOR_MODE}" \
            "session_influence" \
            "1.0"
    fi

    event_normalizer_emit_router_dispatch \
        "$provider" \
        "$agent" \
        "$intent" \
        "$confidence"
}
