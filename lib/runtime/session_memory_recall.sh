#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
SESSION_DIR="${KROOT}/state/sessions"

. "${KROOT}/lib/runtime/session_summary_engine.sh"

kao_session_memory_recall() {

    local mode="${1:-raw}"
    local last_session mem_file

    [ -d "${SESSION_DIR}" ] || {
        echo "NO SESSION MEMORY"
        return 0
    }

    last_session="$(find "${SESSION_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -n 1)"

    [ -n "${last_session}" ] || {
        echo "NO SESSION MEMORY"
        return 0
    }

    mem_file="${SESSION_DIR}/${last_session}/session.memory"

    [ -f "${mem_file}" ] || {
        echo "NO MEMORY FILE"
        return 0
    }

    if [ "${mode}" = "--summary" ]; then
        kao_session_summary_render "${mem_file}"
        return 0
    fi

    echo "SESSION RECALL"
    echo "--------------"
    cat "${mem_file}"
}
