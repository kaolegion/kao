#!/usr/bin/env bash

router_select_agent() {

    local level="${1:-1}"

    if [ -f state/agents/registry.env ]; then
        source state/agents/registry.env
    fi

    local selected="ORGAN_NATIVE"

    if [ "${level}" -ge 3 ] && [ "${AGENT_CLOUD_EXPERT}" = "ENABLED" ]; then
        selected="AGENT_CLOUD_EXPERT"
    elif [ "${level}" -ge 2 ] && [ "${AGENT_CLOUD_GENERAL}" = "ENABLED" ]; then
        selected="AGENT_CLOUD_GENERAL"
    elif [ "${AGENT_LOCAL_LITE}" = "ENABLED" ]; then
        selected="AGENT_LOCAL_LITE"
    fi

    echo "${selected}" > state/router/router.agent.selected
}
