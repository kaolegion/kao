#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
SESSION_DIR="${KROOT}/state/sessions"

kao_session_behavior_insight() {

    [ -d "${SESSION_DIR}" ] || {
        echo "NO SESSION HISTORY"
        return 0
    }

    declare -A COUNT
    total=0

    for dir in "${SESSION_DIR}"/*; do
        [ -d "${dir}" ] || continue

        mem="${dir}/session.memory"
        [ -f "${mem}" ] || continue

        . "${mem}"

        phase="${SESSION_PHASE:-UNKNOWN}"
        COUNT["$phase"]=$(( ${COUNT["$phase"]:-0} + 1 ))
        total=$(( total + 1 ))
    done

    dominant=""
    max=0

    for p in "${!COUNT[@]}"; do
        if [ "${COUNT[$p]}" -gt "${max}" ]; then
            max="${COUNT[$p]}"
            dominant="${p}"
        fi
    done

    echo "SESSION INSIGHT"
    echo "---------------"

    case "${dominant}" in
        INTENSIVE)
            echo "Behavior trend: focused cognition."
            ;;
        EXPLORATORY)
            echo "Behavior trend: discovery phase."
            ;;
        IDLE)
            echo "Behavior trend: low operator activity."
            ;;
        UNKNOWN)
            echo "Behavior trend: early memory stage."
            ;;
        *)
            echo "Behavior trend: mixed cognitive activity."
            ;;
    esac

    echo "Total sessions observed: ${total}."
}
