#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_TX_DIR="${RUNTIME_DIR}/.tx"

source "${KROOT}/lib/runtime/runtime_lock.sh"
source "${KROOT}/lib/runtime/runtime_transaction.sh"

kao_runtime_recovery_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_runtime_recovery_last_open_tx() {
  local txdir last_tx="" state barrier_state

  [ -d "${RUNTIME_TX_DIR}" ] || return 0

  while IFS= read -r txdir; do
    state="$(kao_runtime_tx_field "$(basename "${txdir}")" STATE 2>/dev/null || true)"
    barrier_state="$(kao_runtime_tx_field "$(basename "${txdir}")" BARRIER_STATE 2>/dev/null || true)"

    case "${state}:${barrier_state}" in
      open:*|committing:*|committed:apply-running)
        last_tx="$(basename "${txdir}")"
        ;;
    esac
  done < <(find "${RUNTIME_TX_DIR}" -mindepth 1 -maxdepth 1 -type d | sort)

  [ -n "${last_tx}" ] && printf '%s\n' "${last_tx}"
}

kao_runtime_recovery_mark_aborted() {
  local txid="${1:-}"
  local txdir started_at snapshot_id resource_count

  txdir="${RUNTIME_TX_DIR}/${txid}"
  [ -d "${txdir}" ] || return 1

  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT || true)"
  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID || true)"
  resource_count="$(kao_runtime_tx_field "${txid}" RESOURCE_COUNT || printf '0')"

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "aborted" \
    "reverted" \
    "${resource_count}" \
    "" \
    "$(kao_runtime_recovery_now_utc)"
}

kao_runtime_recovery_mark_committed_recovered() {
  local txid="${1:-}"
  local started_at snapshot_id resource_count committed_at

  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT || true)"
  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID || true)"
  resource_count="$(kao_runtime_tx_field "${txid}" RESOURCE_COUNT || printf '0')"
  committed_at="$(kao_runtime_tx_field "${txid}" COMMITTED_AT || true)"

  [ -n "${committed_at}" ] || committed_at="$(kao_runtime_recovery_now_utc)"

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "committed" \
    "applied" \
    "${resource_count}" \
    "${committed_at}"
}

kao_runtime_recovery_log_timeline() {
  local txid="${1:-none}"
  local state="${2:-unknown}"
  local barrier_state="${3:-unknown}"
  local action="${4:-none}"

  printf '%s|tx=%s|state=%s|barrier=%s|action=%s\n' \
    "$(kao_runtime_recovery_now_utc)" \
    "${txid}" \
    "${state}" \
    "${barrier_state}" \
    "${action}" >> "${RUNTIME_JOURNAL_FILE}"
}

kao_runtime_recovery_repair_tx_if_needed() {
  local txid="${1:-}"
  local state barrier_state

  [ -n "${txid}" ] || return 1

  state="$(kao_runtime_tx_field "${txid}" STATE 2>/dev/null || printf 'unknown')"
  barrier_state="$(kao_runtime_tx_field "${txid}" BARRIER_STATE 2>/dev/null || printf 'unknown')"

  kao_runtime_recovery_log_timeline "${txid}" "${state}" "${barrier_state}" "recovery-inspect"

  case "${state}:${barrier_state}" in
    open:*|committing:*|committed:apply-running)
      kao_runtime_tx_log "recovery.detected" "${txid}" "state=${state};barrier=${barrier_state}"
      kao_runtime_recovery_log_timeline "${txid}" "${state}" "${barrier_state}" "rollback-required"

      if kao_runtime_tx_rollback "${txid}" >/dev/null; then
        kao_runtime_recovery_mark_aborted "${txid}"
        kao_runtime_tx_log "recovery.rollback" "${txid}" "state=${state};barrier=${barrier_state}"
        kao_runtime_recovery_log_timeline "${txid}" "aborted" "reverted" "rollback-applied"
        return 0
      fi

      kao_runtime_tx_log "recovery.rollback-failed" "${txid}" "state=${state};barrier=${barrier_state}"
      kao_runtime_recovery_log_timeline "${txid}" "${state}" "${barrier_state}" "rollback-failed"
      return 1
      ;;
    committed:applied)
      kao_runtime_recovery_mark_committed_recovered "${txid}"
      kao_runtime_tx_log "recovery.confirm" "${txid}" "state=committed;barrier=applied"
      kao_runtime_recovery_log_timeline "${txid}" "committed" "applied" "confirm-committed"
      return 0
      ;;
    rolled_back:*|aborted:*)
      kao_runtime_tx_log "recovery.skip" "${txid}" "state=${state};barrier=${barrier_state}"
      kao_runtime_recovery_log_timeline "${txid}" "${state}" "${barrier_state}" "skip-terminal"
      return 0
      ;;
    *)
      kao_runtime_tx_log "recovery.unknown" "${txid}" "state=${state};barrier=${barrier_state}"
      kao_runtime_recovery_log_timeline "${txid}" "${state}" "${barrier_state}" "unknown-state"
      return 1
      ;;
  esac
}

kao_runtime_recovery_run() {
  local open_txid recovered=0

  mkdir -p "${RUNTIME_DIR}"

  if kao_runtime_lock_is_orphan; then
    open_txid="$(kao_runtime_recovery_last_open_tx || true)"

    if [ -n "${open_txid}" ]; then
      if kao_runtime_recovery_repair_tx_if_needed "${open_txid}"; then
        recovered=1
      fi
    else
      kao_runtime_lock_recover_orphan || true
      kao_runtime_tx_log "recovery.unlock" "none" "orphan_lock=yes"
      kao_runtime_recovery_log_timeline "none" "none" "none" "unlock-orphan-without-tx"
      recovered=1
    fi
  fi

  if [ "${recovered}" -eq 1 ]; then
    printf 'RUNTIME RECOVERY : applied\n'
  fi
}
