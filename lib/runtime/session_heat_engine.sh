#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/runtime"
SESSION_CURRENT_FILE="${STATE_DIR}/session.current"
TIMELINE_FILE="${STATE_DIR}/session.timeline"

. "${KROOT}/lib/runtime/event_normalizer.sh"
. "${KROOT}/lib/runtime/ksl_hook.sh"

kao_session_heat_now_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_session_heat_now_epoch() {
    date -u +%s
}

kao_session_heat_read_field() {
    local key="${1:-}"

    [ -n "${key}" ] || return 1
    [ -f "${SESSION_CURRENT_FILE}" ] || return 1

    awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "${SESSION_CURRENT_FILE}"
}

kao_session_heat_upsert_field() {
    local key="${1:-}"
    local value="${2:-}"

    [ -n "${key}" ] || return 1
    mkdir -p "${STATE_DIR}"
    touch "${SESSION_CURRENT_FILE}"

    if grep -q "^${key}=" "${SESSION_CURRENT_FILE}"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "${SESSION_CURRENT_FILE}"
    else
        printf '%s=%s\n' "${key}" "${value}" >> "${SESSION_CURRENT_FILE}"
    fi
}

kao_session_heat_iso_to_epoch() {
    local iso="${1:-}"
    [ -n "${iso}" ] || return 1
    date -u -d "${iso}" +%s 2>/dev/null
}

kao_session_heat_session_id() {
    kao_session_heat_read_field "SESSION_ID" 2>/dev/null || printf 'none\n'
}

kao_session_heat_age_seconds() {
    local started_at started_epoch now_epoch

    started_at="$(kao_session_heat_read_field "SESSION_STARTED_AT" 2>/dev/null || true)"
    [ -n "${started_at}" ] || started_at="$(kao_session_heat_read_field "OPENED_AT" 2>/dev/null || true)"
    [ -n "${started_at}" ] || return 1

    started_epoch="$(kao_session_heat_iso_to_epoch "${started_at}" 2>/dev/null || true)"
    [ -n "${started_epoch}" ] || return 1

    now_epoch="$(kao_session_heat_now_epoch)"
    printf '%s\n' "$((now_epoch - started_epoch))"
}

kao_session_heat_idle_seconds() {
    local last_activity last_epoch now_epoch

    last_activity="$(kao_session_heat_read_field "SESSION_LAST_ACTIVITY_AT" 2>/dev/null || true)"
    [ -n "${last_activity}" ] || return 1

    last_epoch="$(kao_session_heat_iso_to_epoch "${last_activity}" 2>/dev/null || true)"
    [ -n "${last_epoch}" ] || return 1

    now_epoch="$(kao_session_heat_now_epoch)"
    printf '%s\n' "$((now_epoch - last_epoch))"
}

kao_session_heat_compute_level() {
    local idle_seconds="${1:-}"

    case "${idle_seconds}" in
        ''|*[!0-9]*)
            printf 'WARM\n'
            ;;
        *)
            if [ "${idle_seconds}" -le 120 ]; then
                printf 'HOT\n'
            elif [ "${idle_seconds}" -le 900 ]; then
                printf 'WARM\n'
            else
                printf 'COLD\n'
            fi
            ;;
    esac
}

kao_session_heat_compute_memory_class() {
    local heat_level="${1:-WARM}"

    case "${heat_level}" in
        HOT)  printf 'HOT\n' ;;
        WARM) printf 'WARM\n' ;;
        COLD) printf 'COLD\n' ;;
        *)    printf 'WARM\n' ;;
    esac
}

kao_session_heat_rank() {
    local level="${1:-}"

    case "${level}" in
        HOT)  printf '3\n' ;;
        WARM) printf '2\n' ;;
        COLD) printf '1\n' ;;
        *)    printf '0\n' ;;
    esac
}

kao_session_heat_emit_event() {
    local event_type="${1:-unknown}"
    local detail="${2:-none}"
    local ts session_id semantic_line

    mkdir -p "${STATE_DIR}"
    ts="$(kao_session_heat_now_utc)"
    session_id="$(kao_session_heat_session_id)"
    semantic_line="$(kao_event_enrich_detail "${event_type}" "${detail}")"

    printf 'ts=%s|session_id=%s|event_type=%s|detail=%s\n' \
        "${ts}" \
        "${session_id}" \
        "${event_type}" \
        "${semantic_line}" \
        >> "${TIMELINE_FILE}"

    if declare -F kao_runtime_ksl_emit_from_session_event >/dev/null 2>&1; then
        kao_runtime_ksl_emit_from_session_event "${event_type}" "unknown" "${semantic_line}"
    fi
}

kao_session_heat_emit_transition() {
    local previous_heat="${1:-}"
    local new_heat="${2:-}"
    local previous_memory="${3:-}"
    local new_memory="${4:-}"
    local reason="${5:-refresh}"
    local prev_rank new_rank

    prev_rank="$(kao_session_heat_rank "${previous_heat}")"
    new_rank="$(kao_session_heat_rank "${new_heat}")"

    if [ "${prev_rank}" -gt 0 ] && [ "${new_rank}" -gt 0 ] && [ "${new_rank}" -gt "${prev_rank}" ]; then
        kao_session_heat_emit_event \
            "session-heat-rise" \
            "from=${previous_heat};to=${new_heat};reason=${reason};heat_transition=rise"
    fi

    if [ "${prev_rank}" -gt 0 ] && [ "${new_rank}" -gt 0 ] && [ "${new_rank}" -lt "${prev_rank}" ]; then
        kao_session_heat_emit_event \
            "session-heat-fall" \
            "from=${previous_heat};to=${new_heat};reason=${reason};heat_transition=fall"
    fi

    if [ -n "${new_memory}" ] && [ "${previous_memory}" != "${new_memory}" ]; then
        kao_session_heat_emit_event \
            "session-memory-class" \
            "from=${previous_memory:-none};to=${new_memory};reason=${reason};memory_transition=class_update"
    fi
}

kao_session_heat_emit_aging() {
    local reason="${1:-refresh}"
    local age_seconds idle_seconds heat_level memory_class

    age_seconds="$(kao_session_heat_age_seconds 2>/dev/null || true)"
    idle_seconds="$(kao_session_heat_idle_seconds 2>/dev/null || true)"
    heat_level="$(kao_session_heat_read_field "SESSION_HEAT_LEVEL" 2>/dev/null || true)"
    memory_class="$(kao_session_heat_read_field "SESSION_MEMORY_CLASS" 2>/dev/null || true)"

    [ -n "${age_seconds}" ] || age_seconds="unknown"
    [ -n "${idle_seconds}" ] || idle_seconds="unknown"
    [ -n "${heat_level}" ] || heat_level="unknown"
    [ -n "${memory_class}" ] || memory_class="unknown"

    kao_session_heat_emit_event \
        "session-aging" \
        "age_seconds=${age_seconds};idle_seconds=${idle_seconds};heat_level=${heat_level};memory_class=${memory_class};reason=${reason}"
}

kao_session_heat_init() {
    local now previous_heat previous_memory

    now="$(kao_session_heat_now_utc)"
    previous_heat="$(kao_session_heat_read_field "SESSION_HEAT_LEVEL" 2>/dev/null || true)"
    previous_memory="$(kao_session_heat_read_field "SESSION_MEMORY_CLASS" 2>/dev/null || true)"

    kao_session_heat_upsert_field "SESSION_STARTED_AT" "${now}"
    kao_session_heat_upsert_field "SESSION_LAST_ACTIVITY_AT" "${now}"
    kao_session_heat_upsert_field "SESSION_HEAT_LEVEL" "HOT"
    kao_session_heat_upsert_field "SESSION_MEMORY_CLASS" "HOT"

    kao_session_heat_emit_transition "${previous_heat}" "HOT" "${previous_memory}" "HOT" "session_init"
    kao_session_heat_emit_aging "session_init"
}

kao_session_heat_touch() {
    local now previous_heat previous_memory

    now="$(kao_session_heat_now_utc)"
    previous_heat="$(kao_session_heat_read_field "SESSION_HEAT_LEVEL" 2>/dev/null || true)"
    previous_memory="$(kao_session_heat_read_field "SESSION_MEMORY_CLASS" 2>/dev/null || true)"

    kao_session_heat_upsert_field "SESSION_LAST_ACTIVITY_AT" "${now}"
    kao_session_heat_upsert_field "SESSION_HEAT_LEVEL" "HOT"
    kao_session_heat_upsert_field "SESSION_MEMORY_CLASS" "HOT"

    kao_session_heat_emit_transition "${previous_heat}" "HOT" "${previous_memory}" "HOT" "session_touch"
    kao_session_heat_emit_aging "session_touch"
}

kao_session_heat_refresh() {
    local previous_heat previous_memory idle_seconds heat_level memory_class

    previous_heat="$(kao_session_heat_read_field "SESSION_HEAT_LEVEL" 2>/dev/null || true)"
    previous_memory="$(kao_session_heat_read_field "SESSION_MEMORY_CLASS" 2>/dev/null || true)"

    idle_seconds="$(kao_session_heat_idle_seconds 2>/dev/null || true)"
    heat_level="$(kao_session_heat_compute_level "${idle_seconds}")"
    memory_class="$(kao_session_heat_compute_memory_class "${heat_level}")"

    kao_session_heat_upsert_field "SESSION_HEAT_LEVEL" "${heat_level}"
    kao_session_heat_upsert_field "SESSION_MEMORY_CLASS" "${memory_class}"

    kao_session_heat_emit_transition "${previous_heat}" "${heat_level}" "${previous_memory}" "${memory_class}" "session_refresh"
    kao_session_heat_emit_aging "session_refresh"
}

kao_session_heat_close_freeze() {
    kao_session_heat_refresh
}
