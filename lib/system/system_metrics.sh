#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/runtime"

kao_metrics_now_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_metrics_loadavg() {
    awk '{print $1" "$2" "$3}' /proc/loadavg
}

kao_metrics_mem_total_mb() {
    awk '/MemTotal:/ {printf "%.0f\n", $2/1024}' /proc/meminfo
}

kao_metrics_mem_available_mb() {
    awk '/MemAvailable:/ {printf "%.0f\n", $2/1024}' /proc/meminfo
}

kao_metrics_root_disk_use() {
    df -h / | awk 'NR==2 {print $5" used of "$2}'
}

kao_metrics_uptime_seconds() {
    awk '{printf "%.0f\n", $1}' /proc/uptime
}

kao_metrics_default_route() {
    if ip route show default 2>/dev/null | grep -q '^default'; then
        echo "present"
    else
        echo "absent"
    fi
}

kao_metrics_session_id() {
    if [ -f "${STATE_DIR}/session.current" ]; then
        awk -F= '$1=="SESSION_ID" {print $2}' "${STATE_DIR}/session.current"
    else
        echo "none"
    fi
}

kao_metrics_markdown_count() {
    find "${KROOT}" -name "*.md" | wc -l | awk '{print $1}'
}

kao_metrics_print() {
    printf 'KAO METRICS BASELINE\n'
    printf '%s\n' '--------------------'
    printf 'captured_at         : %s\n' "$(kao_metrics_now_utc)"
    printf 'host                : %s\n' "$(hostname)"
    printf 'kernel              : %s\n' "$(uname -r)"
    printf 'uptime_seconds      : %s\n' "$(kao_metrics_uptime_seconds)"
    printf 'loadavg_1_5_15      : %s\n' "$(kao_metrics_loadavg)"
    printf 'mem_total_mb        : %s\n' "$(kao_metrics_mem_total_mb)"
    printf 'mem_available_mb    : %s\n' "$(kao_metrics_mem_available_mb)"
    printf 'root_disk_use       : %s\n' "$(kao_metrics_root_disk_use)"
    printf 'default_route       : %s\n' "$(kao_metrics_default_route)"
    printf 'active_session      : %s\n' "$(kao_metrics_session_id)"
    printf 'markdown_docs       : %s\n' "$(kao_metrics_markdown_count)"
}
