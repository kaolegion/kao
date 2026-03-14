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
    intent-analysis|execution-gateway)
      printf 'gateway_activity\n'
      ;;
    execution-local-shell|execution-local-script|execution-local-binary)
      printf 'local_execution\n'
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
    intent-analysis|execution-gateway)
      printf 'cognitive\n'
      ;;
    operator-*|session-touch)
      printf 'operator\n'
      ;;
    execution-local-*)
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
    operator-system-repair)
      printf 'critical\n'
      ;;
    intent-analysis|execution-gateway|operator-status|operator-registry|operator-scout|operator-system-inspect)
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
    intent-analysis|execution-gateway)
      printf 'gateway\n'
      ;;
    execution-local-*)
      printf 'environment\n'
      ;;
    *)
      printf 'operator\n'
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
  local event_type family scope intensity surface
  event_type="${1:-unknown}"

  kao_event_taxonomy_load

  family="$(kao_event_taxonomy_value "${event_type}" "FAMILY" "$(kao_event_default_family "${event_type}")")"
  scope="$(kao_event_taxonomy_value "${event_type}" "SCOPE" "$(kao_event_default_scope "${event_type}")")"
  intensity="$(kao_event_taxonomy_value "${event_type}" "INTENSITY" "$(kao_event_default_intensity "${event_type}")")"
  surface="$(kao_event_taxonomy_value "${event_type}" "SURFACE" "$(kao_event_default_surface "${event_type}")")"

  printf 'family=%s;scope=%s;intensity=%s;surface=%s\n' \
    "${family}" \
    "${scope}" \
    "${intensity}" \
    "${surface}"
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
