#!/usr/bin/env bash

# REKON-LEGACY-CANDIDATE: historical runtime identity layer (owner/user/source-runtime model).
# TODO(REKON): decide whether this file becomes compat-layer, merged identity module, or is retired after canonisation.

kao_runtime_require_context() {
  if [ -z "${KROOT:-}" ]; then
    printf 'ERROR: KROOT is required for runtime context\n' >&2
    return 1
  fi

  KAO_RUNTIME_STATE_DIR="${KROOT}/state/runtime"
  KAO_RUNTIME_LOG_DIR="${KROOT}/state/logs"
  KAO_RUNTIME_LOG_FILE="${KAO_RUNTIME_LOG_DIR}/runtime.log"
  KAO_RUNTIME_STATUS_FILE="${KAO_RUNTIME_STATE_DIR}/runtime.state"
  KAO_RUNTIME_SNAPSHOT_FILE="${KAO_RUNTIME_STATE_DIR}/runtime.snapshot"
}

kao_runtime_now() {
  date '+%Y-%m-%d %H:%M:%S'
}

kao_runtime_log() {
  local message
  message="${1:-}"

  kao_runtime_require_context || return 1
  mkdir -p "${KAO_RUNTIME_LOG_DIR}"

  printf '%s | %s\n' "$(kao_runtime_now)" "${message}" >> "${KAO_RUNTIME_LOG_FILE}"
}

kao_runtime_init_state_dir() {
  kao_runtime_require_context || return 1
  mkdir -p "${KAO_RUNTIME_STATE_DIR}" "${KAO_RUNTIME_LOG_DIR}"
}

kao_runtime_owner_cache_file() {
  printf '%s/config/owner.env' "${KROOT}"
}

kao_runtime_user_source_file() {
  printf '%s/config/user.env' "${KROOT}"
}

kao_runtime_user_state_flag_file() {
  printf '%s/config/user.state' "${KROOT}"
}

kao_runtime_user_name() {
  local user_env_file
  user_env_file="$(kao_runtime_user_source_file)"

  if [ ! -f "${user_env_file}" ]; then
    printf 'none'
    return 0
  fi

  awk -F= '/^KAO_USER_NAME=/{print $2; exit}' "${user_env_file}" 2>/dev/null | sed 's/^"//; s/"$//' | sed "s/^'//; s/'$//" | {
    read -r value || true
    if [ -n "${value:-}" ]; then
      printf '%s' "${value}"
    else
      printf 'unknown'
    fi
  }
}

kao_runtime_active_actor() {
  local user_state_file
  user_state_file="$(kao_runtime_user_state_flag_file)"

  if [ -f "${user_state_file}" ]; then
    if grep -Eq '^KAO_USER_ACTIVE=1$' "${user_state_file}" 2>/dev/null; then
      printf 'user'
      return 0
    fi
  fi

  printf 'owner'
}

kao_runtime_owner_status() {
  local owner_env_file
  owner_env_file="$(kao_runtime_owner_cache_file)"

  if [ ! -f "${owner_env_file}" ]; then
    printf 'MISSING'
    return 0
  fi

  if ! env -i bash -n "${owner_env_file}" >/dev/null 2>&1; then
    printf 'INVALID'
    return 0
  fi

  printf 'READY'
}

kao_runtime_user_source_status() {
  local user_env_file
  user_env_file="$(kao_runtime_user_source_file)"

  if [ ! -f "${user_env_file}" ]; then
    printf 'ABSENT'
    return 0
  fi

  if ! env -i bash -n "${user_env_file}" >/dev/null 2>&1; then
    printf 'INVALID'
    return 0
  fi

  if ! grep -Eq '^KAO_USER_NAME=' "${user_env_file}" 2>/dev/null; then
    printf 'INVALID'
    return 0
  fi

  printf 'READY'
}

kao_runtime_snapshot_status() {
  kao_runtime_require_context || return 1

  if [ -f "${KAO_RUNTIME_SNAPSHOT_FILE}" ]; then
    printf 'PRESENT'
  else
    printf 'ABSENT'
  fi
}

kao_runtime_health_status() {
  local owner_status user_status actor
  owner_status="$(kao_runtime_owner_status)"
  user_status="$(kao_runtime_user_source_status)"
  actor="$(kao_runtime_active_actor)"

  case "${owner_status}" in
    READY) ;;
    *)
      printf 'DRIFT'
      return 0
      ;;
  esac

  case "${actor}:${user_status}" in
    owner:*)
      printf 'STABLE'
      ;;
    user:READY)
      printf 'STABLE'
      ;;
    user:ABSENT|user:INVALID)
      printf 'DRIFT'
      ;;
    *)
      printf 'UNKNOWN'
      ;;
  esac
}

kao_runtime_write_status_file() {
  local actor owner_status user_status snapshot_status health_status user_name
  kao_runtime_init_state_dir || return 1

  actor="$(kao_runtime_active_actor)"
  owner_status="$(kao_runtime_owner_status)"
  user_status="$(kao_runtime_user_source_status)"
  snapshot_status="$(kao_runtime_snapshot_status)"
  health_status="$(kao_runtime_health_status)"
  user_name="$(kao_runtime_user_name)"

  {
    printf 'KAO_RUNTIME_ACTIVE_ACTOR=%s\n' "${actor}"
    printf 'KAO_RUNTIME_OWNER_STATUS=%s\n' "${owner_status}"
    printf 'KAO_RUNTIME_USER_SOURCE_STATUS=%s\n' "${user_status}"
    printf 'KAO_RUNTIME_USER_NAME=%s\n' "${user_name}"
    printf 'KAO_RUNTIME_SNAPSHOT_STATUS=%s\n' "${snapshot_status}"
    printf 'KAO_RUNTIME_HEALTH=%s\n' "${health_status}"
  } > "${KAO_RUNTIME_STATUS_FILE}"
}

kao_runtime_print_status() {
  local actor owner_status user_status snapshot_status health_status user_name
  actor="$(kao_runtime_active_actor)"
  owner_status="$(kao_runtime_owner_status)"
  user_status="$(kao_runtime_user_source_status)"
  snapshot_status="$(kao_runtime_snapshot_status)"
  health_status="$(kao_runtime_health_status)"
  user_name="$(kao_runtime_user_name)"

  printf 'RUNTIME ACTIVE ACTOR : %s\n' "${actor}"
  printf 'OWNER CACHE STATUS   : %s\n' "${owner_status}"
  printf 'USER SOURCE STATUS   : %s\n' "${user_status}"
  printf 'USER NAME            : %s\n' "${user_name}"
  printf 'SNAPSHOT STATUS      : %s\n' "${snapshot_status}"
  printf 'RUNTIME HEALTH       : %s\n' "${health_status}"
}

kao_runtime_status() {
  kao_runtime_write_status_file || return 1
  kao_runtime_log "runtime status actor=$(kao_runtime_active_actor) owner=$(kao_runtime_owner_status) user=$(kao_runtime_user_source_status) user_name=$(kao_runtime_user_name) snapshot=$(kao_runtime_snapshot_status) health=$(kao_runtime_health_status)"
  kao_runtime_print_status
}

kao_runtime_snapshot() {
  local actor owner_status user_status snapshot_status health_status user_name
  kao_runtime_init_state_dir || return 1

  actor="$(kao_runtime_active_actor)"
  owner_status="$(kao_runtime_owner_status)"
  user_status="$(kao_runtime_user_source_status)"
  snapshot_status="$(kao_runtime_snapshot_status)"
  health_status="$(kao_runtime_health_status)"
  user_name="$(kao_runtime_user_name)"

  {
    printf 'SNAPSHOT_AT=%s\n' "$(kao_runtime_now)"
    printf 'KAO_RUNTIME_ACTIVE_ACTOR=%s\n' "${actor}"
    printf 'KAO_RUNTIME_OWNER_STATUS=%s\n' "${owner_status}"
    printf 'KAO_RUNTIME_USER_SOURCE_STATUS=%s\n' "${user_status}"
    printf 'KAO_RUNTIME_USER_NAME=%s\n' "${user_name}"
    printf 'KAO_RUNTIME_SNAPSHOT_STATUS=%s\n' "${snapshot_status}"
    printf 'KAO_RUNTIME_HEALTH=%s\n' "${health_status}"
  } > "${KAO_RUNTIME_SNAPSHOT_FILE}"

  kao_runtime_log "runtime snapshot actor=${actor} owner=${owner_status} user=${user_status} user_name=${user_name} health=${health_status}"
  printf 'SNAPSHOT WRITTEN: %s\n' "${KAO_RUNTIME_SNAPSHOT_FILE}"
}

kao_runtime_diff() {
  kao_runtime_require_context || return 1

  if [ ! -f "${KAO_RUNTIME_SNAPSHOT_FILE}" ]; then
    printf 'ERROR: missing runtime snapshot: %s\n' "${KAO_RUNTIME_SNAPSHOT_FILE}" >&2
    return 1
  fi

  local current_file
  current_file="$(mktemp "/tmp/kao-runtime-current.XXXXXX")"

  {
    printf 'SNAPSHOT_AT=CURRENT\n'
    printf 'KAO_RUNTIME_ACTIVE_ACTOR=%s\n' "$(kao_runtime_active_actor)"
    printf 'KAO_RUNTIME_OWNER_STATUS=%s\n' "$(kao_runtime_owner_status)"
    printf 'KAO_RUNTIME_USER_SOURCE_STATUS=%s\n' "$(kao_runtime_user_source_status)"
    printf 'KAO_RUNTIME_USER_NAME=%s\n' "$(kao_runtime_user_name)"
    printf 'KAO_RUNTIME_SNAPSHOT_STATUS=%s\n' "$(kao_runtime_snapshot_status)"
    printf 'KAO_RUNTIME_HEALTH=%s\n' "$(kao_runtime_health_status)"
  } > "${current_file}"

  if diff -u "${KAO_RUNTIME_SNAPSHOT_FILE}" "${current_file}"; then
    :
  else
    :
  fi

  rm -f "${current_file}"
  kao_runtime_log "runtime diff executed"
}

kao_runtime_activate_user() {
  local user_env_file user_state_file user_name
  user_env_file="$(kao_runtime_user_source_file)"
  user_state_file="$(kao_runtime_user_state_flag_file)"

  kao_runtime_init_state_dir || return 1

  case "$(kao_runtime_user_source_status)" in
    READY) ;;
    ABSENT)
      printf 'ERROR: missing user runtime source: %s\n' "${user_env_file}" >&2
      return 1
      ;;
    INVALID)
      printf 'ERROR: invalid user runtime source: %s\n' "${user_env_file}" >&2
      return 1
      ;;
    *)
      printf 'ERROR: unknown user source state\n' >&2
      return 1
      ;;
  esac

  user_name="$(kao_runtime_user_name)"

  {
    printf 'KAO_USER_ACTIVE=1\n'
    printf 'KAO_RUNTIME_ACTOR=user\n'
    printf 'KAO_RUNTIME_USER_NAME=%s\n' "${user_name}"
    printf 'KAO_RUNTIME_ACTIVATED_AT=%s\n' "$(kao_runtime_now)"
  } > "${user_state_file}"

  kao_runtime_write_status_file || return 1
  kao_runtime_log "runtime activate user name=${user_name}"
  printf 'RUNTIME ACTIVATED: user\n'
  kao_runtime_print_status
}

kao_runtime_deactivate() {
  local user_state_file
  user_state_file="$(kao_runtime_user_state_flag_file)"

  kao_runtime_init_state_dir || return 1

  rm -f "${user_state_file}"
  kao_runtime_write_status_file || return 1

  kao_runtime_log "runtime deactivate -> owner baseline"
  printf 'RUNTIME DEACTIVATED: owner baseline restored\n'
  kao_runtime_print_status
}

kao_runtime_repair() {
  local user_state_file
  user_state_file="$(kao_runtime_user_state_flag_file)"

  kao_runtime_init_state_dir || return 1

  rm -f "${user_state_file}"
  kao_runtime_write_status_file || return 1

  kao_runtime_log "runtime repair -> forced owner baseline"
  printf 'RUNTIME REPAIRED: owner baseline restored\n'
  kao_runtime_print_status
}
