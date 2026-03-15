#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_TX_DIR="${RUNTIME_DIR}/.tx"
RUNTIME_JOURNAL_FILE="${RUNTIME_DIR}/runtime.journal"

source "${KROOT}/lib/runtime/runtime_lock.sh"
source "${KROOT}/lib/runtime/snapshot_manager.sh"

kao_runtime_tx_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_runtime_tx_require_paths() {
  mkdir -p "${RUNTIME_DIR}" "${RUNTIME_TX_DIR}"
  touch "${RUNTIME_JOURNAL_FILE}"
}

kao_runtime_tx_new_id() {
  printf 'tx-%s-%s' "$(date -u +%Y%m%d-%H%M%S)" "$RANDOM"
}

kao_runtime_tx_dir() {
  local txid="${1:-}"
  printf '%s/%s\n' "${RUNTIME_TX_DIR}" "${txid}"
}

kao_runtime_tx_env_file() {
  local txid="${1:-}"
  printf '%s/transaction.env\n' "$(kao_runtime_tx_dir "${txid}")"
}

kao_runtime_tx_stage_dir() {
  local txid="${1:-}"
  printf '%s/stage\n' "$(kao_runtime_tx_dir "${txid}")"
}

kao_runtime_tx_wal_dir() {
  local txid="${1:-}"
  printf '%s/wal\n' "$(kao_runtime_tx_dir "${txid}")"
}

kao_runtime_tx_wal_file() {
  local txid="${1:-}"
  printf '%s/runtime.wal\n' "$(kao_runtime_tx_wal_dir "${txid}")"
}

kao_runtime_tx_manifest_file() {
  local txid="${1:-}"
  printf '%s/resources.manifest\n' "$(kao_runtime_tx_dir "${txid}")"
}

kao_runtime_tx_field() {
  local txid="${1:-}"
  local key="${2:-}"
  local env_file

  env_file="$(kao_runtime_tx_env_file "${txid}")"

  [ -n "${txid}" ] || return 1
  [ -n "${key}" ] || return 1
  [ -f "${env_file}" ] || return 1

  awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "${env_file}"
}

kao_runtime_tx_write_env() {
  local txid="${1:-}"
  local started_at="${2:-}"
  local snapshot_id="${3:-}"
  local state="${4:-open}"
  local barrier_state="${5:-none}"
  local resource_count="${6:-0}"
  local committed_at="${7:-}"
  local aborted_at="${8:-}"

  local env_file
  env_file="$(kao_runtime_tx_env_file "${txid}")"

  mkdir -p "$(dirname "${env_file}")"

  {
    printf 'TX_ID=%s\n' "${txid}"
    printf 'STARTED_AT=%s\n' "${started_at}"
    printf 'SNAPSHOT_ID=%s\n' "${snapshot_id}"
    printf 'STATE=%s\n' "${state}"
    printf 'BARRIER_STATE=%s\n' "${barrier_state}"
    printf 'RESOURCE_COUNT=%s\n' "${resource_count}"

    if [ -n "${committed_at}" ]; then
      printf 'COMMITTED_AT=%s\n' "${committed_at}"
    fi

    if [ -n "${aborted_at}" ]; then
      printf 'ABORTED_AT=%s\n' "${aborted_at}"
    fi
  } > "${env_file}"
}

kao_runtime_tx_log() {
  local action="${1:-unknown}"
  local txid="${2:-none}"
  local detail="${3:-none}"

  printf '%s|tx=%s|action=%s|detail=%s\n' \
    "$(kao_runtime_tx_now_utc)" \
    "${txid}" \
    "${action}" \
    "${detail}" >> "${RUNTIME_JOURNAL_FILE}"
}

kao_runtime_tx_manifest_append() {
  local txid="${1:-}"
  local rel="${2:-}"
  local manifest_file

  manifest_file="$(kao_runtime_tx_manifest_file "${txid}")"

  [ -n "${txid}" ] || return 1
  [ -n "${rel}" ] || return 1

  mkdir -p "$(dirname "${manifest_file}")"
  touch "${manifest_file}"

  if ! grep -Fxq "${rel}" "${manifest_file}" 2>/dev/null; then
    printf '%s\n' "${rel}" >> "${manifest_file}"
  fi
}

kao_runtime_tx_resource_count() {
  local txid="${1:-}"
  local manifest_file

  manifest_file="$(kao_runtime_tx_manifest_file "${txid}")"

  if [ ! -f "${manifest_file}" ]; then
    printf '0\n'
    return 0
  fi

  awk 'NF { count++ } END { print count + 0 }' "${manifest_file}"
}

kao_runtime_tx_sha256() {
  local file="${1:-}"

  [ -f "${file}" ] || return 1
  sha256sum "${file}" | awk '{print $1}'
}

kao_runtime_tx_with_lock() {
  local txid="${1:-none}"
  local owner_label="${2:-runtime-op}"
  local command="${3:-unknown-command}"

  kao_runtime_lock_acquire 50 "transaction" "${owner_label}" "${txid}" "${command}"
}

kao_runtime_tx_release_lock() {
  if kao_runtime_lock_is_held; then
    kao_runtime_lock_release
  fi
}

kao_runtime_tx_wal_append_stage() {
  local txid="${1:-}"
  local rel="${2:-}"
  local stage_file="${3:-}"
  local sha256="${4:-}"
  local staged_at="${5:-}"
  local wal_file

  wal_file="$(kao_runtime_tx_wal_file "${txid}")"

  [ -n "${txid}" ] || return 1
  [ -n "${rel}" ] || return 1
  [ -f "${stage_file}" ] || return 1

  mkdir -p "$(dirname "${wal_file}")"
  touch "${wal_file}"

  printf 'WAL_STAGE|tx=%s|target=%s|stage_file=%s|sha256=%s|staged_at=%s\n' \
    "${txid}" \
    "${rel}" \
    "${stage_file}" \
    "${sha256}" \
    "${staged_at}" >> "${wal_file}"
}

kao_runtime_tx_wal_iter_stage_records() {
  local txid="${1:-}"
  local wal_file

  wal_file="$(kao_runtime_tx_wal_file "${txid}")"
  [ -f "${wal_file}" ] || return 0

  grep '^WAL_STAGE|' "${wal_file}" || true
}

kao_runtime_tx_wal_field() {
  local line="${1:-}"
  local key="${2:-}"

  [ -n "${line}" ] || return 1
  [ -n "${key}" ] || return 1

  printf '%s\n' "${line}" | tr '|' '\n' | awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }'
}

kao_runtime_tx_check_stage_record() {
  local txid="${1:-}"
  local line="${2:-}"

  local rel stage_file expected_sha actual_sha

  rel="$(kao_runtime_tx_wal_field "${line}" "target")"
  stage_file="$(kao_runtime_tx_wal_field "${line}" "stage_file")"
  expected_sha="$(kao_runtime_tx_wal_field "${line}" "sha256")"

  [ -n "${rel}" ] || {
    printf 'ERROR: wal target missing\n' >&2
    return 1
  }

  [ -f "${stage_file}" ] || {
    printf 'ERROR: wal stage file missing: %s\n' "${stage_file}" >&2
    return 1
  }

  actual_sha="$(kao_runtime_tx_sha256 "${stage_file}")"
  if [ "${actual_sha}" != "${expected_sha}" ]; then
    printf 'ERROR: wal checksum mismatch for %s\n' "${rel}" >&2
    return 1
  fi

  return 0
}

kao_runtime_tx_check_consistency() {
  local txid="${1:-}"
  local txdir wal_file manifest_file env_file
  local issues=0 line checked=0

  txdir="$(kao_runtime_tx_dir "${txid}")"
  wal_file="$(kao_runtime_tx_wal_file "${txid}")"
  manifest_file="$(kao_runtime_tx_manifest_file "${txid}")"
  env_file="$(kao_runtime_tx_env_file "${txid}")"

  [ -d "${txdir}" ] || {
    printf 'CONSISTENCY|tx=%s|state=missing-txdir\n' "${txid}"
    return 1
  }

  [ -f "${env_file}" ] || issues=$((issues + 1))
  [ -f "${manifest_file}" ] || issues=$((issues + 1))
  [ -f "${wal_file}" ] || issues=$((issues + 1))

  while IFS= read -r line; do
    [ -n "${line}" ] || continue
    checked=$((checked + 1))
    if ! kao_runtime_tx_check_stage_record "${txid}" "${line}"; then
      issues=$((issues + 1))
    fi
  done < <(kao_runtime_tx_wal_iter_stage_records "${txid}")

  printf 'CONSISTENCY|tx=%s|issues=%s|checked=%s\n' "${txid}" "${issues}" "${checked}"

  [ "${issues}" -eq 0 ]
}

kao_runtime_tx_begin() {
  local txid txdir snapshot_id started_at

  kao_runtime_tx_require_paths

  txid="$(kao_runtime_tx_new_id)"
  txdir="$(kao_runtime_tx_dir "${txid}")"
  started_at="$(kao_runtime_tx_now_utc)"

  kao_runtime_tx_with_lock "${txid}" "runtime-tx-begin" "kao transaction begin" || return 1

  mkdir -p \
    "${txdir}" \
    "$(kao_runtime_tx_stage_dir "${txid}")" \
    "$(kao_runtime_tx_wal_dir "${txid}")"

  : > "$(kao_runtime_tx_manifest_file "${txid}")"
  : > "$(kao_runtime_tx_wal_file "${txid}")"

  snapshot_id="$(kao_snapshot_create | awk -F': ' '/SNAPSHOT CREATED/ {print $2}')"

  [ -n "${snapshot_id}" ] || {
    kao_runtime_tx_release_lock
    printf 'ERROR: snapshot creation failed\n' >&2
    return 1
  }

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "open" \
    "none" \
    "0"

  kao_runtime_tx_log "begin" "${txid}" "snapshot=${snapshot_id}"
  kao_runtime_tx_release_lock

  printf '%s\n' "${txid}"
}

kao_runtime_tx_stage_file() {
  local txid="${1:-}"
  local target="${2:-}"
  local source_file="${3:-}"

  local txdir rel stage_target resource_count started_at snapshot_id state
  local barrier_state stage_sha staged_at

  txdir="$(kao_runtime_tx_dir "${txid}")"

  [ -d "${txdir}" ] || {
    printf 'ERROR: unknown tx\n' >&2
    return 1
  }

  [ -f "${source_file}" ] || {
    printf 'ERROR: stage source missing\n' >&2
    return 1
  }

  kao_runtime_tx_with_lock "${txid}" "runtime-tx-stage" "kao transaction stage" || return 1

  rel="$(realpath --relative-to="${RUNTIME_DIR}" "${target}")"
  stage_target="$(kao_runtime_tx_stage_dir "${txid}")/${rel}"

  mkdir -p "$(dirname "${stage_target}")"
  cp "${source_file}" "${stage_target}"

  stage_sha="$(kao_runtime_tx_sha256 "${stage_target}")"
  staged_at="$(kao_runtime_tx_now_utc)"

  kao_runtime_tx_manifest_append "${txid}" "${rel}"
  kao_runtime_tx_wal_append_stage "${txid}" "${rel}" "${stage_target}" "${stage_sha}" "${staged_at}"

  resource_count="$(kao_runtime_tx_resource_count "${txid}")"
  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT)"
  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID)"
  state="$(kao_runtime_tx_field "${txid}" STATE)"
  barrier_state="staged"

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "${state}" \
    "${barrier_state}" \
    "${resource_count}"

  kao_runtime_tx_log "stage" "${txid}" "${rel}"
  kao_runtime_tx_release_lock
}

kao_runtime_tx_apply_stage() {
  local txid="${1:-}"
  local line rel stage_file target tmp

  while IFS= read -r line; do
    [ -n "${line}" ] || continue

    if ! kao_runtime_tx_check_stage_record "${txid}" "${line}"; then
      kao_runtime_tx_log "apply-check-failed" "${txid}" "wal_checksum_or_stage_missing"
      return 1
    fi

    rel="$(kao_runtime_tx_wal_field "${line}" "target")"
    stage_file="$(kao_runtime_tx_wal_field "${line}" "stage_file")"
    target="${RUNTIME_DIR}/${rel}"
    tmp="${target}.apply.$$"

    mkdir -p "$(dirname "${target}")"
    cp "${stage_file}" "${tmp}"
    mv "${tmp}" "${target}"

    kao_runtime_tx_log "apply" "${txid}" "${rel}"
  done < <(kao_runtime_tx_wal_iter_stage_records "${txid}")
}

kao_runtime_tx_commit() {
  local txid="${1:-}"
  local txdir snapshot_id started_at resource_count

  txdir="$(kao_runtime_tx_dir "${txid}")"

  [ -d "${txdir}" ] || {
    printf 'ERROR: unknown transaction\n' >&2
    return 1
  }

  kao_runtime_tx_with_lock "${txid}" "runtime-tx-commit" "kao transaction commit" || return 1

  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID)"
  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT)"
  resource_count="$(kao_runtime_tx_resource_count "${txid}")"

  if ! kao_runtime_tx_check_consistency "${txid}" >/dev/null; then
    kao_runtime_tx_release_lock
    printf 'ERROR: transaction consistency check failed\n' >&2
    return 1
  fi

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "committing" \
    "apply-running" \
    "${resource_count}"

  kao_runtime_tx_apply_stage "${txid}" || {
    printf 'ERROR: transaction apply failed\n' >&2
    return 1
  }

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "committed" \
    "applied" \
    "${resource_count}" \
    "$(kao_runtime_tx_now_utc)"

  kao_runtime_tx_log "commit" "${txid}" "snapshot=${snapshot_id}"
  kao_runtime_tx_release_lock

  printf 'RUNTIME TRANSACTION COMMITTED : %s\n' "${txid}"
}

kao_runtime_tx_rollback() {
  local txid="${1:-}"
  local snapshot_id started_at resource_count

  snapshot_id="$(kao_runtime_tx_field "${txid}" SNAPSHOT_ID)"
  started_at="$(kao_runtime_tx_field "${txid}" STARTED_AT)"
  resource_count="$(kao_runtime_tx_resource_count "${txid}")"

  kao_runtime_tx_with_lock "${txid}" "runtime-tx-rollback" "kao transaction rollback" || return 1

  kao_snapshot_restore "${snapshot_id}" || {
    kao_runtime_tx_release_lock
    return 1
  }

  kao_runtime_tx_write_env \
    "${txid}" \
    "${started_at}" \
    "${snapshot_id}" \
    "rolled_back" \
    "reverted" \
    "${resource_count}" \
    "" \
    "$(kao_runtime_tx_now_utc)"

  kao_runtime_tx_log "rollback" "${txid}" "snapshot=${snapshot_id}"
  kao_runtime_tx_release_lock

  printf 'RUNTIME TRANSACTION ROLLED BACK : %s\n' "${txid}"
}

kao_runtime_tx_status() {
  local lock_state
  local txdir txid state barrier_state resource_count snapshot_id
  local tx_found=0

  printf 'RUNTIME TRANSACTION STATUS\n'

  lock_state="$(kao_runtime_lock_state 2>/dev/null || printf 'unknown')"
  printf 'lock         : %s\n' "${lock_state}"
  if [ "${lock_state}" != "free" ]; then
    printf 'lock owner   : %s\n' "$(kao_runtime_lock_owner_label 2>/dev/null || printf 'unknown')"
    printf 'lock kind    : %s\n' "$(kao_runtime_lock_owner_kind 2>/dev/null || printf 'unknown')"
    printf 'lock txid    : %s\n' "$(kao_runtime_lock_txid 2>/dev/null || printf 'none')"
    printf 'lock command : %s\n' "$(kao_runtime_lock_command 2>/dev/null || printf 'unknown')"
  fi

  if [ ! -d "${RUNTIME_TX_DIR}" ]; then
    return 0
  fi

  while IFS= read -r txdir; do
    [ -d "${txdir}" ] || continue
    tx_found=1

    txid="$(basename "${txdir}")"
    state="$(kao_runtime_tx_field "${txid}" "STATE" || true)"
    barrier_state="$(kao_runtime_tx_field "${txid}" "BARRIER_STATE" || true)"
    resource_count="$(kao_runtime_tx_field "${txid}" "RESOURCE_COUNT" || true)"
    snapshot_id="$(kao_runtime_tx_field "${txid}" "SNAPSHOT_ID" || true)"

    printf '\n'
    printf 'txid           : %s\n' "${txid}"
    printf 'state          : %s\n' "${state:-unknown}"
    printf 'barrier_state  : %s\n' "${barrier_state:-unknown}"
    printf 'resource_count : %s\n' "${resource_count:-0}"
    printf 'snapshot_id    : %s\n' "${snapshot_id:-none}"
  done < <(find "${RUNTIME_TX_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

  return 0
}
