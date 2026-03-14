#!/usr/bin/env bash

# shellcheck disable=SC1091
. "/home/kao/lib/system/local_paths_registry.sh"

kao_system_check_path_state() {
  local expected_type path

  expected_type="${1:-}"
  path="${2:-}"

  if [ ! -e "${path}" ]; then
    printf 'MISSING\n'
    return 0
  fi

  case "${expected_type}" in
    dir)
      if [ ! -d "${path}" ]; then
        printf 'TYPE-MISMATCH\n'
        return 0
      fi
      ;;
    file)
      if [ ! -f "${path}" ]; then
        printf 'TYPE-MISMATCH\n'
        return 0
      fi
      ;;
    *)
      printf 'TYPE-MISMATCH\n'
      return 0
      ;;
  esac

  if [ ! -r "${path}" ]; then
    printf 'UNREADABLE\n'
    return 0
  fi

  printf 'OK\n'
}

kao_system_path_owner() {
  local path
  path="${1:-}"

  if [ ! -e "${path}" ]; then
    printf 'n/a\n'
    return 0
  fi

  stat -c '%U' "${path}"
}

kao_system_path_group() {
  local path
  path="${1:-}"

  if [ ! -e "${path}" ]; then
    printf 'n/a\n'
    return 0
  fi

  stat -c '%G' "${path}"
}

kao_system_path_mode() {
  local path
  path="${1:-}"

  if [ ! -e "${path}" ]; then
    printf 'n/a\n'
    return 0
  fi

  stat -c '%a' "${path}"
}

kao_system_check_metadata_drift() {
  local path expected_owner expected_group expected_mode actual_owner actual_group actual_mode drift_parts

  path="${1:-}"
  expected_owner="${2:-}"
  expected_group="${3:-}"
  expected_mode="${4:-}"

  if [ ! -e "${path}" ]; then
    printf 'n/a\n'
    return 0
  fi

  actual_owner="$(kao_system_path_owner "${path}")"
  actual_group="$(kao_system_path_group "${path}")"
  actual_mode="$(kao_system_path_mode "${path}")"
  drift_parts=""

  if [ "${actual_owner}" != "${expected_owner}" ]; then
    drift_parts="owner"
  fi

  if [ "${actual_group}" != "${expected_group}" ]; then
    if [ -n "${drift_parts}" ]; then
      drift_parts="${drift_parts},group"
    else
      drift_parts="group"
    fi
  fi

  if [ "${actual_mode}" != "${expected_mode}" ]; then
    if [ -n "${drift_parts}" ]; then
      drift_parts="${drift_parts},mode"
    else
      drift_parts="mode"
    fi
  fi

  if [ -z "${drift_parts}" ]; then
    printf 'OK\n'
    return 0
  fi

  printf 'DRIFT:%s\n' "${drift_parts}"
}

kao_system_inspect_local_paths() {
  local label expected_type path expected_owner expected_group expected_mode state owner group mode drift

  while IFS='|' read -r label expected_type path expected_owner expected_group expected_mode; do
    [ -n "${label}" ] || continue
    state="$(kao_system_check_path_state "${expected_type}" "${path}")"
    owner="$(kao_system_path_owner "${path}")"
    group="$(kao_system_path_group "${path}")"
    mode="$(kao_system_path_mode "${path}")"
    drift="$(kao_system_check_metadata_drift "${path}" "${expected_owner}" "${expected_group}" "${expected_mode}")"
    printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
      "${label}" \
      "${expected_type}" \
      "${path}" \
      "${state}" \
      "${owner}" \
      "${group}" \
      "${mode}" \
      "${expected_owner}" \
      "${expected_group}" \
      "${expected_mode}|${drift}"
  done <<EOF_PATHS
$(kao_local_paths_expected_metadata_list)
EOF_PATHS
}

kao_system_render_inspection() {
  local label _expected_type path state owner group mode expected_owner expected_group expected_mode drift

  printf 'LOCAL SYSTEM INSPECTION\n\n'

  while IFS='|' read -r label _expected_type path state owner group mode expected_owner expected_group expected_mode drift; do
    [ -n "${label}" ] || continue
    printf '%-16s : %s | owner %s:%s | mode %s | expected %s:%s %s | drift %s | path %s\n' \
      "${label}" \
      "${state}" \
      "${owner}" \
      "${group}" \
      "${mode}" \
      "${expected_owner}" \
      "${expected_group}" \
      "${expected_mode}" \
      "${drift}" \
      "${path}"
  done <<EOF_RESULTS
$(kao_system_inspect_local_paths)
EOF_RESULTS
}
