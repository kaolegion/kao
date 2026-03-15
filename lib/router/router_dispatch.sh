#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/router/gateway_intelligence.sh"

router_dispatch() {

    local intent="$*"

    # --- cognitive gateway evaluation ---
    gateway_intelligence_evaluate "$intent"

    # --- legacy router behaviour continues below ---
    echo "ROUTER DISPATCH (legacy execution)"
}

