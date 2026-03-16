#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"

check_transaction_integrity() {
  local txdir="${RUNTIME_DIR}/.tx"
  [ -d "${txdir}" ] || return 0

  local tx state barrier env_file manifest_file wal_file resource_count manifest_count

  for tx in "${txdir}"/*; do
    [ -d "${tx}" ] || continue

    env_file="${tx}/transaction.env"
    manifest_file="${tx}/resources.manifest"
    wal_file="${tx}/wal/runtime.wal"

    [ -f "${env_file}" ] || return 1

    state="$(awk -F= '$1=="STATE"{print substr($0,index($0,"=")+1); exit}' "${env_file}")"
    barrier="$(awk -F= '$1=="BARRIER_STATE"{print substr($0,index($0,"=")+1); exit}' "${env_file}")"
    resource_count="$(awk -F= '$1=="RESOURCE_COUNT"{print substr($0,index($0,"=")+1); exit}' "${env_file}")"

    [ -n "${state}" ] || return 1
    [ -n "${barrier}" ] || return 1
    [ -n "${resource_count}" ] || resource_count="0"

    if [ -f "${manifest_file}" ]; then
      manifest_count="$(awk 'NF { count++ } END { print count + 0 }' "${manifest_file}")"
    else
      manifest_count="0"
    fi

    case "${state}:${barrier}" in
      committed:none)
        if [ "${resource_count}" = "0" ]; then
          :
        else
          return 1
        fi
        ;;
      committed:applied|aborted:reverted|rolled_back:reverted)
        :
        ;;
      open:none|open:staged)
        if [ "${resource_count}" != "${manifest_count}" ]; then
          return 1
        fi
        ;;
      committing:staged|committing:apply-ready)
        return 1
        ;;
      committed:apply-running|committed:staged)
        return 1
        ;;
      aborted:*|rolled_back:*)
        :
        ;;
      *)
        return 1
        ;;
    esac

    if [ "${resource_count}" -gt 0 ]; then
      [ -f "${manifest_file}" ] || return 1
      [ -f "${wal_file}" ] || return 1
    fi
  done

  return 0
}

check_wal_integrity() {
  local journal="${RUNTIME_DIR}/runtime.journal"
  [ -f "${journal}" ] || return 0
  grep -q "PENDING" "${journal}" && return 1
  return 0
}

check_recovery_safety() {
  "${KROOT}/lib/runtime/runtime_recovery.sh" --dry-run >/dev/null 2>&1
}

check_runtime_writable() {
  touch "${RUNTIME_DIR}/.consistency.test" 2>/dev/null || return 1
  rm -f "${RUNTIME_DIR}/.consistency.test"
}

check_state_syntax() {
  grep -q "=" "${RUNTIME_DIR}/runtime.state" 2>/dev/null
}

kao_runtime_consistency_run() {
  local level="STRONG"
  local report=()

  ! check_transaction_integrity && level="BROKEN" && report+=("transaction integrity violation") || report+=("transaction integrity : OK")
  ! check_wal_integrity && level="BROKEN" && report+=("wal ordering violation") || report+=("wal integrity : OK")
  ! check_recovery_safety && level="BROKEN" && report+=("recovery safety violation") || report+=("recovery dry-run : OK")
  ! check_runtime_writable && level="BROKEN" && report+=("runtime not writable") || report+=("runtime writable : OK")
  ! check_state_syntax && level="BROKEN" && report+=("runtime.state syntax invalid") || report+=("runtime.state syntax : OK")

  echo "RUNTIME CONSISTENCY"
  echo "level : ${level}"
  echo ""
  echo "checks:"
  for line in "${report[@]}"; do
    echo " - ${line}"
  done
}

kao_runtime_consistency_cli() {
  case "${1:-status}" in
    status|"")
      kao_runtime_consistency_run
      ;;
    *)
      echo "usage: consistency [status]"
      return 1
      ;;
  esac
}
