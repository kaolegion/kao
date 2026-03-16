#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
SESSION_DIR="${KROOT}/state/sessions"

kao_session_phase_history() {

    [ -d "${SESSION_DIR}" ] || {
        echo "NO SESSION HISTORY"
        return 0
    }

    echo "SESSION HISTORY"
    echo "---------------"

    find "${SESSION_DIR}" -mindepth 1 -maxdepth 1 -type d \
    | sort \
    | while read -r dir; do

        mem="${dir}/session.memory"

        [ -f "${mem}" ] || continue

        # shellcheck disable=SC1090
        . "${mem}"

        printf "%s %s\n" "${SESSION_ID}" "${SESSION_PHASE:-UNKNOWN}"

    done
}
