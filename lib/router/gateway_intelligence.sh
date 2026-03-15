#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_STATE_FILE="${RUNTIME_DIR}/runtime.state"

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

gateway_intelligence_evaluate() {

    local intent="$1"

    local connectivity
    connectivity="$(gateway_intelligence_detect_connectivity)"

    local level
    level="$(gateway_intelligence_classify_intent "$intent")"

    local provider
    provider="$(gateway_intelligence_select_provider "$connectivity" "$level")"

    gateway_intelligence_emit_runtime_decision "$provider" "$level" "$connectivity"
}
