#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/router/gateway_intelligence.sh"
source "${KROOT}/lib/router/router_timeline.sh"

router_dispatch() {

    local intent="$*"

    # --- cognitive gateway evaluation ---
    gateway_intelligence_evaluate "$intent"

    # --- timeline trace ---
    router_timeline_append_dispatch "$intent"

    # --- legacy router behaviour continues below ---
    echo "ROUTER DISPATCH (legacy execution)"
}
