#!/usr/bin/env bash

KSL_TIMELINE_FILE="/home/kao/state/runtime/session.timeline"

ksl_dashboard_header() {
    printf "KSL DASHBOARD\n"
    printf "=============\n"
}

ksl_dashboard_timeline_preview() {
    printf "\n[TEMPORAL WINDOW]\n"

    if [ -f "/home/kao/lib/ksl/nav/ksl_temporal_nav.sh" ]; then
        . /home/kao/lib/ksl/nav/ksl_temporal_nav.sh
        ksl_timeline_focus_window
        printf "\n"
        ksl_timeline_status_line
    elif [ -f "$KSL_TIMELINE_FILE" ]; then
        tail -n 8 "$KSL_TIMELINE_FILE"
    else
        printf "no timeline data\n"
    fi
}

ksl_dashboard_agent_field_dynamic() {
    . /home/kao/lib/ksl/nav/ksl_temporal_nav.sh
    . /home/kao/lib/ksl/ksl_agent_field.sh

    local total
    local phase

    total="$(ksl_timeline_count)"
    phase="present"

    if [ "$total" -le 0 ]; then
        phase="present"
    elif [ "$KSL_TEMPORAL_CURSOR" -lt $((total / 3)) ]; then
        phase="past"
    elif [ "$KSL_TEMPORAL_CURSOR" -gt $(((total * 2) / 3)) ]; then
        phase="future"
    fi

    printf "\n[AGENT FIELD — %s]\n" "$phase"

    case "$phase" in
        past)
            ksl_agent_field_emit "ray" "gateway" "success" "0"
            ksl_agent_field_emit "router-local" "agent" "idle" "1"
            ksl_agent_field_emit "timeline" "agent" "idle" "2"
            ksl_agent_field_emit "watcher" "observer" "idle" "3"
            ;;
        present)
            ksl_agent_field_emit "ray" "gateway" "active" "0"
            ksl_agent_field_emit "router-local" "agent" "active" "1"
            ksl_agent_field_emit "timeline" "agent" "success" "2"
            ksl_agent_field_emit "watcher" "observer" "idle" "3"
            ;;
        future)
            ksl_agent_field_emit "ray" "gateway" "fallback" "0"
            ksl_agent_field_emit "router-local" "agent" "active" "1"
            ksl_agent_field_emit "timeline" "agent" "active" "2"
            ksl_agent_field_emit "watcher" "observer" "active" "3"
            ;;
    esac
}

ksl_dashboard_projection() {
    printf "\n[PROJECTION]\n"

    if [ -f "/home/kao/lib/ksl/nav/ksl_temporal_nav.sh" ]; then
        . /home/kao/lib/ksl/nav/ksl_temporal_nav.sh
        ksl_timeline_projection
    else
        printf "projection unavailable\n"
    fi
}

ksl_dashboard_controls() {
    printf "\n[CONTROLS]\n"
    printf "a=prev  d=next  0=start  $=end  q=quit\n"
}

ksl_dashboard_render() {
    clear
    ksl_dashboard_header
    ksl_dashboard_timeline_preview
    ksl_dashboard_agent_field_dynamic
    ksl_dashboard_projection
    ksl_dashboard_controls
}

ksl_dashboard_loop() {
    . /home/kao/lib/ksl/nav/ksl_temporal_nav.sh

    while true; do
        ksl_dashboard_render
        printf "\ncommand> "
        read -rsn1 key

        case "$key" in
            a) ksl_timeline_step_prev ;;
            d) ksl_timeline_step_next ;;
            0) ksl_timeline_jump_start ;;
            '$') ksl_timeline_jump_end ;;
            q) break ;;
        esac
    done
}
