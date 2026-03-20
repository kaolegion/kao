#!/usr/bin/env bash

KAO_ROOT="${KAO_ROOT:-/home/kao}"
POLICY_FILE="${KAO_ROOT}/config/authority_policy.env"

kao_authority_validate_provider() {

    local proposed="${1:-none}"
    local fallback=""

    if [ -f "${POLICY_FILE}" ]; then
        fallback="$(grep '^FALLBACK_PROVIDER=' "${POLICY_FILE}" | cut -d= -f2)"
    fi

    if [ -z "${fallback}" ]; then
        printf '%s\n' "${proposed}"
        return 0
    fi

    case "${proposed}" in
        forbidden)
            printf '%s\n' "${fallback}"
            return 0
            ;;
    esac

    printf '%s\n' "${proposed}"
}
