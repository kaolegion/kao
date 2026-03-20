#!/usr/bin/env bash

set -euo pipefail

KAO_ROOT="${KAO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
STATE_DIR="${KAO_ROOT}/state"
RAW_LOG="${STATE_DIR}/runtime/events.raw.log"
SIGNALS_LOG="${STATE_DIR}/sense/signals.log"
TAXONOMY_FILE="${KAO_ROOT}/config/event_taxonomy.env"

mkdir -p "$(dirname "${RAW_LOG}")" "$(dirname "${SIGNALS_LOG}")"

kao_event_taxonomy_resolve() {
  local raw_type="${1:-UNKNOWN}"
  local mapping

  if [ -f "${TAXONOMY_FILE}" ]; then
    mapping="$(grep -E "^${raw_type}=" "${TAXONOMY_FILE}" | tail -n 1 | cut -d'=' -f2- || true)"
  else
    mapping=""
  fi

  if [ -z "${mapping}" ]; then
    mapping="$(grep -E '^UNKNOWN=' "${TAXONOMY_FILE}" | tail -n 1 | cut -d'=' -f2- || true)"
  fi

  if [ -z "${mapping}" ]; then
    mapping="system|unknown|unknown"
  fi

  printf '%s\n' "${mapping}"
}

kao_normalize_raw_line() {
  local raw_line="${1:-}"
  local ts raw_type payload mapping source domain event

  [ -n "${raw_line}" ] || return 0

  ts="$(printf '%s' "${raw_line}" | cut -d'|' -f1)"
  raw_type="$(printf '%s' "${raw_line}" | cut -d'|' -f2)"
  payload="$(printf '%s' "${raw_line}" | cut -d'|' -f3-)"

  [ -n "${ts}" ] || ts="$(date +%s)"
  [ -n "${raw_type}" ] || raw_type="UNKNOWN"

  mapping="$(kao_event_taxonomy_resolve "${raw_type}")"
  source="$(printf '%s' "${mapping}" | cut -d'|' -f1)"
  domain="$(printf '%s' "${mapping}" | cut -d'|' -f2)"
  event="$(printf '%s' "${mapping}" | cut -d'|' -f3)"

  printf '%s|%s|%s|%s|%s\n' "${ts}" "${source}" "${domain}" "${event}" "${payload}"
}

kao_normalize_and_append() {
  local raw_line="${1:-}"
  local signal_line

  signal_line="$(kao_normalize_raw_line "${raw_line}")"
  [ -n "${signal_line}" ] || return 0
  printf '%s\n' "${signal_line}" >> "${SIGNALS_LOG}"
}

if [ "${1:-}" = "normalize" ]; then
  shift
  kao_normalize_raw_line "${*:-}"
elif [ "${1:-}" = "append" ]; then
  shift
  kao_normalize_and_append "${*:-}"
fi

# --- timeline semantic compatibility layer ---

kao_event_enrich_detail() {
  local event_type="${1:-unknown}"
  local detail="${2:-none}"

  # minimal semantic fallback
  local family="runtime_activity"
  local scope="system"
  local intensity="passive"
  local surface="operator"

  case "${event_type}" in
    session-open|session-close)
      family="session_lifecycle"
      scope="environment"
      intensity="narrative"
      surface="system"
      ;;
    cognitive-event)
      family="cognitive_activity"
      scope="system"
      intensity="active"
      surface="system"
      ;;
    session-touch)
      family="operator_surface"
      scope="operator"
      intensity="passive"
      surface="operator"
      ;;
  esac

  printf '%s;family=%s;scope=%s;intensity=%s;surface=%s\n' \
    "${detail}" "${family}" "${scope}" "${intensity}" "${surface}"
}

