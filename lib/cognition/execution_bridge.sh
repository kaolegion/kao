#!/usr/bin/env bash

execution_mode_resolve() {
  local raw
  raw="${EXECUTION_MODE:-auto}"

  case "${raw}" in
    auto|local|cloud)
      printf '%s\n' "${raw}"
      ;;
    *)
      printf 'auto\n'
      ;;
  esac
}

execution_strategy_for_intent() {
  local intent
  intent="${1:-unknown}"

  case "${intent}" in
    file-op)
      printf 'local-exec\n'
      ;;
    system-op)
      printf 'local-inspect\n'
      ;;
    cognitive-heavy)
      printf 'gateway-heavy\n'
      ;;
    cognitive-light)
      printf 'gateway-light\n'
      ;;
    *)
      printf 'unclassified\n'
      ;;
  esac
}

execution_surface_for_strategy() {
  local strategy
  strategy="${1:-unclassified}"

  case "${strategy}" in
    local-exec)
      printf 'shell\n'
      ;;
    local-inspect)
      printf 'system\n'
      ;;
    gateway-heavy|gateway-light)
      printf 'gateway\n'
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_provider_for_strategy() {
  local strategy selected_provider
  strategy="${1:-unclassified}"

  case "${strategy}" in
    gateway-heavy|gateway-light)
      selected_provider="$(gateway_provider_select)"
      printf '%s\n' "${selected_provider}"
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_decision_label() {
  local strategy surface
  strategy="${1:-unclassified}"
  surface="${2:-none}"

  if [ "${strategy}" = "unclassified" ] || [ "${surface}" = "none" ]; then
    printf 'no-execution-bridge\n'
    return 0
  fi

  printf 'routed-execution\n'
}

execution_bridge_operator_surface() {
  local prompt intent route action execution_mode strategy surface provider decision

  prompt="${*:-}"
  intent="$(intent_classify "${prompt}")"
  route="$(intent_route_family "${intent}")"
  action="$(intent_action_label "${intent}")"
  execution_mode="$(execution_mode_resolve)"
  strategy="$(execution_strategy_for_intent "${intent}")"
  surface="$(execution_surface_for_strategy "${strategy}")"
  provider="$(execution_provider_for_strategy "${strategy}")"
  decision="$(execution_decision_label "${strategy}" "${surface}")"

  printf 'EXECUTION BRIDGE\n'
  printf 'prompt         : %s\n' "${prompt}"
  printf 'intent class   : %s\n' "${intent}"
  printf 'route family   : %s\n' "${route}"
  printf 'action         : %s\n' "${action}"
  printf 'execution mode : %s\n' "${execution_mode}"
  printf 'strategy       : %s\n' "${strategy}"
  printf 'surface        : %s\n' "${surface}"
  printf 'provider       : %s\n' "${provider}"
  printf 'decision       : %s\n' "${decision}"
}
