#!/usr/bin/env bash

source /home/kao/lib/ksl/ksl_engine.sh

kao_runtime_ksl_emit() {
  local event="$1"
  kao_runtime_emit_event "$event"
}

kao_runtime_ksl_emit_if_mapped() {
  local event="$1"
  local signal

  signal="$(kao_signal_resolve "$event")"
  if [ -n "$signal" ]; then
    kao_runtime_emit_event "$event"
    return 0
  fi

  return 1
}

kao_runtime_ksl_detail_action() {
  local raw_detail="${1:-}"
  printf '%s\n' "${raw_detail}" | tr ';' '\n' | awk -F= '$1 == "action" { print $2; exit }'
}

kao_runtime_ksl_emit_if_state_differs() {
  local key="${1:-}"
  local expected="${2:-}"
  local event="${3:-}"
  local current

  current="$(kao_ksl_get_state "${key}" "__unset__")"
  if [ "${current}" != "${expected}" ]; then
    kao_runtime_ksl_emit_if_mapped "${event}" || true
  fi
}

kao_runtime_ksl_emit_provider_route() {
  local provider="${1:-unknown}"

  case "${provider}" in
    mistral|openrouter|cloud|gateway-cloud)
      kao_runtime_ksl_emit_if_state_differs "NET" "online" "network.online"
      kao_runtime_ksl_emit_if_state_differs "ROUTER" "cloud" "router.cloud_selected"
      ;;
    ollama|local|local-shell|gateway-local)
      kao_runtime_ksl_emit_if_state_differs "ROUTER" "local" "router.local_selected"
      ;;
    *)
      return 0
      ;;
  esac
}

kao_runtime_ksl_emit_from_session_event() {
  local event_type="${1:-unknown}"
  local provider="${2:-unknown}"
  local raw_detail="${3:-}"
  local action

  action="$(kao_runtime_ksl_detail_action "${raw_detail}")"

  case "${event_type}" in
    session-open)
      kao_runtime_ksl_emit_if_mapped "session.start" || true
      kao_runtime_ksl_emit_provider_route "${provider}"
      ;;
    session-touch)
      case "${action}" in
        operator-status|operator-registry|operator-scout|operator-system-inspect|operator-session-open)
          kao_runtime_ksl_emit_if_mapped "session.steady" || true
          kao_runtime_ksl_emit_provider_route "${provider}"
          ;;
        execution-gateway)
          kao_runtime_ksl_emit_provider_route "${provider}"
          kao_runtime_ksl_emit_if_state_differs "AGENT_STATE" "running" "agent.active"
          kao_runtime_ksl_emit_if_state_differs "MEMORY" "hot" "memory.hot"
          ;;
        execution-local-shell|execution-local-script|execution-local-binary)
          kao_runtime_ksl_emit_provider_route "${provider}"
          kao_runtime_ksl_emit_if_state_differs "AGENT_STATE" "running" "agent.active"
          ;;
        *)
          kao_runtime_ksl_emit_provider_route "${provider}"
          ;;
      esac
      ;;
    session-close)
      kao_runtime_ksl_emit_if_mapped "agent.done" || true
      kao_runtime_ksl_emit_if_mapped "session.end" || true
      ;;
  esac
}
