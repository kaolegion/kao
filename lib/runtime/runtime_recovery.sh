#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_TX_DIR="${RUNTIME_DIR}/.tx"

source "${KROOT}/lib/runtime/runtime_lock.sh"
source "${KROOT}/lib/runtime/runtime_transaction.sh"

kao_runtime_recovery_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_runtime_recovery_tx_is_terminal() {
  local txid="$1"
  local state barrier

  state="$(kao_runtime_tx_field "${txid}" STATE 2>/dev/null || echo unknown)"
  barrier="$(kao_runtime_tx_field "${txid}" BARRIER_STATE 2>/dev/null || echo unknown)"

  case "${state}:${barrier}" in
    committed:applied|aborted:reverted|rolled_back:reverted)
      return 0
      ;;
  esac

  return 1
}

kao_runtime_recovery_find_incomplete_tx() {
  [ -d "${RUNTIME_TX_DIR}" ] || return 0

  local tx
  for tx in "${RUNTIME_TX_DIR}"/*; do
    [ -d "${tx}" ] || continue
    local txid
    txid="$(basename "${tx}")"

    if ! kao_runtime_recovery_tx_is_terminal "${txid}"; then
      echo "${txid}"
      return 0
    fi
  done
}

kao_runtime_recovery_mark_aborted() {
  local txid="${1:-}"
  local started_at snapshot_id resource_count

  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT || true)"
  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID || true)"
  resource_count="$(kao_runtime_tx_field "${txid}" RESOURCE_COUNT || echo 0)"

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

kao_runtime_recovery_log() {
  local txid="$1"
  local msg="$2"

  kao_runtime_tx_log "recovery.sovereign" "${txid}" "${msg}"
}

kao_runtime_recovery_repair_tx() {
  local txid="$1"

  kao_runtime_recovery_log "${txid}" "detected-incomplete"

  if kao_runtime_tx_rollback "${txid}" >/dev/null 2>&1; then
    kao_runtime_recovery_mark_aborted "${txid}"
    kao_runtime_recovery_log "${txid}" "rollback-applied"
    return 0
  fi

  kao_runtime_recovery_log "${txid}" "rollback-failed"
  return 1
}

kao_runtime_recovery_run() {
  mkdir -p "${RUNTIME_DIR}"

  local txid
  txid="$(kao_runtime_recovery_find_incomplete_tx || true)"

  if [ -n "${txid}" ]; then
    kao_runtime_recovery_repair_tx "${txid}" && {
      echo "RUNTIME RECOVERY : sovereign repair applied (${txid})"
      return 0
    }
  fi

  if kao_runtime_lock_is_orphan; then
    kao_runtime_lock_recover_orphan || true
    kao_runtime_tx_log "recovery.unlock" "none" "orphan_lock=yes"
    echo "RUNTIME RECOVERY : orphan lock released"
  fi
}
