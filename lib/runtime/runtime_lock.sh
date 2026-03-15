#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_LOCK_DIR="${RUNTIME_DIR}/.lock"

kao_runtime_lock_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_runtime_lock_require_paths() {
  mkdir -p "${RUNTIME_DIR}"
}

kao_runtime_lock_pid_is_alive() {
  local pid="${1:-}"

  [ -n "${pid}" ] || return 1
  kill -0 "${pid}" 2>/dev/null
}

kao_runtime_lock_meta_file() {
  local key="${1:-}"
  [ -n "${key}" ] || return 1
  printf '%s/%s\n' "${RUNTIME_LOCK_DIR}" "${key}"
}

kao_runtime_lock_read_meta() {
  local key="${1:-}"
  local file

  [ -n "${key}" ] || return 1
  file="$(kao_runtime_lock_meta_file "${key}")"

  [ -f "${file}" ] || return 1
  tr -d '\n' < "${file}"
}

kao_runtime_lock_read_pid() {
  kao_runtime_lock_read_meta "pid"
}

kao_runtime_lock_state() {
  if ! kao_runtime_lock_is_held; then
    printf 'free\n'
    return 0
  fi

  if kao_runtime_lock_is_orphan; then
    printf 'orphan\n'
    return 0
  fi

  printf '%s\n' "$(kao_runtime_lock_read_meta "state" 2>/dev/null || printf 'active')"
}

kao_runtime_lock_is_held() {
  [ -d "${RUNTIME_LOCK_DIR}" ]
}

kao_runtime_lock_is_orphan() {
  local pid

  kao_runtime_lock_is_held || return 1

  pid="$(kao_runtime_lock_read_pid || true)"

  if [ -z "${pid}" ]; then
    return 0
  fi

  if kao_runtime_lock_pid_is_alive "${pid}"; then
    return 1
  fi

  return 0
}

kao_runtime_lock_owner_pid() {
  local pid
  pid="$(kao_runtime_lock_read_pid || true)"

  if [ -n "${pid}" ]; then
    printf '%s\n' "${pid}"
  else
    printf 'unknown\n'
  fi
}

kao_runtime_lock_owner_kind() {
  kao_runtime_lock_read_meta "owner_kind" 2>/dev/null || printf 'unknown\n'
}

kao_runtime_lock_owner_label() {
  kao_runtime_lock_read_meta "owner_label" 2>/dev/null || printf 'unknown\n'
}

kao_runtime_lock_txid() {
  kao_runtime_lock_read_meta "txid" 2>/dev/null || printf 'none\n'
}

kao_runtime_lock_command() {
  kao_runtime_lock_read_meta "command" 2>/dev/null || printf 'unknown\n'
}

kao_runtime_lock_write_metadata() {
  local owner_kind="${1:-runtime}"
  local owner_label="${2:-unknown}"
  local txid="${3:-none}"
  local command="${4:-unknown}"

  {
    printf '%s\n' "$$"
  } > "$(kao_runtime_lock_meta_file "pid")"

  {
    printf '%s\n' "$(kao_runtime_lock_now_utc)"
  } > "$(kao_runtime_lock_meta_file "created_at")"

  {
    printf 'active\n'
  } > "$(kao_runtime_lock_meta_file "state")"

  {
    printf '%s\n' "${owner_kind}"
  } > "$(kao_runtime_lock_meta_file "owner_kind")"

  {
    printf '%s\n' "${owner_label}"
  } > "$(kao_runtime_lock_meta_file "owner_label")"

  {
    printf '%s\n' "${txid}"
  } > "$(kao_runtime_lock_meta_file "txid")"

  {
    printf '%s\n' "${command}"
  } > "$(kao_runtime_lock_meta_file "command")"
}

kao_runtime_lock_acquire() {
  local waited=0
  local max_wait_loops="${1:-50}"
  local owner_kind="${2:-runtime}"
  local owner_label="${3:-unknown}"
  local txid="${4:-none}"
  local command="${5:-unknown}"

  kao_runtime_lock_require_paths

  while ! mkdir "${RUNTIME_LOCK_DIR}" 2>/dev/null; do
    if kao_runtime_lock_is_orphan; then
      printf 'WARN: orphan runtime lock detected, recovering\n' >&2
      kao_runtime_lock_recover_orphan || {
        printf 'ERROR: failed to recover orphan runtime lock\n' >&2
        return 1
      }
      continue
    fi

    waited=$((waited + 1))
    if [ "${waited}" -ge "${max_wait_loops}" ]; then
      printf 'ERROR: runtime lock busy\n' >&2
      return 1
    fi
    sleep 0.1
  done

  kao_runtime_lock_write_metadata "${owner_kind}" "${owner_label}" "${txid}" "${command}"
}

kao_runtime_lock_release() {
  rm -rf "${RUNTIME_LOCK_DIR}"
}

kao_runtime_lock_recover_orphan() {
  kao_runtime_lock_is_held || return 0
  kao_runtime_lock_is_orphan || return 1

  rm -rf "${RUNTIME_LOCK_DIR}"
}

kao_runtime_lock_status() {
  printf 'RUNTIME LOCK STATUS\n'

  if ! kao_runtime_lock_is_held; then
    printf 'lock       : free\n'
    return 0
  fi

  printf 'lock       : held\n'
  printf 'state      : %s\n' "$(kao_runtime_lock_state)"
  printf 'owner pid  : %s\n' "$(kao_runtime_lock_owner_pid)"
  printf 'owner kind : %s\n' "$(kao_runtime_lock_owner_kind)"
  printf 'owner      : %s\n' "$(kao_runtime_lock_owner_label)"
  printf 'txid       : %s\n' "$(kao_runtime_lock_txid)"
  printf 'command    : %s\n' "$(kao_runtime_lock_command)"

  if [ -f "${RUNTIME_LOCK_DIR}/created_at" ]; then
    printf 'created    : %s\n' "$(cat "${RUNTIME_LOCK_DIR}/created_at")"
  fi

  if kao_runtime_lock_is_orphan; then
    printf 'orphan     : yes\n'
  else
    printf 'orphan     : no\n'
  fi
}
