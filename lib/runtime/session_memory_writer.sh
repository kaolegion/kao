#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/runtime"
SESSION_DIR="${KROOT}/state/sessions"
. "${KROOT}/lib/runtime/session_phase_engine.sh"

. "${KROOT}/lib/runtime/session_heat_engine.sh"
. "${KROOT}/lib/runtime/session_cognitive_state.sh"

kao_session_memory_write() {

    [ -f "${STATE_DIR}/session.current" ] || return 0

    session_id="$(kao_session_heat_session_id)"
    age="$(kao_session_heat_age_seconds 2>/dev/null || echo unknown)"
    heat="$(kao_session_heat_read_field SESSION_HEAT_LEVEL)"
    memory="$(kao_session_heat_read_field SESSION_MEMORY_CLASS)"
    intensity="$(kao_session_cognitive_intensity)"
    closed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    target_dir="${SESSION_DIR}/${session_id}"
    mkdir -p "${target_dir}"


    AGE_SECONDS="${age}"
    FINAL_INTENSITY="${intensity}"
    FINAL_HEAT="${heat}"

    kao_session_phase_compute

    cat > "${target_dir}/session.memory" <<EOT
SESSION_ID=${session_id}
CLOSED_AT=${closed_at}
AGE_SECONDS=${age}
FINAL_HEAT=${heat}
FINAL_MEMORY_CLASS=${memory}
FINAL_INTENSITY=${intensity}
SESSION_PHASE=${SESSION_PHASE}
SESSION_COGNITIVE_LOAD=${SESSION_COGNITIVE_LOAD:-0}
EOT

}
