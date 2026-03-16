#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/session_heat_engine.sh"
source "${KROOT}/lib/router/router_cognitive_state.sh"

router_behavior_compute() {

    local heat memory mode level

    heat="$(kao_session_heat_read_field SESSION_HEAT_LEVEL 2>/dev/null || echo WARM)"
    memory="$(kao_session_heat_read_field SESSION_MEMORY_CLASS 2>/dev/null || echo WARM)"

    case "${heat}" in
        HOT)
            mode="AGGRESSIVE"
            level=3
            ;;
        WARM)
            mode="BALANCED"
            level=2
            ;;
        COLD)
            mode="ECONOMY"
            level=1
            ;;
        *)
            mode="BALANCED"
            level=2
            ;;
    esac

    router_state_write ROUTER_MODE "${mode}"
    router_state_write ROUTER_COGNITIVE_LEVEL "${level}"

    export ROUTER_BEHAVIOR_MODE="${mode}"
}
