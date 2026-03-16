#!/usr/bin/env bash

kao_session_summary_render() {

source "${KROOT}/lib/runtime/session_phase_engine.sh"
    local mem_file="$1"

    [ -f "${mem_file}" ] || {
        echo "NO SESSION MEMORY"
        return 1
    }

    # shellcheck disable=SC1090
    . "${mem_file}"

    kao_session_phase_compute


    local interpretation state_line

    case "${FINAL_INTENSITY}" in
        HIGH)
            state_line="Session ended in active cognitive state."
            ;;
        MEDIUM)
            state_line="Session cooled but remained cognitively engaged."
            ;;
        LOW)
            state_line="Session was warm but low activity."
            ;;
        *)
            state_line="Session ended idle."
            ;;
    esac

    echo "SESSION SUMMARY"
    echo "---------------"
    echo "Session lasted ${AGE_SECONDS} seconds."
    echo "Session phase was ${SESSION_PHASE}."
    echo "Cognitive heat remained ${FINAL_HEAT}."
    echo "Memory class remained ${FINAL_MEMORY_CLASS}."
    echo "Final intensity was ${FINAL_INTENSITY}."
    echo "${state_line}"
}
