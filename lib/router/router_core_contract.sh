#!/usr/bin/env bash
# REKON-CANONICAL-CANDIDATE: explicit router-core contract stage V0
# TODO(SENTINEL): keep contract side-effect free.
# TODO(SYFER): define stable boundary cognition → gateway.
# TODO(AVA): keep operator-readable routing decision surface.

router_core_contract_build() {
  local query="$1"

  ROUTER_CORE_STATUS="ok"
  ROUTER_CORE_INTENT="unknown"
  ROUTER_CORE_ROUTE_FAMILY="undetermined"
  ROUTER_CORE_DECISION="gateway-llm"
  ROUTER_CORE_NEXT="gateway"
  ROUTER_CORE_REASON="default-escalation"

  if echo "$query" | grep -qiE 'qui es[- ]?tu|who are you'; then
    ROUTER_CORE_DECISION="self"
    ROUTER_CORE_NEXT="stop"
    ROUTER_CORE_REASON="self-answer-eligible"
  elif echo "$query" | grep -qiE 'ouvre|open|file|fichier'; then
    ROUTER_CORE_DECISION="local-agent"
    ROUTER_CORE_NEXT="dispatch"
    ROUTER_CORE_REASON="local-operator-route"
  else
    ROUTER_CORE_DECISION="gateway-llm"
    ROUTER_CORE_NEXT="gateway"
    ROUTER_CORE_REASON="llm-route"
  fi

  export ROUTER_CORE_STATUS
  export ROUTER_CORE_DECISION
  export ROUTER_CORE_NEXT
  export ROUTER_CORE_REASON
}
