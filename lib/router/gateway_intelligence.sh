#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_STATE_FILE="${RUNTIME_DIR}/runtime.state"

source "${KROOT}/lib/router/router_cognitive_state.sh"

gateway_runtime_mode_get() {
    grep '^KAO_RUNTIME_CONNECTIVITY_MODE=' "$RUNTIME_STATE_FILE" 2>/dev/null | cut -d= -f2
}

gateway_intelligence_detect_connectivity() {

    local forced
    forced="$(gateway_runtime_mode_get)"

    case "$forced" in
        offline)
            echo "offline"
            return
            ;;
        online)
            echo "online"
            return
            ;;
    esac

    if ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; then
        echo "online"
    else
        echo "offline"
    fi
}

gateway_intelligence_classify_intent() {
    local intent="$1"

    case "$intent" in
        *open*|*list*|*status*)
            echo "micro"
            ;;
        *video*|*analyse*|*résume*|*summary*)
            echo "expert"
            ;;
        *)
            echo "standard"
            ;;
    esac
}

gateway_intelligence_select_provider() {

    local connectivity="$1"
    local cognitive_level="$2"

    if [ "$connectivity" = "offline" ]; then
        echo "ollama_local"
        return
    fi

    case "$cognitive_level" in
        micro)
            echo "local_fast"
            ;;
        expert)
            echo "cloud_free"
            ;;
        *)
            echo "hybrid_auto"
            ;;
    esac
}

gateway_intelligence_select_agent() {
    local provider="$1"
    local level="$2"

    case "${provider}:${level}" in
        ollama_local:micro)
            echo "ollama_micro"
            ;;
        ollama_local:expert)
            echo "ollama_expert"
            ;;
        ollama_local:standard)
            echo "ollama_standard"
            ;;
        local_fast:micro)
            echo "local_fast"
            ;;
        cloud_free:expert)
            echo "cloud_free"
            ;;
        hybrid_auto:standard)
            echo "hybrid_auto"
            ;;
        *)
            echo "${provider}"
            ;;
    esac
}

gateway_intelligence_router_mode() {
    local connectivity="$1"
    local provider="$2"

    if [ "$connectivity" = "offline" ]; then
        echo "OFFLINE"
        return
    fi

    case "$provider" in
        cloud_free)
            echo "CLOUD"
            ;;
        local_fast)
            echo "LOCAL"
            ;;
        hybrid_auto)
            echo "HYBRID"
            ;;
        ollama_local)
            echo "OFFLINE"
            ;;
        *)
            echo "UNKNOWN"
            ;;
    esac
}

gateway_intelligence_confidence() {
    local level="$1"

    case "$level" in
        micro)
            echo "0.92"
            ;;
        expert)
            echo "0.86"
            ;;
        standard)
            echo "0.75"
            ;;
        *)
            echo "0"
            ;;
    esac
}

gateway_intelligence_latency() {
    local provider="$1"

    case "$provider" in
        local_fast)
            echo "80"
            ;;
        ollama_local)
            echo "140"
            ;;
        cloud_free)
            echo "420"
            ;;
        hybrid_auto)
            echo "220"
            ;;
        *)
            echo "0"
            ;;
    esac
}

gateway_runtime_set_key() {

    local key="$1"
    local value="$2"
    local file="${RUNTIME_STATE_FILE}"
    local tmp

    mkdir -p "${RUNTIME_DIR}"
    touch "${file}"

    tmp="$(mktemp)"
    grep -v "^${key}=" "${file}" > "${tmp}" || true
    printf "%s=%s\n" "${key}" "${value}" >> "${tmp}"
    cat "${tmp}" > "${file}"
    rm -f "${tmp}"
}

gateway_intelligence_emit_runtime_decision() {

    local provider="$1"
    local level="$2"
    local connectivity="$3"

    gateway_runtime_set_key "KAO_GATEWAY_PROVIDER" "${provider}"
    gateway_runtime_set_key "KAO_GATEWAY_COGNITIVE_LEVEL" "${level}"
    gateway_runtime_set_key "KAO_GATEWAY_CONNECTIVITY" "${connectivity}"
}

gateway_intelligence_emit_cognitive_state() {
    local intent="$1"
    local provider="$2"
    local level="$3"
    local connectivity="$4"
    local agent="$5"

    router_state_init
    router_state_write ROUTER_MODE "$(gateway_intelligence_router_mode "$connectivity" "$provider")"
    router_state_write ROUTER_NETWORK "$(printf '%s' "$connectivity" | tr '[:lower:]' '[:upper:]')"
    router_state_write ROUTER_PROVIDER "$(printf '%s' "$provider" | tr '[:lower:]' '[:upper:]')"
    router_state_write ROUTER_AGENT "$(printf '%s' "$agent" | tr '[:lower:]' '[:upper:]')"
    router_state_write ROUTER_INTENT "$intent"
    router_state_write ROUTER_COGNITIVE_LEVEL "$(printf '%s' "$level" | tr '[:lower:]' '[:upper:]')"
    router_state_write ROUTER_CONFIDENCE "$(gateway_intelligence_confidence "$level")"
    router_state_write ROUTER_LATENCY "$(gateway_intelligence_latency "$provider")"
    router_state_health_ok
}

gateway_intelligence_evaluate() {

    local intent="$1"

    local connectivity
    connectivity="$(gateway_intelligence_detect_connectivity)"

    local level
    level="$(gateway_intelligence_classify_intent "$intent")"

    local provider
    provider="$(gateway_intelligence_select_provider "$connectivity" "$level")"

    local agent
    agent="$(gateway_intelligence_select_agent "$provider" "$level")"

    gateway_intelligence_emit_runtime_decision "$provider" "$level" "$connectivity"
    gateway_intelligence_emit_cognitive_state "$intent" "$provider" "$level" "$connectivity" "$agent"
}
