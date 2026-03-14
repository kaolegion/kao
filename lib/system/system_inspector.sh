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

kao_system_inspect_local_paths() {
  local label expected_type path state owner group mode

  while IFS='|' read -r label expected_type path; do
    [ -n "${label}" ] || continue
    state="$(kao_system_check_path_state "${expected_type}" "${path}")"
    owner="$(kao_system_path_owner "${path}")"
    group="$(kao_system_path_group "${path}")"
    mode="$(kao_system_path_mode "${path}")"
    printf '%s|%s|%s|%s|%s|%s|%s\n' \
      "${label}" \
      "${expected_type}" \
      "${path}" \
      "${state}" \
      "${owner}" \
      "${group}" \
      "${mode}"
  done <<EOF_PATHS
$(kao_local_paths_list)
EOF_PATHS
}

kao_system_render_inspection() {
  local label _expected_type path state owner group mode

  printf 'LOCAL SYSTEM INSPECTION\n\n'

  while IFS='|' read -r label _expected_type path state owner group mode; do
    [ -n "${label}" ] || continue
    printf '%-16s : %s | owner %s:%s | mode %s | path %s\n' \
      "${label}" \
      "${state}" \
      "${owner}" \
      "${group}" \
      "${mode}" \
      "${path}"
  done <<EOF_RESULTS
$(kao_system_inspect_local_paths)
EOF_RESULTS
}
