#!/usr/bin/env bash

kao_owner_state_require_context() {
  : "${OWNER_ENV_FILE:?missing OWNER_ENV_FILE}"
  : "${OWNER_PROFILE_SELECTOR_FILE:?missing OWNER_PROFILE_SELECTOR_FILE}"
  : "${OWNER_PRESETS_DIR:?missing OWNER_PRESETS_DIR}"
  : "${OWNER_SELECTOR_OFF:?missing OWNER_SELECTOR_OFF}"
}

kao_owner_resolve_exports() {
  local env_file
  env_file="$1"

  if [ ! -f "${env_file}" ]; then
    return 1
  fi

  if ! env -i bash -n "${env_file}" >/dev/null 2>&1; then
    return 1
  fi

  env -i bash -c '
    set -euo pipefail
    . "$1"
    for key in \
      KAO_OWNER_NAME \
      KAO_OWNER_ROLE \
      KAO_OWNER_ID \
      KAO_OWNER_TITLE \
      KAO_OWNER_HANDLE \
      KAO_OWNER_EMAIL \
      KAO_OWNER_ORG \
      KAO_OWNER_DOMAIN
    do
      eval "value=\${$key-}"
      if [ -n "${value}" ]; then
        printf "%s=%s\n" "${key}" "${value}"
      fi
    done
  ' bash "${env_file}" 2>/dev/null
}

kao_owner_read_selector_value() {
  if [ ! -f "${OWNER_PROFILE_SELECTOR_FILE}" ]; then
    return 1
  fi

  sed -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d' "${OWNER_PROFILE_SELECTOR_FILE}" | head -n 1
}

kao_owner_get_preset_path() {
  local preset_name
  preset_name="$1"
  printf '%s/%s.env\n' "${OWNER_PRESETS_DIR}" "${preset_name}"
}

kao_owner_selector_raw_state() {
  if [ ! -f "${OWNER_PROFILE_SELECTOR_FILE}" ]; then
    printf 'missing'
    return 0
  fi

  local raw_trimmed
  raw_trimmed="$(sed -e 's/[[:space:]]*$//' "${OWNER_PROFILE_SELECTOR_FILE}" | tr -d '\r')"

  if [ -z "${raw_trimmed}" ]; then
    printf 'empty'
    return 0
  fi

  printf 'present'
}

kao_owner_selector_mode() {
  local raw_state selector_value target_path
  raw_state="$(kao_owner_selector_raw_state)"

  if [ "${raw_state}" = "missing" ]; then
    printf 'missing'
    return 0
  fi

  if [ "${raw_state}" = "empty" ]; then
    printf 'empty'
    return 0
  fi

  selector_value="$(kao_owner_read_selector_value 2>/dev/null || true)"

  if [ -z "${selector_value}" ]; then
    printf 'empty'
    return 0
  fi

  if [ "${selector_value}" = "${OWNER_SELECTOR_OFF}" ]; then
    printf 'off'
    return 0
  fi

  target_path="$(kao_owner_get_preset_path "${selector_value}")"

  if [ ! -f "${target_path}" ]; then
    printf 'target-missing'
    return 0
  fi

  if ! kao_owner_resolve_exports "${target_path}" >/dev/null 2>&1; then
    printf 'target-invalid'
    return 0
  fi

  printf 'target-valid'
}

kao_owner_selector_status_label() {
  local mode
  mode="$(kao_owner_selector_mode)"

  case "${mode}" in
    missing) printf 'missing' ;;
    empty) printf 'empty' ;;
    off) printf 'deactivated' ;;
    target-missing) printf 'present -> target missing' ;;
    target-invalid) printf 'present -> target invalid' ;;
    target-valid) printf 'present -> target valid' ;;
    *) printf 'unknown' ;;
  esac
}

kao_owner_selector_target_path() {
  local selector_value mode
  mode="$(kao_owner_selector_mode)"
  selector_value="$(kao_owner_read_selector_value 2>/dev/null || true)"

  case "${mode}" in
    target-missing|target-invalid|target-valid)
      kao_owner_get_preset_path "${selector_value}"
      ;;
    *)
      printf 'none'
      ;;
  esac
}

kao_owner_runtime_cache_status() {
  local mode selector_value target_path
  mode="$(kao_owner_selector_mode)"
  selector_value="$(kao_owner_read_selector_value 2>/dev/null || true)"

  if [ ! -f "${OWNER_ENV_FILE}" ]; then
    printf 'missing'
    return 0
  fi

  if ! kao_owner_resolve_exports "${OWNER_ENV_FILE}" >/dev/null 2>&1; then
    printf 'invalid'
    return 0
  fi

  case "${mode}" in
    missing|empty)
      printf 'legacy-ready'
      return 0
      ;;
    off)
      printf 'retained'
      return 0
      ;;
    target-missing|target-invalid)
      printf 'stale'
      return 0
      ;;
  esac

  target_path="$(kao_owner_get_preset_path "${selector_value}")"

  if cmp -s "${OWNER_ENV_FILE}" "${target_path}" 2>/dev/null; then
    printf 'aligned'
  else
    printf 'rebuilt-or-diverged'
  fi
}

kao_owner_runtime_selector_relation() {
  local mode cache_status
  mode="$(kao_owner_selector_mode)"
  cache_status="$(kao_owner_runtime_cache_status)"

  case "${mode}:${cache_status}" in
    missing:legacy-ready|empty:legacy-ready)
      printf 'selector absent or empty -> runtime legacy fallback available'
      ;;
    off:retained)
      printf 'selector off -> runtime intentionally retained'
      ;;
    target-missing:stale)
      printf 'selector target missing -> runtime stale'
      ;;
    target-invalid:stale)
      printf 'selector target invalid -> runtime stale'
      ;;
    target-valid:aligned)
      printf 'selector and runtime aligned'
      ;;
    target-valid:rebuilt-or-diverged)
      printf 'selector valid but runtime diverged'
      ;;
    *:missing)
      printf 'runtime cache missing'
      ;;
    *:invalid)
      printf 'runtime cache invalid'
      ;;
    *)
      printf 'runtime relationship unknown'
      ;;
  esac
}

kao_owner_repair_hint_for_state() {
  local mode cache_status
  mode="$(kao_owner_selector_mode)"
  cache_status="$(kao_owner_runtime_cache_status)"

  case "${mode}:${cache_status}" in
    missing:legacy-ready)
      printf 'activate a preset or keep legacy fallback'
      ;;
    empty:legacy-ready)
      printf 'run: kao owner recover'
      ;;
    off:retained)
      printf 'run: kao owner recover to reactivate a valid preset'
      ;;
    target-missing:stale)
      printf 'restore preset or run: kao owner recover'
      ;;
    target-invalid:stale)
      printf 'repair preset file or run: kao owner recover'
      ;;
    target-valid:aligned)
      printf 'no repair needed'
      ;;
    target-valid:rebuilt-or-diverged)
      printf 'run: kao owner activate <preset> to realign runtime'
      ;;
    *:missing)
      printf 'run: kao owner activate <preset> or kao owner recover'
      ;;
    *:invalid)
      printf 'repair runtime or reactivate a valid preset'
      ;;
    *)
      printf 'inspect selector, runtime and presets'
      ;;
  esac
}

kao_owner_repair_action_for_state() {
  local mode cache_status
  mode="$(kao_owner_selector_mode)"
  cache_status="$(kao_owner_runtime_cache_status)"

  case "${mode}:${cache_status}" in
    missing:legacy-ready)
      printf 'KEEP_OR_ACTIVATE'
      ;;
    empty:legacy-ready)
      printf 'RECOVER_SELECTOR'
      ;;
    off:retained)
      printf 'RECOVER_FROM_OFF'
      ;;
    target-missing:stale)
      printf 'RECOVER_TARGET_MISSING'
      ;;
    target-invalid:stale)
      printf 'RECOVER_TARGET_INVALID'
      ;;
    target-valid:aligned)
      printf 'NONE'
      ;;
    target-valid:rebuilt-or-diverged)
      printf 'REALIGN_RUNTIME'
      ;;
    *:missing)
      printf 'REBUILD_RUNTIME'
      ;;
    *:invalid)
      printf 'REPAIR_RUNTIME'
      ;;
    *)
      printf 'INSPECT'
      ;;
  esac
}

kao_owner_result_state_for_state() {
  local mode cache_status
  mode="$(kao_owner_selector_mode)"
  cache_status="$(kao_owner_runtime_cache_status)"

  case "${mode}:${cache_status}" in
    missing:legacy-ready)
      printf 'ABSENT'
      ;;
    empty:legacy-ready)
      printf 'INVALID'
      ;;
    off:retained)
      printf 'DEACTIVATED'
      ;;
    target-missing:stale|target-invalid:stale)
      printf 'INVALID'
      ;;
    target-valid:aligned|target-valid:rebuilt-or-diverged)
      printf 'ACTIVE'
      ;;
    *:missing|*:invalid)
      printf 'INVALID'
      ;;
    *)
      printf 'UNKNOWN'
      ;;
  esac
}

kao_owner_policy_state_for_transition() {
  local before_action after_action
  before_action="${1:-}"
  after_action="${2:-}"

  if [ -z "${before_action}" ] || [ -z "${after_action}" ]; then
    printf 'UNKNOWN'
    return 0
  fi

  if [ "${before_action}" = "${after_action}" ]; then
    if [ "${after_action}" = "NONE" ]; then
      printf 'NOOP'
    else
      printf 'REFUSED'
    fi
    return 0
  fi

  case "${after_action}" in
    NONE)
      if [ "${before_action}" = "NONE" ]; then
        printf 'NOOP'
      else
        printf 'REPAIR'
      fi
      ;;
    KEEP_OR_ACTIVATE|RECOVER_SELECTOR|RECOVER_FROM_OFF|RECOVER_TARGET_MISSING|RECOVER_TARGET_INVALID|REALIGN_RUNTIME|REBUILD_RUNTIME|REPAIR_RUNTIME)
      printf 'REPAIR'
      ;;
    INSPECT|UNKNOWN)
      printf 'REFUSED'
      ;;
    *)
      printf 'SUCCESS'
      ;;
  esac
}

kao_owner_list_valid_presets() {
  mkdir -p "${OWNER_PRESETS_DIR}"

  local preset_file preset_name preset_path
  while IFS= read -r preset_file; do
    [ -n "${preset_file}" ] || continue
    preset_name="$(basename "${preset_file}" .env)"
    preset_path="$(kao_owner_get_preset_path "${preset_name}")"
    if kao_owner_resolve_exports "${preset_path}" >/dev/null 2>&1; then
      printf '%s\n' "${preset_name}"
    fi
  done < <(find "${OWNER_PRESETS_DIR}" -maxdepth 1 -type f -name '*.env' | LC_ALL=C sort)
}

kao_owner_choose_recovery_preset() {
  local valid_count first_valid preset_name
  valid_count=0
  first_valid=""

  while IFS= read -r preset_name; do
    [ -n "${preset_name}" ] || continue
    valid_count=$((valid_count + 1))
    if [ -z "${first_valid}" ]; then
      first_valid="${preset_name}"
    fi
  done < <(kao_owner_list_valid_presets)

  if [ "${valid_count}" -ge 1 ]; then
    printf '%s' "${first_valid}"
    return 0
  fi

  return 1
}

kao_owner_apply_exports_to_env() {
  local owner_exports
  owner_exports="$1"

  while IFS='=' read -r key value; do
    [ -n "${key}" ] || continue
    case "${key}" in
      KAO_OWNER_NAME) KAO_OWNER_NAME="${value}" ;;
      KAO_OWNER_ROLE) KAO_OWNER_ROLE="${value}" ;;
      KAO_OWNER_ID) KAO_OWNER_ID="${value}" ;;
      KAO_OWNER_TITLE) KAO_OWNER_TITLE="${value}" ;;
      KAO_OWNER_HANDLE) KAO_OWNER_HANDLE="${value}" ;;
      KAO_OWNER_EMAIL) KAO_OWNER_EMAIL="${value}" ;;
      KAO_OWNER_ORG) KAO_OWNER_ORG="${value}" ;;
      KAO_OWNER_DOMAIN) KAO_OWNER_DOMAIN="${value}" ;;
    esac
  done <<EOF_OWNER_EXPORTS
${owner_exports}
EOF_OWNER_EXPORTS
}

kao_owner_available_presets_csv() {
  if [ ! -d "${OWNER_PRESETS_DIR}" ]; then
    printf 'none'
    return 0
  fi

  local csv
  csv="$(
    find "${OWNER_PRESETS_DIR}" -maxdepth 1 -type f -name '*.env' -printf '%f\n' 2>/dev/null \
      | LC_ALL=C sort \
      | sed 's/\.env$//' \
      | paste -sd ',' -
  )"

  if [ -z "${csv}" ]; then
    printf 'none'
  else
    printf '%s' "${csv}"
  fi
}

kao_owner_emit_state_kv() {
  local selector_mode runtime_cache selector_value selector_target status_label runtime_link
  local repair_hint repair_action result_state available_presets

  selector_mode="$(kao_owner_selector_mode)"
  runtime_cache="$(kao_owner_runtime_cache_status)"
  selector_value="$(kao_owner_read_selector_value 2>/dev/null || true)"
  selector_target="$(kao_owner_selector_target_path)"
  status_label="$(kao_owner_selector_status_label)"
  runtime_link="$(kao_owner_runtime_selector_relation)"
  repair_hint="$(kao_owner_repair_hint_for_state)"
  repair_action="$(kao_owner_repair_action_for_state)"
  result_state="$(kao_owner_result_state_for_state)"
  available_presets="$(kao_owner_available_presets_csv)"

  printf 'selector_raw_state=%s\n' "$(kao_owner_selector_raw_state)"
  printf 'selector_mode=%s\n' "${selector_mode}"
  printf 'selector_value=%s\n' "${selector_value}"
  printf 'selector_target=%s\n' "${selector_target}"
  printf 'selector_status_label=%s\n' "${status_label}"
  printf 'runtime_cache_status=%s\n' "${runtime_cache}"
  printf 'runtime_selector_relation=%s\n' "${runtime_link}"
  printf 'repair_hint=%s\n' "${repair_hint}"
  printf 'repair_action=%s\n' "${repair_action}"
  printf 'result_state=%s\n' "${result_state}"
  printf 'available_presets=%s\n' "${available_presets}"
}
