#!/usr/bin/env bash

router_intent_probe() {

    local intent="${1:-unknown}"

    if command -v router_dispatch >/dev/null 2>&1; then
        router_dispatch "${intent}" >/dev/null 2>&1 || true
    fi

}
