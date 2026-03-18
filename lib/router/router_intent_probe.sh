#!/usr/bin/env bash

router_intent_probe() {

    local intent="${1:-unknown}"
    local level="1"

    if command -v router_dispatch >/dev/null 2>&1; then
        source "${KROOT}/lib/router/router_agent_selector.sh" 2>/dev/null || true

        if [ -f state/router/router.cognitive.state ]; then
            level="$(grep '^ROUTER_COGNITIVE_LEVEL=' state/router/router.cognitive.state | cut -d= -f2)"
        fi

        router_select_agent "${level}"
        router_dispatch "${intent}" >/dev/null 2>&1 || true
    fi

}
