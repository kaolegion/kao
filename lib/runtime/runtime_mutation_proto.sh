#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
MUTATION_PLAN_FILE="${RUNTIME_DIR}/mutation.plan"
MUTATION_SIM_FILE="${RUNTIME_DIR}/mutation.simulation"
MUTATION_LAST_FILE="${RUNTIME_DIR}/mutation.last"
MUTATION_ARCHIVE_DIR="${KROOT}/state/archive/mutations"

source "${KROOT}/lib/runtime/runtime_mutation.sh"

kao_mutation_proto_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_mutation_proto_require_paths() {
  mkdir -p "${RUNTIME_DIR}" "${MUTATION_ARCHIVE_DIR}"
}

kao_mutation_proto_reset_plan() {
  rm -f "${MUTATION_PLAN_FILE}" "${MUTATION_SIM_FILE}"
}

kao_mutation_proto_write_plan() {
  local target="${1:-}"
  local created_at

  [ -n "${target}" ] || {
    printf 'RAY_ERROR missing mutation target\n' >&2
    return 1
  }

  kao_mutation_proto_require_paths
  created_at="$(kao_mutation_proto_now_utc)"

  {
    printf 'FORMAT_VERSION=1\n'
    printf 'TARGET=%s\n' "${target}"
    printf 'CREATED_AT=%s\n' "${created_at}"
    printf 'STATUS=planned\n'
  } > "${MUTATION_PLAN_FILE}"

  {
    printf 'LAST_ACTION=propose\n'
    printf 'LAST_TARGET=%s\n' "${target}"
    printf 'LAST_AT=%s\n' "${created_at}"
  } > "${MUTATION_LAST_FILE}"

  printf 'MUTATION PLAN CREATED\n'
  printf 'target : %s\n' "${target}"
  printf 'plan   : %s\n' "${MUTATION_PLAN_FILE}"
}

kao_mutation_proto_plan_target() {
  [ -f "${MUTATION_PLAN_FILE}" ] || return 1
  sed -n 's/^TARGET=//p' "${MUTATION_PLAN_FILE}" | head -n 1
}

kao_mutation_proto_simulate() {
  local target simulated_at

  [ -f "${MUTATION_PLAN_FILE}" ] || {
    printf 'RAY_ERROR no mutation plan available\n' >&2
    return 1
  }

  target="$(kao_mutation_proto_plan_target)"
  simulated_at="$(kao_mutation_proto_now_utc)"

  {
    printf 'FORMAT_VERSION=1\n'
    printf 'TARGET=%s\n' "${target}"
    printf 'SIMULATED_AT=%s\n' "${simulated_at}"
    printf 'RESULT=dry-run-only\n'
    printf 'SOURCE_EXISTS='
    if [ -e "${target}" ]; then
      printf 'yes\n'
    else
      printf 'no\n'
    fi
    printf 'WRITE_ACTION=none\n'
    printf 'ROLLBACK_READY=no\n'
  } > "${MUTATION_SIM_FILE}"

  {
    printf 'LAST_ACTION=simulate\n'
    printf 'LAST_TARGET=%s\n' "${target}"
    printf 'LAST_AT=%s\n' "${simulated_at}"
  } > "${MUTATION_LAST_FILE}"

  printf 'MUTATION SIMULATION READY\n'
  printf 'target      : %s\n' "${target}"
  printf 'simulation  : %s\n' "${MUTATION_SIM_FILE}"
}

kao_mutation_proto_apply() {
  local target txid archive_dir applied_at

  [ -f "${MUTATION_PLAN_FILE}" ] || {
    printf "RAY_ERROR no mutation plan
" >&2
    return 1
  }

  target="$(kao_mutation_proto_plan_target)"
  [ -e "${target}" ] || {
    printf "RAY_ERROR target not found
" >&2
    return 1
  }

  txid="$(kao_runtime_mutation_begin)" || return 1

  archive_dir="${MUTATION_ARCHIVE_DIR}/${txid}"
  mkdir -p "${archive_dir}"

  cp -a "${target}" "${archive_dir}/preimage" || {
    printf "RAY_ERROR archive failed
" >&2
    return 1
  }

  printf "# mutation-test-tx
" >> "${target}"

  kao_runtime_mutation_commit "${txid}" || {
    printf "RAY_ERROR commit failed
" >&2
    return 1
  }

  applied_at="$(kao_mutation_proto_now_utc)"

  {
    printf "FORMAT_VERSION=1
"
    printf "TXID=%s
" "${txid}"
    printf "TARGET=%s
" "${target}"
    printf "ARCHIVE_DIR=%s
" "${archive_dir}"
    printf "APPLIED_AT=%s
" "${applied_at}"
    printf "STATUS=success
"
  } > "${archive_dir}/manifest"

  {
    printf "LAST_ACTION=apply-success
"
    printf "LAST_TARGET=%s
" "${target}"
    printf "LAST_AT=%s
" "${applied_at}"
  } > "${MUTATION_LAST_FILE}"

  printf "MUTATION APPLIED SUCCESSFULLY
"
  printf "txid    : %s
" "${txid}"
}



kao_mutation_proto_abort() {
  kao_mutation_proto_reset_plan

  {
    printf 'LAST_ACTION=abort\n'
    printf 'LAST_TARGET=none\n'
    printf 'LAST_AT=%s\n' "$(kao_mutation_proto_now_utc)"
  } > "${MUTATION_LAST_FILE}"

  printf 'MUTATION PLAN ABORTED\n'
}

kao_mutation_proto_rollback() {
  local last_manifest target archive_dir txid rollback_at

  last_manifest="$(grep -l "STATUS=success" ${MUTATION_ARCHIVE_DIR}/*/manifest | tail -n1)"
  [ -n "${last_manifest}" ] || {
    printf "RAY_ERROR no successful mutation found
" >&2
    return 1
  }

  txid="$(sed -n "s/^TXID=//p" "${last_manifest}")"
  target="$(sed -n "s/^TARGET=//p" "${last_manifest}")"
  archive_dir="$(sed -n "s/^ARCHIVE_DIR=//p" "${last_manifest}")"

  [ -e "${archive_dir}/preimage" ] || {
    printf "RAY_ERROR preimage missing
" >&2
    return 1
  }

  kao_runtime_mutation_begin || return 1

  cp -a "${archive_dir}/preimage" "${target}" || {
    printf "RAY_ERROR restore failed
" >&2
    return 1
  }

  kao_runtime_mutation_commit "${txid}" || {
    printf "RAY_ERROR rollback commit failed
" >&2
    return 1
  }

  rollback_at="$(kao_mutation_proto_now_utc)"

  sed -i "s/STATUS=success/STATUS=rolled_back/" "${last_manifest}"

  {
    printf "LAST_ACTION=rollback
"
    printf "LAST_TARGET=%s
" "${target}"
    printf "LAST_AT=%s
" "${rollback_at}"
  } > "${MUTATION_LAST_FILE}"

  printf "MUTATION ROLLED BACK
"
  printf "txid : %s
" "${txid}"
}

