#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
SESSION_DIR="${KROOT}/state/sessions"

kao_session_phase_stats() {

    [ -d "${SESSION_DIR}" ] || {
        echo "NO SESSION HISTORY"
        return 0
    }

    declare -A COUNT

    for dir in "${SESSION_DIR}"/*; do

        [ -d "${dir}" ] || continue

        mem="${dir}/session.memory"
        [ -f "${mem}" ] || continue

        # shellcheck disable=SC1090
        . "${mem}"

        phase="${SESSION_PHASE:-UNKNOWN}"
        COUNT["$phase"]=$(( ${COUNT["$phase"]:-0} + 1 ))

    done

    echo "SESSION STATS"
    echo "-------------"

    for p in "${!COUNT[@]}"; do
        printf "%-12s : %s\n" "$p" "${COUNT[$p]}"
    done
}
