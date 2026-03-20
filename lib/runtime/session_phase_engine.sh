#!/usr/bin/env bash

kao_session_phase_compute() {

    local duration="${AGE_SECONDS:-0}"
    local intensity="${FINAL_INTENSITY:-IDLE}"
    local heat="${FINAL_HEAT:-LOW}"
    local cognitive_load="${SESSION_COGNITIVE_LOAD:-0}"

    SESSION_PHASE="EXPLORATORY"

    case "${duration}" in
        ''|*[!0-9]*) duration=0 ;;
    esac

    case "${cognitive_load}" in
        ''|*[!0-9]*) cognitive_load=0 ;;
    esac

    if [ "${intensity}" = "IDLE" ] && [ "${cognitive_load}" -eq 0 ]; then
        SESSION_PHASE="IDLE"
        return
    fi

    if [ "${cognitive_load}" -ge 3 ]; then
        SESSION_PHASE="INTENSIVE"
        return
    fi

    if [ "${duration}" -lt 10 ]; then
        SESSION_PHASE="EXPLORATORY"
        return
    fi

    if [ "${intensity}" = "HIGH" ]; then
        SESSION_PHASE="INTENSIVE"
        return
    fi

    if [ "${heat}" = "WARM" ] || [ "${heat}" = "LOW" ] || [ "${heat}" = "COLD" ]; then
        SESSION_PHASE="COOLING"
        return
    fi

    SESSION_PHASE="EXPLORATORY"
}
