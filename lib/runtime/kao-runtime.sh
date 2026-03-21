#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

# REKON-CANONICAL-RUNTIME-CANDIDATE: current best runtime source-of-truth candidate.
# TODO(REKON): split responsibilities into runtime-core / connectivity / runtime-cli / signals after canon decision.
# TODO(REKON-FIX): keep shebang and load-order canonical during runtime core refactor.

source "${KROOT}/lib/runtime/authority_policy.sh"
source "${KROOT}/lib/runtime/runtime_recovery.sh"
source "${KROOT}/lib/runtime/runtime_mutation.sh"
source "${KROOT}/lib/runtime/snapshot_manager.sh"
source "${KROOT}/lib/runtime/runtime_lock.sh"
source "${KROOT}/lib/runtime/runtime_transaction.sh"
source "${KROOT}/lib/runtime/runtime_consistency.sh"
source "${KROOT}/lib/runtime/session_manager.sh"

kao_runtime_state_file() {
  printf '%s/state/runtime/runtime.state\n' "${KROOT}"
}

kao_runtime_snapshot_file() {
  printf '%s/state/runtime/runtime.snapshot\n' "${KROOT}"
}

kao_kernel_validate_provider() {
  local proposed="${1:-none}"

  # V0 authority policy:
  # - passthrough decision from Ray/gateway
  # - future sovereign policy engine can override here
  printf '%s\n' "${proposed}"
}

kao_runtime_session_current_file() {
  printf '%s/state/runtime/session.current\n' "${KROOT}"
}

kao_runtime_session_field() {
  local key="${1:-}"
  kao_runtime_read_field_from_file "$(kao_runtime_session_current_file)" "${key}"
}

kao_runtime_format_duration() {
  local total="${1:-0}"
  local hours minutes seconds

  case "${total}" in
    ''|*[!0-9]*)
      printf 'unknown\n'
      return 0
      ;;
  esac

  hours="$((total / 3600))"
  minutes="$(((total % 3600) / 60))"
  seconds="$((total % 60))"

  printf '%02dh:%02dm:%02ds\n' "${hours}" "${minutes}" "${seconds}"
}

kao_runtime_session_age_seconds() {
  kao_session_heat_age_seconds
}

kao_runtime_session_idle_seconds() {
  kao_session_heat_idle_seconds
}

kao_runtime_state_require() {
  mkdir -p "${KROOT}/state/runtime"
  touch "$(kao_runtime_state_file)"
}

kao_runtime_read_field_from_file() {
  local file="${1:-}"
  local key="${2:-}"

  [ -n "${file}" ] || return 1
  [ -n "${key}" ] || return 1
  [ -f "${file}" ] || return 1

  awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "${file}"
}

kao_runtime_state_field() {
  local key="${1:-}"
  kao_runtime_read_field_from_file "$(kao_runtime_state_file)" "${key}"
}

kao_runtime_snapshot_field() {
  local key="${1:-}"
  kao_runtime_read_field_from_file "$(kao_runtime_snapshot_file)" "${key}"
}

kao_runtime_best_field() {
  local key="${1:-}"
  local value=""

  value="$(kao_runtime_state_field "${key}" 2>/dev/null || true)"
  if [ -n "${value}" ]; then
    printf '%s\n' "${value}"
    return 0
  fi

  value="$(kao_runtime_snapshot_field "${key}" 2>/dev/null || true)"
  if [ -n "${value}" ]; then
    printf '%s\n' "${value}"
    return 0
  fi

  return 1
}

kao_runtime_state_set() {
  local key="$1"
  local value="$2"

  [ -n "${key}" ] || return 1

  TXID="$(kao_runtime_mutation_begin)" || return 1

  mkdir -p "${KROOT}/state/runtime"

  if [ ! -f "$(kao_runtime_state_file)" ]; then
    touch "$(kao_runtime_state_file)"
  fi

  if grep -q "^${key}=" "$(kao_runtime_state_file)"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$(kao_runtime_state_file)"
  else
    echo "${key}=${value}" >> "$(kao_runtime_state_file)"
  fi

  kao_runtime_mutation_commit "${TXID}"
}

kao_runtime_set_phase() {
  local phase="$1"

  case "${phase}" in
    BOOT|IDLE|ACTIVE_SESSION|COMMITTING|STOPPING)
      ;;
    *)
      echo "ERROR: invalid runtime phase ${phase}" >&2
      return 1
      ;;
  esac

  kao_runtime_state_set KAO_RUNTIME_PHASE "${phase}"
}

kao_router_decide_gateway() {
  local net local_llm cloud

  net="$(grep '^KAO_CONNECTIVITY_NETWORK=' "$(kao_runtime_state_file)" | cut -d= -f2)"
  local_llm="$(grep '^KAO_LOCAL_LLM=' "$(kao_runtime_state_file)" | cut -d= -f2)"
  cloud="$(grep '^KAO_CLOUD_ACCESS=' "$(kao_runtime_state_file)" | cut -d= -f2)"

  case "${net}" in
    offline)
      if [ "${local_llm}" = "present" ]; then
        echo "local|network_offline"
      else
        echo "none|no_route"
      fi
      return
      ;;
    online|degraded)
      if [ "${cloud}" = "available" ]; then
        echo "cloud|cloud_preferred"
      elif [ "${local_llm}" = "present" ]; then
        echo "local|fallback_local"
      else
        echo "none|no_route"
      fi
      return
      ;;
    *)
      echo "none|boot"
      ;;
  esac
}

kao_router_apply_gateway_decision() {
  local decision gateway reason

  decision="$(kao_router_decide_gateway)"
  gateway="$(echo "${decision}" | cut -d'|' -f1)"
  reason="$(echo "${decision}" | cut -d'|' -f2)"

  kao_runtime_state_set KAO_ROUTER_GATEWAY "${gateway}"
  kao_runtime_state_set KAO_ROUTER_REASON "${reason}"
}

kao_router_detect_network() {
  if ping -c1 -W1 8.8.8.8 >/dev/null 2>&1; then
    echo online
  else
    echo offline
  fi
}

kao_router_detect_local_llm() {
  if ss -ltn | grep -q ":11434"; then
    echo present
  else
    echo absent
  fi
}

kao_router_journal() {
  local msg="$1"
  local journal="${KROOT}/state/runtime/runtime.journal"

  mkdir -p "${KROOT}/state/runtime"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)|${msg}" >> "${journal}"
}

kao_router_refresh_connectivity() {
  local net llm

  net="$(kao_router_detect_network)"
  llm="$(kao_router_detect_local_llm)"

  kao_runtime_state_set KAO_CONNECTIVITY_NETWORK "${net}"
  kao_runtime_state_set KAO_LOCAL_LLM "${llm}"

  if [ "${net}" = "online" ]; then
    kao_runtime_state_set KAO_CLOUD_ACCESS "available"
  else
    kao_runtime_state_set KAO_CLOUD_ACCESS "unavailable"
  fi

  kao_router_journal "connectivity_refresh network=${net} local_llm=${llm}"

  kao_router_apply_gateway_decision
}

kao_runtime_snapshot_refresh() {
  local snapshot_file tmp_file session_file now

  kao_runtime_state_require

  snapshot_file="$(kao_runtime_snapshot_file)"
  tmp_file="${snapshot_file}.tmp.$$"
  session_file="$(kao_runtime_session_current_file)"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  {
    printf 'SNAPSHOT_AT=%s\n' "${now}"

    if [ -f "$(kao_runtime_state_file)" ]; then
      grep '^[A-Z0-9_]\+=' "$(kao_runtime_state_file)" || true
    fi

    if [ -f "${session_file}" ]; then
      awk -F= '
        $1=="SESSION_ID" { printf "SNAPSHOT_SESSION_ID=%s\n", substr($0, index($0, "=") + 1) }
        $1=="OPENED_AT" { printf "SNAPSHOT_SESSION_OPENED_AT=%s\n", substr($0, index($0, "=") + 1) }
        $1=="SESSION_STARTED_AT" { printf "SNAPSHOT_SESSION_STARTED_AT=%s\n", substr($0, index($0, "=") + 1) }
        $1=="SESSION_LAST_ACTIVITY_AT" { printf "SNAPSHOT_SESSION_LAST_ACTIVITY_AT=%s\n", substr($0, index($0, "=") + 1) }
        $1=="SESSION_HEAT_LEVEL" { printf "SNAPSHOT_SESSION_HEAT_LEVEL=%s\n", substr($0, index($0, "=") + 1) }
        $1=="SESSION_MEMORY_CLASS" { printf "SNAPSHOT_SESSION_MEMORY_CLASS=%s\n", substr($0, index($0, "=") + 1) }
        $1=="GATEWAY_PROVIDER" { printf "SNAPSHOT_SESSION_GATEWAY_PROVIDER=%s\n", substr($0, index($0, "=") + 1) }
        $1=="GATEWAY_AGENT" { printf "SNAPSHOT_SESSION_GATEWAY_AGENT=%s\n", substr($0, index($0, "=") + 1) }
      ' "${session_file}"
    fi
  } > "${tmp_file}"

  mv "${tmp_file}" "${snapshot_file}"
  printf 'RUNTIME SNAPSHOT REFRESHED\n'
}

kao_runtime_status() {
  local actor provider level net phase snapshot_status
  local session_id session_provider session_agent
  local session_started_at session_last_activity_at session_heat_level session_memory_class
  local session_age_seconds session_idle_seconds session_age_human session_idle_human

  if [ -f "$(kao_runtime_session_current_file)" ]; then
    kao_session_heat_refresh >/dev/null 2>&1 || true
  fi

  actor="$(kao_runtime_best_field KAO_RUNTIME_ACTIVE_ACTOR 2>/dev/null || printf 'unknown')"
  phase="$(kao_runtime_best_field KAO_RUNTIME_PHASE 2>/dev/null || printf 'unknown')"

  provider="$(kao_runtime_best_field KAO_GATEWAY_PROVIDER 2>/dev/null || true)"
  [ -n "${provider}" ] || provider="$(kao_runtime_best_field KAO_ROUTER_GATEWAY 2>/dev/null || printf 'unknown')"

  level="$(kao_runtime_best_field KAO_GATEWAY_COGNITIVE_LEVEL 2>/dev/null || printf 'unknown')"

  net="$(kao_runtime_best_field KAO_GATEWAY_CONNECTIVITY 2>/dev/null || true)"
  [ -n "${net}" ] || net="$(kao_runtime_best_field KAO_CONNECTIVITY_NETWORK 2>/dev/null || printf 'unknown')"

  if [ -f "$(kao_runtime_snapshot_file)" ]; then
    snapshot_status="PRESENT"
  else
    snapshot_status="ABSENT"
  fi

  if [ -f "$(kao_runtime_session_current_file)" ]; then
    session_id="$(kao_runtime_session_field SESSION_ID)"
    session_provider="$(kao_runtime_session_field GATEWAY_PROVIDER)"
    session_agent="$(kao_runtime_session_field GATEWAY_AGENT)"

    session_started_at="$(kao_runtime_session_field SESSION_STARTED_AT)"
    [ -n "${session_started_at}" ] || session_started_at="$(kao_runtime_session_field OPENED_AT)"

    session_last_activity_at="$(kao_runtime_session_field SESSION_LAST_ACTIVITY_AT)"
    session_heat_level="$(kao_runtime_session_field SESSION_HEAT_LEVEL)"
    session_memory_class="$(kao_runtime_session_field SESSION_MEMORY_CLASS)"

    session_age_seconds="$(kao_runtime_session_age_seconds)"
    session_idle_seconds="$(kao_runtime_session_idle_seconds)"
  else
    session_id="$(kao_runtime_best_field SNAPSHOT_SESSION_ID || printf 'none')"
    session_provider="$(kao_runtime_best_field SNAPSHOT_SESSION_GATEWAY_PROVIDER || printf 'none')"
    session_agent="$(kao_runtime_best_field SNAPSHOT_SESSION_GATEWAY_AGENT || printf 'none')"

    session_started_at="$(kao_runtime_best_field SNAPSHOT_SESSION_STARTED_AT)"
    session_last_activity_at="$(kao_runtime_best_field SNAPSHOT_SESSION_LAST_ACTIVITY_AT)"
    session_heat_level="$(kao_runtime_best_field SNAPSHOT_SESSION_HEAT_LEVEL)"
    session_memory_class="$(kao_runtime_best_field SNAPSHOT_SESSION_MEMORY_CLASS)"

    session_age_seconds="unknown"
    session_idle_seconds="unknown"
  fi

  session_age_human="$(kao_runtime_format_duration "${session_age_seconds}")"
  session_idle_human="$(kao_runtime_format_duration "${session_idle_seconds}")"

  printf 'RUNTIME STATUS\n'
  printf 'actor             : %s\n' "${actor}"
  printf 'phase             : %s\n' "${phase}"
  printf 'gateway provider  : %s\n' "${provider}"
  printf 'gateway level     : %s\n' "${level}"
  printf 'gateway net       : %s\n' "${net}"
  printf 'snapshot          : %s\n' "${snapshot_status}"
  printf 'session id        : %s\n' "${session_id}"
  printf 'session provider  : %s\n' "${session_provider}"
  printf 'session agent     : %s\n' "${session_agent}"
  printf 'session started   : %s\n' "${session_started_at}"
  printf 'last activity     : %s\n' "${session_last_activity_at}"
  printf 'session age       : %s\n' "${session_age_human}"
  printf 'session idle      : %s\n' "${session_idle_human}"
  printf 'session heat      : %s\n' "${session_heat_level}"
  printf 'session memory    : %s\n' "${session_memory_class}"
}

kao_runtime_mode_status() {
  local mode
  mode="$(kao_runtime_state_field KAO_RUNTIME_CONNECTIVITY_MODE 2>/dev/null || printf 'auto')"

  printf 'RUNTIME MODE\n'
  printf 'mode : %s\n' "${mode}"
}

kao_runtime_mode_set() {
  local mode="${1:-}"

  case "${mode}" in
    auto|offline|online)
      ;;
    *)
      printf 'usage: kao runtime mode status|set <auto|offline|online>\n' >&2
      return 1
      ;;
  esac

  kao_runtime_state_set KAO_RUNTIME_CONNECTIVITY_MODE "${mode}"
  kao_runtime_snapshot_refresh >/dev/null
  printf 'RUNTIME MODE SET : %s\n' "${mode}"
}

kao_runtime_lock_cli() {
  case "${1:-status}" in
    ""|status)
      kao_runtime_lock_status
      ;;
    *)
      printf "usage: kao lock status
" >&2
      return 1
      ;;
  esac
}

kao_runtime_transaction_cli() {
  case "${1:-status}" in
    ""|status)
      kao_runtime_tx_status
      ;;
    *)
      printf "usage: kao transaction status
" >&2
      return 1
      ;;
  esac
}

kao_runtime_consistency_cli() {
  case "${1:-status}" in
    ""|status)
      kao_runtime_consistency_run
      ;;
    *)
      printf "usage: kao consistency status
" >&2
      return 1
      ;;
  esac
}

kao_runtime_session_cli() {
  local session_id opened_at

  case "${1:-status}" in
    ""|status)
      printf 'SESSION STATUS
'
      if [ -f "$(kao_runtime_session_current_file)" ]; then
        session_id="$(grep '^SESSION_ID=' "$(kao_runtime_session_current_file)" | cut -d= -f2)"
        opened_at="$(grep '^OPENED_AT=' "$(kao_runtime_session_current_file)" | cut -d= -f2)"
        printf 'session id        : %s
' "${session_id}"
        printf 'opened at         : %s
' "${opened_at}"
      else
        printf 'session id        : none
'
        printf 'opened at         : none
'
      fi

      printf '
'
      if [ -f "${KROOT}/lib/runtime/session_cognitive_state.sh" ]; then
        . "${KROOT}/lib/runtime/session_cognitive_state.sh"
        kao_session_cognitive_state
      fi
      ;;
    open)
      kao_session_open
      printf 'SESSION OPENED
'
      ;;
    close)
      kao_session_close
      printf 'SESSION CLOSED
'
      ;;
    recall)
      . "${KROOT}/lib/runtime/session_memory_recall.sh"
      kao_session_memory_recall
      ;;
    *)
      printf 'usage: kao session [open|close|status|recall]
' >&2
      return 1
      ;;
  esac
}

kao_runtime_cli() {
  local cmd="${1:-status}"
  shift || true

  case "${cmd}" in
    ""|status)
      kao_runtime_status
      ;;
    refresh)
      kao_router_refresh_connectivity
      kao_runtime_snapshot_refresh
      printf 'RUNTIME REFRESH OK\n'
      ;;
    snapshot)
      case "${1:-refresh}" in
        refresh|"")
          kao_runtime_snapshot_refresh
          ;;
        *)
          printf 'usage: kao runtime snapshot [refresh]\n' >&2
          return 1
          ;;
      esac
      ;;
    mode)
      case "${1:-status}" in
        status)
          kao_runtime_mode_status
          ;;
        set)
          shift || true
          kao_runtime_mode_set "${1:-}"
          ;;
        *)
          printf 'usage: kao runtime mode status|set <auto|offline|online>\n' >&2
          return 1
          ;;
      esac
      ;;
    lock)
      kao_runtime_lock_cli "$@"
      ;;
    transaction)
      kao_runtime_transaction_cli "$@"
      ;;
    consistency)
      kao_runtime_consistency_cli "$@"
      ;;
    session)
      kao_runtime_session_cli "$@"
      ;;
    *)
      printf 'usage: kao runtime [status|refresh|snapshot|mode|lock|transaction|consistency|session]\n' >&2
      return 1
      ;;
  esac
}

# ==========================================================
# ==========================================================
# REL-SYS-1 — Runtime Authority Pulse Surface
# ==========================================================

kao_runtime_authority_pulse() {
    local pulse_type="${1:-runtime-authority}"
    local pulse_detail="${2:-none}"
    local ts

    ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    printf 'AUTHORITY_PULSE|ts=%s|type=%s|detail=%s\n' \
        "${ts}" \
        "${pulse_type}" \
        "${pulse_detail}" \
        >> "${KROOT}/state/runtime/runtime.journal"

    {
        echo "KAO_RUNTIME_LAST_AUTHORITY_TYPE=${pulse_type}"
        echo "KAO_RUNTIME_LAST_AUTHORITY_TS=${ts}"
    } >> "${KROOT}/state/runtime/runtime.state"
}

kao_runtime_signals_file() {
  printf '%s/state/runtime/runtime.signals.log\n' "${KROOT}"
}

kao_runtime_signals_require() {
  mkdir -p "${KROOT}/state/runtime"
}

kao_runtime_signals_render() {
  local f
  f="$(kao_runtime_signals_file)"

  if [ ! -f "${f}" ]; then
    echo "RUNTIME SIGNAL STREAM"
    echo "status : empty"
    echo "note   : no runtime signals recorded"
    return 0
  fi

  echo "RUNTIME SIGNAL STREAM"
  tail -n 40 "${f}"
}

kao_runtime_signals_cli() {
  kao_runtime_signals_require
  kao_runtime_signals_render
}

