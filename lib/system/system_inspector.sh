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

kao_system_repair_path_metadata() {
  local path expected_owner expected_group expected_mode dry_run
  local actual_owner actual_group actual_mode
  local owner_changed group_changed mode_changed

  path="${1:-}"
  expected_owner="${2:-}"
  expected_group="${3:-}"
  expected_mode="${4:-}"
  dry_run="${5:-0}"

  if [ ! -e "${path}" ]; then
    printf 'SKIP|missing-path\n'
    return 0
  fi

  actual_owner="$(kao_system_path_owner "${path}")"
  actual_group="$(kao_system_path_group "${path}")"
  actual_mode="$(kao_system_path_mode "${path}")"

  owner_changed="no"
  group_changed="no"
  mode_changed="no"

  if [ "${actual_owner}" != "${expected_owner}" ]; then
    if [ "${dry_run}" = "1" ]; then
      owner_changed="would-fix"
    else
      chown "${expected_owner}" "${path}"
      owner_changed="fixed"
    fi
  fi

  if [ "${actual_group}" != "${expected_group}" ]; then
    if [ "${dry_run}" = "1" ]; then
      group_changed="would-fix"
    else
      chgrp "${expected_group}" "${path}"
      group_changed="fixed"
    fi
  fi

  if [ "${actual_mode}" != "${expected_mode}" ]; then
    if [ "${dry_run}" = "1" ]; then
      mode_changed="would-fix"
    else
      chmod "${expected_mode}" "${path}"
      mode_changed="fixed"
    fi
  fi

  printf 'APPLY|owner=%s|group=%s|mode=%s\n' \
    "${owner_changed}" \
    "${group_changed}" \
    "${mode_changed}"
}

kao_system_repair_local_paths() {
  local dry_run
  local label expected_type path expected_owner expected_group expected_mode
  local state drift apply_result post_owner post_group post_mode post_drift

  dry_run="${1:-0}"

  printf 'LOCAL SYSTEM REPAIR\n\n'

  while IFS='|' read -r label expected_type path expected_owner expected_group expected_mode; do
    [ -n "${label}" ] || continue

    state="$(kao_system_check_path_state "${expected_type}" "${path}")"
    drift="$(kao_system_check_metadata_drift "${path}" "${expected_owner}" "${expected_group}" "${expected_mode}")"

    if [ "${state}" != "OK" ]; then
      printf '%-16s : SKIP | state %s | drift %s | reason non-repairable-state | path %s\n' \
        "${label}" \
        "${state}" \
        "${drift}" \
        "${path}"
      continue
    fi

    if [ "${drift}" = "OK" ]; then
      printf '%-16s : NOOP | state %s | drift %s | path %s\n' \
        "${label}" \
        "${state}" \
        "${drift}" \
        "${path}"
      continue
    fi

    apply_result="$(kao_system_repair_path_metadata "${path}" "${expected_owner}" "${expected_group}" "${expected_mode}" "${dry_run}")"
    post_owner="$(kao_system_path_owner "${path}")"
    post_group="$(kao_system_path_group "${path}")"
    post_mode="$(kao_system_path_mode "${path}")"
    post_drift="$(kao_system_check_metadata_drift "${path}" "${expected_owner}" "${expected_group}" "${expected_mode}")"

    if [ "${dry_run}" = "1" ]; then
      printf '%-16s : DRY-RUN | state %s | drift %s | %s | expected %s:%s %s | current %s:%s %s | path %s\n' \
        "${label}" \
        "${state}" \
        "${drift}" \
        "${apply_result}" \
        "${expected_owner}" \
        "${expected_group}" \
        "${expected_mode}" \
        "${post_owner}" \
        "${post_group}" \
        "${post_mode}" \
        "${path}"
    else
      printf '%-16s : REPAIRED | state %s | before %s | after %s | %s | path %s\n' \
        "${label}" \
        "${state}" \
        "${drift}" \
        "${post_drift}" \
        "${apply_result}" \
        "${path}"
    fi
  done <<EOF_PATHS
$(kao_local_paths_expected_metadata_list)
EOF_PATHS
}
