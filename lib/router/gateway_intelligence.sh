#!/usr/bin/env bash

# REKON-GATEWAY-BRIDGE: canonical projection layer from real gateway selection into router cognitive dispatch.
# TODO(REKON): migrate confidence and agent derivation to a shared router-core contract once canonical router-core is declared.
# TODO(REKON-TEST): preserve provider projection, cognitive state write, authority-safe local-first policy, and deterministic decision traces.

KROOT="${KROOT:-/home/kao}"

# shellcheck disable=SC1091
source "${KROOT}/lib/router/router_cognitive_state.sh"
# shellcheck disable=SC1091
source "${KROOT}/lib/gateway/router.sh"

gateway_intelligence_evaluate() {

    local intent provider selected_route route_reason route_score selection_policy
    local selected_kind selected_health confidence agent router_mode

    intent="$*"

    provider="$(gateway_provider_select)"
    selected_route="$(gateway_selected_route)"
    route_reason="$(gateway_route_reason)"
    route_score="$(gateway_route_score)"
    selection_policy="$(gateway_selection_policy)"
    selected_kind="$(gateway_provider_kind "${provider}")"
    selected_health="$(gateway_provider_health "${provider}")"

    case "${provider}" in
        ollama)
            agent="local-reflex"
            ;;
        mistral)
            agent="cloud-expert"
            ;;
        none|*)
            agent="no-provider"
            ;;
    esac

    case "${selected_route}" in
        local) confidence="0.91" ;;
        cloud) confidence="0.76" ;;
        *) confidence="0.00" ;;
    esac

    case "${provider}" in
        ollama)
            router_mode="LOCAL_FIRST"
            ;;
        mistral)
            router_mode="CLOUD_ALLOWED"
            ;;
        *)
            router_mode="NO_PROVIDER"
            ;;
    esac

    GATEWAY_SELECTED_PROVIDER="${provider}"
    GATEWAY_SELECTED_AGENT="${agent}"
    GATEWAY_ROUTE_CONFIDENCE="${confidence}"

    router_state_write ROUTER_MODE "${router_mode}"
    router_state_write ROUTER_PROVIDER "${provider}"
    router_state_write ROUTER_AGENT "${agent}"
    router_state_write ROUTER_INTENT "${intent}"
    router_state_write ROUTER_CONFIDENCE "${confidence}"
    router_state_write ROUTER_SOVEREIGN_STATE "${selection_policy}"

    if [ "${selected_route}" = "local" ]; then
        router_state_write ROUTER_COGNITIVE_LEVEL 1
    elif [ "${selected_route}" = "cloud" ]; then
        router_state_write ROUTER_COGNITIVE_LEVEL 2
    else
        router_state_write ROUTER_COGNITIVE_LEVEL 0
    fi

    if [ "${provider}" = "ollama" ]; then
        router_state_write ROUTER_NETWORK "LOCAL"
    elif [ "${provider}" = "mistral" ]; then
        router_state_write ROUTER_NETWORK "ONLINE"
    else
        router_state_write ROUTER_NETWORK "UNKNOWN"
    fi

    if [ "${selected_health}" = "ready" ] || [ "${selected_health}" = "local-real-ready" ] || [ "${selected_health}" = "local-real-backend-ready" ] || [ "${selected_health}" = "local-stub-ready" ]; then
        router_state_health_ok
    fi

    echo "[KAO][REKON][GATEWAY] provider=${provider} route=${selected_route} score=${route_score} reason=${route_reason} kind=${selected_kind} health=${selected_health} policy=${selection_policy}"
}
