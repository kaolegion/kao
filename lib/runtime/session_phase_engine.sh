#!/usr/bin/env bash

kao_session_phase_compute() {

    local duration="${AGE_SECONDS:-0}"
    local intensity="${FINAL_INTENSITY:-IDLE}"
    local heat="${FINAL_HEAT:-LOW}"

    SESSION_PHASE="EXPLORATORY"

    if [ "${intensity}" = "IDLE" ]; then
        SESSION_PHASE="IDLE"
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

    if [ "${heat}" = "WARM" ] || [ "${heat}" = "LOW" ]; then
        SESSION_PHASE="COOLING"
        return
    fi

    SESSION_PHASE="EXPLORATORY"
}
