#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/session_heat_engine.sh"
source "${KROOT}/lib/router/router_cognitive_state.sh"

router_behavior_compute() {

    local heat network mode level

    heat="$(kao_session_heat_read_field SESSION_HEAT_LEVEL 2>/dev/null || echo WARM)"

    if grep -q "KAO_RUNTIME_NETWORK=ONLINE" "${KROOT}/state/runtime/runtime.state" 2>/dev/null; then
        network="ONLINE"
    else
        network="OFFLINE"
    fi

    case "${network}-${heat}" in

        OFFLINE-*)
            mode="SURVIVAL"
            level=1
            ;;

        ONLINE-COLD)
            mode="OPPORTUNISTIC"
            level=2
            ;;

        ONLINE-WARM|ONLINE-HOT)
            mode="PERFORMANCE"
            level=3
            ;;

        *)
            mode="BALANCED"
            level=2
            ;;
    esac

    router_state_write ROUTER_MODE "${mode}"
    router_state_write ROUTER_NETWORK "${network}"
    router_state_write ROUTER_COGNITIVE_LEVEL "${level}"

    export ROUTER_BEHAVIOR_MODE="${mode}"
}
