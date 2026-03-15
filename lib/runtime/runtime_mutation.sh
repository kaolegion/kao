#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/runtime_transaction.sh"
source "${KROOT}/lib/runtime/runtime_recovery.sh"

kao_runtime_mutation_begin() {
  local current_lock_pid=""

  kao_runtime_tx_require_paths

  kao_runtime_recovery_assert_lock_safe || return 1
  kao_runtime_lock_assert_or_recover || return 1

  if kao_runtime_lock_is_held; then
    current_lock_pid="$(kao_runtime_lock_owner_pid)"
  fi

  TX_ID="$(kao_runtime_tx_new_id)"
  STARTED_AT="$(kao_runtime_tx_now_utc)"

  if [ -n "${current_lock_pid}" ] && [ "${current_lock_pid}" = "$$" ]; then
    mkdir -p "$(kao_runtime_tx_dir "${TX_ID}")"
    kao_runtime_tx_write_env "${TX_ID}" "${STARTED_AT}" "none" "open" "reentrant" "0"
    kao_runtime_tx_log "begin.reentrant" "${TX_ID}" "runtime-mutation"
    echo "${TX_ID}"
    return 0
  fi

  kao_runtime_tx_with_lock "${TX_ID}" "runtime-mutation" "mutation-begin" || return 1

  kao_runtime_tx_write_env "${TX_ID}" "${STARTED_AT}" "none" "open" "none" "0"
  kao_runtime_tx_log "begin" "${TX_ID}" "runtime-mutation"

  echo "${TX_ID}"
}

kao_runtime_mutation_commit() {
  local txid="${1:-}"
  local committed_at
  local barrier_state

  [ -n "${txid}" ] || return 1

  committed_at="$(kao_runtime_tx_now_utc)"
  barrier_state="$(kao_runtime_tx_field "${txid}" BARRIER_STATE 2>/dev/null || printf 'none')"

  if [ "${barrier_state}" = "reentrant" ]; then
    kao_runtime_tx_write_env "${txid}" "" "" "committed" "reentrant" "0" "${committed_at}"
    kao_runtime_tx_log "commit.reentrant" "${txid}" "runtime-mutation"
    return 0
  fi

  kao_runtime_tx_write_env "${txid}" "" "" "committed" "none" "0" "${committed_at}"
  kao_runtime_tx_log "commit" "${txid}" "runtime-mutation"
  kao_runtime_tx_release_lock
}

kao_runtime_mutation_abort() {
  local txid="${1:-}"
  local aborted_at
  local barrier_state

  [ -n "${txid}" ] || return 1

  aborted_at="$(kao_runtime_tx_now_utc)"
  barrier_state="$(kao_runtime_tx_field "${txid}" BARRIER_STATE 2>/dev/null || printf 'none')"

  if [ "${barrier_state}" = "reentrant" ]; then
    kao_runtime_tx_write_env "${txid}" "" "" "aborted" "reentrant" "0" "" "${aborted_at}"
    kao_runtime_tx_log "abort.reentrant" "${txid}" "runtime-mutation"
    return 0
  fi

  kao_runtime_tx_write_env "${txid}" "" "" "aborted" "none" "0" "" "${aborted_at}"
  kao_runtime_tx_log "abort" "${txid}" "runtime-mutation"
  kao_runtime_tx_release_lock
}
