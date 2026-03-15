#!/usr/bin/env bash

kao_event_taxonomy_file() {
  printf '%s/config/event_taxonomy.env\n' "${KROOT}"
}

kao_event_taxonomy_load() {
  local file
  file="$(kao_event_taxonomy_file)"
  [ -f "${file}" ] || return 0
  # shellcheck disable=SC1090
  . "${file}"
}

kao_event_default_family() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close)
      printf 'session_lifecycle\n'
      ;;
    session-touch)
      printf 'operator_surface\n'
      ;;
    operator-status|operator-registry|operator-scout|operator-system-inspect|operator-system-repair)
      printf 'operator_surface\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch)
      printf 'gateway_activity\n'
      ;;
    execution-local-shell|execution-local-script|execution-local-binary)
      printf 'local_execution\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*)
      printf 'runtime_transaction\n'
      ;;
    runtime-recovery-*|runtime-consistency-*)
      printf 'runtime_reliability\n'
      ;;
    *)
      printf 'runtime_activity\n'
      ;;
  esac
}

kao_event_default_scope() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close)
      printf 'environment\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch)
      printf 'cognitive\n'
      ;;
    operator-*|session-touch)
      printf 'operator\n'
      ;;
    execution-local-*)
      printf 'system\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'system\n'
      ;;
    *)
      printf 'system\n'
      ;;
  esac
}

kao_event_default_intensity() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close)
      printf 'narrative\n'
      ;;
    operator-system-repair|runtime-recovery-*|runtime-consistency-broken)
      printf 'critical\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch|operator-status|operator-registry|operator-scout|operator-system-inspect|runtime-transaction-*|runtime-mutation-*|runtime-state-*)
      printf 'active\n'
      ;;
    *)
      printf 'passive\n'
      ;;
  esac
}

kao_event_default_surface() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close)
      printf 'system\n'
      ;;
    operator-*|session-touch)
      printf 'operator\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch)
      printf 'gateway\n'
      ;;
    execution-local-*)
      printf 'environment\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'kernel\n'
      ;;
    *)
      printf 'operator\n'
      ;;
  esac
}

kao_event_default_domain() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-touch|session-close)
      printf 'session\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch)
      printf 'router\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'runtime\n'
      ;;
    operator-*)
      printf 'operator\n'
      ;;
    execution-local-*)
      printf 'execution\n'
      ;;
    *)
      printf 'runtime\n'
      ;;
  esac
}

kao_event_default_authority_class() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close|runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'authoritative\n'
      ;;
    session-touch|operator-*|intent-analysis|execution-gateway|router-dispatch)
      printf 'advisory\n'
      ;;
    execution-local-*)
      printf 'observed\n'
      ;;
    *)
      printf 'observed\n'
      ;;
  esac
}

kao_event_default_mutation_state() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-close|runtime-state-*|runtime-mutation-commit|runtime-transaction-commit|runtime-recovery-commit)
      printf 'committed\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch|runtime-mutation-begin|runtime-transaction-begin)
      printf 'proposed\n'
      ;;
    execution-local-*|session-touch|operator-*)
      printf 'observed\n'
      ;;
    runtime-recovery-*|runtime-consistency-*)
      printf 'replayed\n'
      ;;
    *)
      printf 'observed\n'
      ;;
  esac
}

kao_event_default_memory_class() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    session-open|session-touch|session-close)
      printf 'session\n'
      ;;
    intent-analysis|execution-gateway|router-dispatch)
      printf 'cognitive\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'kernel\n'
      ;;
    *)
      printf 'runtime\n'
      ;;
  esac
}

kao_event_default_projection_class() {
  local event_type
  event_type="${1:-unknown}"

  case "${event_type}" in
    intent-analysis|execution-gateway|router-dispatch)
      printf 'cockpit\n'
      ;;
    session-open|session-touch|session-close)
      printf 'timeline\n'
      ;;
    runtime-transaction-*|runtime-mutation-*|runtime-state-*|runtime-recovery-*|runtime-consistency-*)
      printf 'health\n'
      ;;
    *)
      printf 'timeline\n'
      ;;
  esac
}

kao_event_taxonomy_value() {
  local event_type suffix key default_value value
  event_type="${1:-unknown}"
  suffix="${2:-}"
  default_value="${3:-}"

  key="$(printf '%s' "${event_type}" | tr '[:lower:]-' '[:upper:]_')_${suffix}"
  value="$(eval "printf '%s' \"\${${key}:-}\"")"

  if [ -n "${value}" ]; then
    printf '%s\n' "${value}"
  else
    printf '%s\n' "${default_value}"
  fi
}

kao_event_semantic_payload() {
  local event_type family scope intensity surface domain authority_class mutation_state memory_class projection_class
  event_type="${1:-unknown}"

  kao_event_taxonomy_load

  family="$(kao_event_taxonomy_value "${event_type}" "FAMILY" "$(kao_event_default_family "${event_type}")")"
  scope="$(kao_event_taxonomy_value "${event_type}" "SCOPE" "$(kao_event_default_scope "${event_type}")")"
  intensity="$(kao_event_taxonomy_value "${event_type}" "INTENSITY" "$(kao_event_default_intensity "${event_type}")")"
  surface="$(kao_event_taxonomy_value "${event_type}" "SURFACE" "$(kao_event_default_surface "${event_type}")")"
  domain="$(kao_event_taxonomy_value "${event_type}" "DOMAIN" "$(kao_event_default_domain "${event_type}")")"
  authority_class="$(kao_event_taxonomy_value "${event_type}" "AUTHORITY_CLASS" "$(kao_event_default_authority_class "${event_type}")")"
  mutation_state="$(kao_event_taxonomy_value "${event_type}" "MUTATION_STATE" "$(kao_event_default_mutation_state "${event_type}")")"
  memory_class="$(kao_event_taxonomy_value "${event_type}" "MEMORY_CLASS" "$(kao_event_default_memory_class "${event_type}")")"
  projection_class="$(kao_event_taxonomy_value "${event_type}" "PROJECTION_CLASS" "$(kao_event_default_projection_class "${event_type}")")"

  printf 'family=%s;scope=%s;intensity=%s;surface=%s;domain=%s;authority_class=%s;mutation_state=%s;memory_class=%s;projection_class=%s\n' \
    "${family}" \
    "${scope}" \
    "${intensity}" \
    "${surface}" \
    "${domain}" \
    "${authority_class}" \
    "${mutation_state}" \
    "${memory_class}" \
    "${projection_class}"
}

kao_event_enrich_detail() {
  local event_type raw_detail semantic
  event_type="${1:-unknown}"
  raw_detail="${2:-none}"
  semantic="$(kao_event_semantic_payload "${event_type}")"

  if [ -z "${raw_detail}" ] || [ "${raw_detail}" = "none" ]; then
    printf '%s\n' "${semantic}"
  else
    printf '%s;%s\n' "${raw_detail}" "${semantic}"
  fi
}

# ==========================================================
# REL-SYS-1 — Router Canonical Event
# ==========================================================

event_normalizer_emit_router_dispatch() {

    local provider="$1"
    local agent="$2"
    local intent="$3"
    local confidence="$4"

    local ts
    ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    printf 'ts=%s|session_id=none|event_type=router-dispatch|detail=provider=%s;agent=%s;intent=%s;confidence=%s;family=gateway_activity;scope=cognitive;intensity=active;surface=gateway;domain=router;authority_class=advisory;mutation_state=proposed;memory_class=cognitive;projection_class=cockpit\n' \
        "${ts}" \
        "${provider}" \
        "${agent}" \
        "${intent}" \
        "${confidence}" \
        >> "${KROOT}/state/runtime/session.timeline"
}
