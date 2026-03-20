#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/runtime"
TIMELINE_FILE="${STATE_DIR}/session.timeline"

. "${KROOT}/lib/runtime/event_normalizer.sh"
. "${KROOT}/lib/runtime/ksl_hook.sh"
. "${KROOT}/lib/runtime/session_heat_engine.sh"
. "${KROOT}/lib/runtime/live_capture.sh"

kao_session_emit() {
    local event_type detail semantic_line ts session_id

    event_type="${1:-unknown}"
    detail="${2:-none}"

    ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    if [ -f "${STATE_DIR}/session.current" ]; then
        session_id="$(grep '^SESSION_ID=' "${STATE_DIR}/session.current" | cut -d= -f2)"
    else
        session_id="none"
    fi

    semantic_line="$(kao_event_enrich_detail "${event_type}" "${detail}")"

    printf 'ts=%s|session_id=%s|event_type=%s|detail=%s\n' \
        "${ts}" \
        "${session_id}" \
        "${event_type}" \
        "${semantic_line}" \
        >> "${TIMELINE_FILE}"

    kao_runtime_ksl_emit_from_session_event "${event_type}" "unknown" "${semantic_line}"
}

kao_session_touch() {
    if [ -f "${STATE_DIR}/session.current" ]; then
        kao_session_heat_touch
    fi

    kao_session_emit "session-touch" "operator_interaction"
}

kao_session_open() {

    if [ -f "${STATE_DIR}/session.current" ]; then
        return 0
    fi

    local session_id ts

    ts="$(date -u +"%Y%m%d-%H%M%S")"
    session_id="session-${ts}-$$"

    mkdir -p "${STATE_DIR}"

    cat > "${STATE_DIR}/session.current" <<EOT
SESSION_ID=${session_id}
OPENED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOT

    kao_session_heat_init
    kao_session_emit "session-open" "runtime_session_started"
    kao_live_capture_session_open "runtime_session_started"
}

kao_session_close() {

    if [ ! -f "${STATE_DIR}/session.current" ]; then
        return 0
    fi

    kao_session_heat_close_freeze
    kao_session_emit "session-close" "runtime_session_closed"
    kao_live_capture_session_close "runtime_session_closed"
    . "${KROOT}/lib/runtime/session_memory_writer.sh"
    kao_session_memory_write

    rm -f "${STATE_DIR}/session.current"
}

kao_session_signal_cognitive() {
    local reason="${1:-cognitive_activity}"
    "${KROOT}/lib/runtime/live_capture.sh" capture COGNITIVE_EVENT "${reason}"
}


kao_session_emit_cognitive() {
    local detail="${1:-cognitive_activity}"
    kao_session_heat_touch
    kao_session_emit "cognitive-event" "${detail}"
}

