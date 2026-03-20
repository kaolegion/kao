#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

# hard dependency — runtime mutation requires recovery + transaction layers
source "${KROOT}/lib/runtime/runtime_recovery.sh"
source "${KROOT}/lib/runtime/runtime_transaction.sh"

kao_runtime_mutation_prepare() {
  kao_runtime_tx_require_paths || return 1

  # Recover orphan lock first if needed.
  if kao_runtime_lock_is_orphan 2>/dev/null; then
    kao_runtime_lock_recover_orphan || return 1
  fi

  # Recover incomplete transactions before opening a new mutation.
  kao_runtime_transaction_recover_all >/dev/null 2>&1 || return 1
}

kao_runtime_mutation_lock_owned_by_self() {
  local owner_pid=""
  owner_pid="$(kao_runtime_lock_owner_pid 2>/dev/null || true)"
  [ -n "${owner_pid}" ] && [ "${owner_pid}" = "$$" ]
}

kao_runtime_mutation_begin() {
  local current_lock_pid=""
  local txid=""
  local started_at=""

  kao_runtime_mutation_prepare || return 1

  if kao_runtime_lock_is_held 2>/dev/null; then
    current_lock_pid="$(kao_runtime_lock_owner_pid 2>/dev/null || true)"
  fi

  txid="$(kao_runtime_tx_new_id)"
  started_at="$(kao_runtime_tx_now_utc)"

  if [ -n "${current_lock_pid}" ] && [ "${current_lock_pid}" = "$$" ]; then
    mkdir -p "$(kao_runtime_tx_dir "${txid}")"
    kao_runtime_tx_write_env "${txid}" "${started_at}" "none" "open" "reentrant" "0"
    kao_runtime_tx_log "begin.reentrant" "${txid}" "runtime-mutation"
    printf '%s\n' "${txid}"
    return 0
  fi

  kao_runtime_tx_with_lock "${txid}" "runtime-mutation" "mutation-begin" || return 1

  kao_runtime_tx_write_env "${txid}" "${started_at}" "none" "open" "none" "0"
  kao_runtime_tx_log "begin" "${txid}" "runtime-mutation"
  printf '%s\n' "${txid}"
}

kao_runtime_mutation_commit() {
  local txid="${1:-}"
  local committed_at=""
  local barrier_state=""

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

  if kao_runtime_mutation_lock_owned_by_self; then
    kao_runtime_tx_release_lock
  fi
}

kao_runtime_mutation_abort() {
  local txid="${1:-}"
  local aborted_at=""
  local barrier_state=""

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

  if kao_runtime_mutation_lock_owned_by_self; then
    kao_runtime_tx_release_lock
  fi
}
