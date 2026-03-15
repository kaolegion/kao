#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
STATE_DIR="${KROOT}/state/router"
HEAT_FILE="${STATE_DIR}/router.heat.memory"

router_heat_init() {
    mkdir -p "${STATE_DIR}"
    touch "${HEAT_FILE}"
}

router_heat_decay_apply() {
    local now tmp provider score ts age decay new_score

    router_heat_init
    now="$(date +%s)"
    tmp="$(mktemp)"

    while IFS='|' read -r provider score ts; do
        [ -z "${provider}" ] && continue
        [ -z "${score}" ] && continue
        [ -z "${ts}" ] && continue

        age=$(( now - ts ))
        if [ "${age}" -lt 0 ]; then
            age=0
        fi

        decay="$(awk "BEGIN {print exp(-${age}/600)}")"
        new_score="$(awk "BEGIN {print ${score} * ${decay}}")"

        printf '%s|%s|%s\n' "${provider}" "${new_score}" "${now}" >> "${tmp}"
    done < "${HEAT_FILE}"

    mv "${tmp}" "${HEAT_FILE}"
}

router_heat_add_event() {
    local provider now tmp found p s t new_score

    provider="$1"
    [ -z "${provider}" ] && return 1
    [ "${provider}" = "unknown" ] && return 1

    router_heat_decay_apply

    now="$(date +%s)"
    tmp="$(mktemp)"
    found=0

    while IFS='|' read -r p s t; do
        [ -z "${p}" ] && continue

        if [ "${p}" = "${provider}" ]; then
            new_score="$(awk "BEGIN {print ${s} + 1}")"
            printf '%s|%s|%s\n' "${provider}" "${new_score}" "${now}" >> "${tmp}"
            found=1
        else
            printf '%s|%s|%s\n' "${p}" "${s}" "${t}" >> "${tmp}"
        fi
    done < "${HEAT_FILE}"

    if [ "${found}" -eq 0 ]; then
        printf '%s|1|%s\n' "${provider}" "${now}" >> "${tmp}"
    fi

    mv "${tmp}" "${HEAT_FILE}"
}

router_heat_score_get() {
    router_heat_decay_apply
    cat "${HEAT_FILE}"
}
