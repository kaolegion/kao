#!/usr/bin/env bash

# ========================================
# KSL TEMPORAL NAVIGATION ENGINE
# ========================================

KSL_TIMELINE_FILE="/home/kao/state/runtime/session.timeline"
KSL_TEMPORAL_CURSOR="${KSL_TEMPORAL_CURSOR:-0}"
KSL_TEMPORAL_WINDOW="${KSL_TEMPORAL_WINDOW:-5}"

ksl_timeline_seek() {
    local ts="$1"
    grep "$ts" "$KSL_TIMELINE_FILE"
}

ksl_timeline_window() {
    local from="$1"
    local to="$2"
    awk -v f="$from" -v t="$to" '
        $0 >= f && $0 <= t
    ' "$KSL_TIMELINE_FILE"
}

ksl_timeline_projection() {
    echo "KSL::⌁/SYS/projection/i1/pulse-future/timeline"
}

ksl_timeline_count() {
    if [ -f "$KSL_TIMELINE_FILE" ]; then
        wc -l < "$KSL_TIMELINE_FILE" | tr -d ' '
    else
        echo 0
    fi
}

ksl_timeline_cursor_normalize() {
    local total
    total="$(ksl_timeline_count)"

    if [ "$total" -le 0 ]; then
        KSL_TEMPORAL_CURSOR=0
        return
    fi

    if [ "$KSL_TEMPORAL_CURSOR" -lt 0 ]; then
        KSL_TEMPORAL_CURSOR=0
    fi

    if [ "$KSL_TEMPORAL_CURSOR" -ge "$total" ]; then
        KSL_TEMPORAL_CURSOR=$((total - 1))
    fi
}

ksl_timeline_cursor_set() {
    KSL_TEMPORAL_CURSOR="${1:-0}"
    ksl_timeline_cursor_normalize
}

ksl_timeline_step_prev() {
    KSL_TEMPORAL_CURSOR=$((KSL_TEMPORAL_CURSOR - 1))
    ksl_timeline_cursor_normalize
}

ksl_timeline_step_next() {
    KSL_TEMPORAL_CURSOR=$((KSL_TEMPORAL_CURSOR + 1))
    ksl_timeline_cursor_normalize
}

ksl_timeline_jump_start() {
    KSL_TEMPORAL_CURSOR=0
    ksl_timeline_cursor_normalize
}

ksl_timeline_jump_end() {
    local total
    total="$(ksl_timeline_count)"

    if [ "$total" -le 0 ]; then
        KSL_TEMPORAL_CURSOR=0
    else
        KSL_TEMPORAL_CURSOR=$((total - 1))
    fi
}

ksl_timeline_focus_window() {
    local total
    local start
    local end

    total="$(ksl_timeline_count)"

    if [ "$total" -le 0 ]; then
        return 0
    fi

    start=$((KSL_TEMPORAL_CURSOR - KSL_TEMPORAL_WINDOW / 2))
    end=$((start + KSL_TEMPORAL_WINDOW - 1))

    if [ "$start" -lt 0 ]; then
        start=0
        end=$((KSL_TEMPORAL_WINDOW - 1))
    fi

    if [ "$end" -ge "$total" ]; then
        end=$((total - 1))
        start=$((end - KSL_TEMPORAL_WINDOW + 1))
        if [ "$start" -lt 0 ]; then
            start=0
        fi
    fi

    awk -v s="$start" -v e="$end" -v c="$KSL_TEMPORAL_CURSOR" '
        NR >= s + 1 && NR <= e + 1 {
            prefix = (NR - 1 == c) ? ">> " : "   "
            print prefix $0
        }
    ' "$KSL_TIMELINE_FILE"
}

ksl_timeline_status_line() {
    local total
    total="$(ksl_timeline_count)"
    printf "cursor=%s window=%s total=%s\n" \
        "$KSL_TEMPORAL_CURSOR" \
        "$KSL_TEMPORAL_WINDOW" \
        "$total"
}
