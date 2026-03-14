#!/usr/bin/env bash

# ========================================
# KSL AGENT FIELD ENGINE
# ========================================

ksl_agent_field_signal() {
    local role="${1:-agent}"
    local state="${2:-idle}"

    case "$role:$state" in
        gateway:active)   echo "◆/AGT/active/i3/pulse-fast/gateway" ;;
        gateway:success)  echo "◆/AGT/success/i1/hold/gateway" ;;
        gateway:fallback) echo "◆/AGT/fallback/i2/blink-triple/gateway" ;;
        gateway:error)    echo "◆/AGT/error/i3/blink-fast/gateway" ;;
        agent:active)     echo "•/AGT/active/i2/pulse-slow/agent" ;;
        agent:success)    echo "•/AGT/success/i1/fade/agent" ;;
        agent:idle)       echo "•/AGT/idle/i1/hold/agent" ;;
        agent:fallback)   echo "•/AGT/fallback/i2/blink-triple/agent" ;;
        agent:error)      echo "•/AGT/error/i3/blink-fast/agent" ;;
        observer:active)  echo "⌁/AGT/active/i1/pulse-slow/observer" ;;
        observer:idle)    echo "⌁/AGT/idle/i1/hold/observer" ;;
        observer:success) echo "⌁/AGT/success/i1/fade/observer" ;;
        *)                echo "•/AGT/idle/i1/hold/agent" ;;
    esac
}

ksl_agent_field_slot() {
    local index="${1:-0}"

    case "$index" in
        0) echo "center" ;;
        1) echo "north" ;;
        2) echo "east" ;;
        3) echo "south" ;;
        4) echo "west" ;;
        5) echo "north-east" ;;
        6) echo "south-east" ;;
        7) echo "south-west" ;;
        8) echo "north-west" ;;
        *) echo "orbit-$index" ;;
    esac
}

ksl_agent_field_emit() {
    local name="${1:-agent}"
    local role="${2:-agent}"
    local state="${3:-idle}"
    local index="${4:-1}"

    local signal
    local slot

    signal="$(ksl_agent_field_signal "$role" "$state")"
    slot="$(ksl_agent_field_slot "$index")"

    printf 'FIELD|name=%s|role=%s|state=%s|slot=%s|signal=%s\n' \
        "$name" "$role" "$state" "$slot" "$signal"
}

ksl_agent_field_demo() {
    ksl_agent_field_emit "ray" "gateway" "active" "0"
    ksl_agent_field_emit "router-local" "agent" "active" "1"
    ksl_agent_field_emit "timeline" "agent" "success" "2"
    ksl_agent_field_emit "watcher" "observer" "idle" "3"
}
