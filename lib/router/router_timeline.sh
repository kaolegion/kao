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
grep '^SESSION_ID=' "${SESSION_CURRENT_FILE}" 2>/dev/null | cut -d= -f2
}

router_timeline_state_value() {
grep "^$1=" "${ROUTER_STATE_FILE}" 2>/dev/null | cut -d= -f2-
}

router_timeline_append_dispatch() {

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

printf '%s\n' \
"ts=${ts}|session_id=${session_id}|event_type=router-dispatch|gateway_agent=gateway-router|agent=${agent}|selected_provider=${provider}|provider_kind=${mode}|network_state=${network}|cognitive_level=${level}|intent_class=$*|route_confidence=${confidence}|route_latency=${latency}" \
>> "${TIMELINE_FILE}"

}
