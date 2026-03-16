#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/runtime"

. "${KROOT}/lib/runtime/session_heat_engine.sh"

kao_session_cognitive_intensity() {

    local idle heat

    idle="$(kao_session_heat_idle_seconds 2>/dev/null || echo 0)"
    heat="$(kao_session_heat_read_field SESSION_HEAT_LEVEL 2>/dev/null || echo WARM)"

    if [ "${heat}" = "HOT" ] && [ "${idle}" -lt 60 ]; then
        echo "HIGH"
    elif [ "${heat}" = "HOT" ]; then
        echo "MEDIUM"
    elif [ "${heat}" = "WARM" ]; then
        echo "LOW"
    else
        echo "IDLE"
    fi
}

kao_session_cognitive_state() {

    local age heat memory intensity

    age="$(kao_session_heat_age_seconds 2>/dev/null || echo unknown)"
    heat="$(kao_session_heat_read_field SESSION_HEAT_LEVEL 2>/dev/null || echo unknown)"
    memory="$(kao_session_heat_read_field SESSION_MEMORY_CLASS 2>/dev/null || echo unknown)"
    intensity="$(kao_session_cognitive_intensity)"

    echo "SESSION COGNITIVE STATE"
    echo "age_seconds : ${age}"
    echo "heat_level  : ${heat}"
    echo "memory      : ${memory}"
    echo "intensity   : ${intensity}"
}

