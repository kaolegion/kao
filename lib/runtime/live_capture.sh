#!/usr/bin/env bash

set -euo pipefail

KAO_ROOT="${KAO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
STATE_DIR="${KAO_ROOT}/state"
RAW_LOG="${STATE_DIR}/runtime/events.raw.log"
SIGNALS_LOG="${STATE_DIR}/sense/signals.log"
NORMALIZER="${KAO_ROOT}/lib/runtime/event_normalizer.sh"

mkdir -p "$(dirname "${RAW_LOG}")" "$(dirname "${SIGNALS_LOG}")"

kao_capture_event() {
  local raw_type="${1:-UNKNOWN}"
  shift || true
  local payload="${*:-}"
  local ts raw_line

  ts="$(date +%s)"
  raw_line="${ts}|${raw_type}|${payload}"

  printf '%s\n' "${raw_line}" >> "${RAW_LOG}"

  if [ -x "${NORMALIZER}" ]; then
    "${NORMALIZER}" append "${raw_line}" || true
  fi
}

if [ "${1:-}" = "capture" ]; then
  shift
  kao_capture_event "${@:-}"
fi

kao_live_capture_command_start() {
  local name="${1:-unknown}"
  kao_capture_event "COMMAND_START" "${name}"
}

kao_live_capture_command_end() {
  local name="${1:-unknown}"
  kao_capture_event "COMMAND_END" "${name}"
}

kao_live_capture_command_fail() {
  local name="${1:-unknown}"
  local rc="${2:-1}"
  kao_capture_event "COMMAND_FAIL" "${name}|${rc}"
}
