#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
TIMELINE_FILE="${RUNTIME_DIR}/session.timeline"
SESSION_CURRENT_FILE="${RUNTIME_DIR}/session.current"
ROUTER_STATE_FILE="${KROOT}/state/router/router.cognitive.state"

router_timeline_now() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

router_timeline_session_id() {
    if [ -f "${SESSION_CURRENT_FILE}" ]; then
        grep '^SESSION_ID=' "${SESSION_CURRENT_FILE}" 2>/dev/null | cut -d= -f2
    else
        echo "no-session"
    fi
}

router_timeline_state_value() {
    local key="$1"
    if [ -f "${ROUTER_STATE_FILE}" ]; then
        grep "^${key}=" "${ROUTER_STATE_FILE}" 2>/dev/null | cut -d= -f2-
    fi
}

router_timeline_last_dispatch() {
    if [ -f "${TIMELINE_FILE}" ]; then
        grep "event_type=router-dispatch" "${TIMELINE_FILE}" | tail -n 1
    fi
}

router_timeline_extract_field() {
    local line="$1"
    local field="$2"
    printf '%s\n' "$line" | tr '|' '\n' | grep "^${field}=" | tail -n 1 | cut -d= -f2-
}

router_timeline_switch_flags() {
    local last_line="$1"
    local provider="$2"
    local level="$3"
    local mode="$4"

    local last_provider last_level last_mode
    local provider_switch level_switch mode_switch

    last_provider="$(router_timeline_extract_field "$last_line" "selected_provider")"
    last_level="$(router_timeline_extract_field "$last_line" "cognitive_level")"
    last_mode="$(router_timeline_extract_field "$last_line" "provider_kind")"

    provider_switch="no"
    level_switch="no"
    mode_switch="no"

    [ -n "$last_provider" ] && [ "$last_provider" != "$provider" ] && provider_switch="yes"
    [ -n "$last_level" ] && [ "$last_level" != "$level" ] && level_switch="yes"
    [ -n "$last_mode" ] && [ "$last_mode" != "$mode" ] && mode_switch="yes"

    printf '%s|%s|%s\n' "$provider_switch" "$level_switch" "$mode_switch"
}

router_timeline_append_dispatch() {
    local intent="$1"
    local ts session_id provider level mode network agent confidence latency
    local last_line switch_flags provider_switch level_switch mode_switch

    mkdir -p "${RUNTIME_DIR}"
    touch "${TIMELINE_FILE}"

    ts="$(router_timeline_now)"
    session_id="$(router_timeline_session_id)"
    provider="$(router_timeline_state_value ROUTER_PROVIDER)"
    level="$(router_timeline_state_value ROUTER_COGNITIVE_LEVEL)"
    mode="$(router_timeline_state_value ROUTER_MODE)"
    network="$(router_timeline_state_value ROUTER_NETWORK)"
    agent="$(router_timeline_state_value ROUTER_AGENT)"
    confidence="$(router_timeline_state_value ROUTER_CONFIDENCE)"
    latency="$(router_timeline_state_value ROUTER_LATENCY)"

    last_line="$(router_timeline_last_dispatch)"
    switch_flags="$(router_timeline_switch_flags "$last_line" "${provider:-unknown}" "${level:-unknown}" "${mode:-unknown}")"
    provider_switch="$(printf '%s' "$switch_flags" | cut -d'|' -f1)"
    level_switch="$(printf '%s' "$switch_flags" | cut -d'|' -f2)"
    mode_switch="$(printf '%s' "$switch_flags" | cut -d'|' -f3)"

    printf '%s\n' \
"ts=${ts}|session_id=${session_id:-no-session}|event_type=router-dispatch|gateway_agent=gateway-router|agent=${agent:-unknown}|selected_provider=${provider:-unknown}|provider_kind=${mode:-unknown}|network_state=${network:-unknown}|cognitive_level=${level:-unknown}|intent_class=${intent}|route_confidence=${confidence:-0}|route_latency=${latency:-0}|provider_switch=${provider_switch}|level_switch=${level_switch}|mode_switch=${mode_switch}" \
>> "${TIMELINE_FILE}"
}
