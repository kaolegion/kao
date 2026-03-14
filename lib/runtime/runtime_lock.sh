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

kao_runtime_lock_read_pid() {
  local pid_file="${RUNTIME_LOCK_DIR}/pid"

  [ -f "${pid_file}" ] || return 1
  tr -d '[:space:]' < "${pid_file}"
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

kao_runtime_lock_acquire() {
  local waited=0
  local max_wait_loops="${1:-50}"

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

  {
    printf '%s\n' "$$"
  } > "${RUNTIME_LOCK_DIR}/pid"

  {
    printf '%s\n' "$(kao_runtime_lock_now_utc)"
  } > "${RUNTIME_LOCK_DIR}/created_at"

  printf 'active\n' > "${RUNTIME_LOCK_DIR}/state"
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
    printf 'lock     : free\n'
    return 0
  fi

  printf 'lock     : held\n'
  printf 'owner    : %s\n' "$(kao_runtime_lock_owner_pid)"

  if [ -f "${RUNTIME_LOCK_DIR}/created_at" ]; then
    printf 'created  : %s\n' "$(cat "${RUNTIME_LOCK_DIR}/created_at")"
  fi

  if kao_runtime_lock_is_orphan; then
    printf 'orphan   : yes\n'
  else
    printf 'orphan   : no\n'
  fi
}
