#!/usr/bin/env bash

execution_mode_resolve() {
  local raw
  raw="${EXECUTION_MODE:-auto}"

  case "${raw}" in
    auto|local|cloud)
      printf '%s\n' "${raw}"
      ;;
    *)
      printf 'auto\n'
      ;;
  esac
}

execution_strategy_for_intent() {
  local intent
  intent="${1:-unknown}"

  case "${intent}" in
    file-op)
      printf 'local-exec\n'
      ;;
    system-op)
      printf 'local-inspect\n'
      ;;
    cognitive-heavy)
      printf 'gateway-heavy\n'
      ;;
    cognitive-light)
      printf 'gateway-light\n'
      ;;
    *)
      printf 'unclassified\n'
      ;;
  esac
}

execution_surface_for_strategy() {
  local strategy
  strategy="${1:-unclassified}"

  case "${strategy}" in
    local-exec)
      printf 'shell\n'
      ;;
    local-inspect)
      printf 'system\n'
      ;;
    gateway-heavy|gateway-light)
      printf 'gateway\n'
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_provider_for_strategy() {
  local strategy selected_provider
  strategy="${1:-unclassified}"

  case "${strategy}" in
    gateway-heavy|gateway-light)
      selected_provider="$(gateway_provider_select)"
      printf '%s\n' "${selected_provider}"
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_decision_label() {
  local strategy surface
  strategy="${1:-unclassified}"
  surface="${2:-none}"

  if [ "${strategy}" = "unclassified" ] || [ "${surface}" = "none" ]; then
    printf 'no-execution-bridge\n'
    return 0
  fi

  printf 'routed-execution\n'
}

execution_prompt_normalize() {
  local prompt
  prompt="${*:-}"
  printf '%s' "${prompt}" | tr '[:upper:]' '[:lower:]'
}

execution_path_id_for_prompt() {
  local prompt normalized

  prompt="${*:-}"
  normalized="$(execution_prompt_normalize "${prompt}")"

  case "${normalized}" in
    "ouvre dossier "*)
      printf 'path-open-directory\n'
      ;;
    "ouvrir dossier "*)
      printf 'path-open-directory\n'
      ;;
    "liste fichiers"*|"ls"|\
    "ls "*|"affiche fichiers"*|"montre fichiers"*)
      printf 'path-list-current-directory\n'
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_path_state_for_prompt() {
  local prompt intent strategy path_id

  prompt="${*:-}"
  intent="$(intent_classify "${prompt}")"
  strategy="$(execution_strategy_for_intent "${intent}")"
  path_id="$(execution_path_id_for_prompt "${prompt}")"

  case "${strategy}:${path_id}" in
    local-exec:path-open-directory|local-exec:path-list-current-directory)
      printf 'path-ready\n'
      ;;
    local-exec:none)
      printf 'local-action-pending\n'
      ;;
    local-inspect:none)
      printf 'local-inspection-pending\n'
      ;;
    gateway-heavy:none|gateway-light:none)
      printf 'gateway-ready\n'
      ;;
    *)
      printf 'unclassified\n'
      ;;
  esac
}

execution_path_label_for_id() {
  local path_id
  path_id="${1:-none}"

  case "${path_id}" in
    path-open-directory)
      printf 'open-directory-safe-read\n'
      ;;
    path-list-current-directory)
      printf 'list-current-directory-safe-read\n'
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_path_sequence_for_id() {
  local path_id
  path_id="${1:-none}"

  case "${path_id}" in
    path-open-directory)
      printf '%s\n' \
        "1. resolve target from prompt" \
        "2. verify target exists and is a directory under current workspace" \
        "3. print target path" \
        "4. list directory entries"
      ;;
    path-list-current-directory)
      printf '%s\n' \
        "1. resolve current workspace" \
        "2. print workspace path" \
        "3. list directory entries"
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

execution_extract_directory_target() {
  local prompt normalized target
  prompt="${*:-}"
  normalized="$(execution_prompt_normalize "${prompt}")"

  case "${normalized}" in
    "ouvre dossier "*)
      target="${normalized#ouvre dossier }"
      ;;
    "ouvrir dossier "*)
      target="${normalized#ouvrir dossier }"
      ;;
    *)
      target=""
      ;;
  esac

  target="$(printf '%s' "${target}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  printf '%s\n' "${target}"
}

execution_workspace_root() {
  if [ -n "${KROOT:-}" ]; then
    printf '%s\n' "${KROOT}"
    return 0
  fi

  printf '%s\n' "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
}

execution_safe_directory_path() {
  local workspace_root raw_target candidate

  raw_target="${1:-}"
  workspace_root="$(execution_workspace_root)"

  if [ -z "${raw_target}" ]; then
    return 1
  fi

  case "${raw_target}" in
    *".."*|/*)
      return 1
      ;;
  esac

  candidate="${workspace_root}/${raw_target}"

  if [ ! -d "${candidate}" ]; then
    return 1
  fi

  printf '%s\n' "${candidate}"
}

execution_bridge_operator_surface() {
  local prompt intent route action execution_mode strategy surface provider decision
  local path_id path_label path_state

  prompt="${*:-}"
  intent="$(intent_classify "${prompt}")"
  route="$(intent_route_family "${intent}")"
  action="$(intent_action_label "${intent}")"
  execution_mode="$(execution_mode_resolve)"
  strategy="$(execution_strategy_for_intent "${intent}")"
  surface="$(execution_surface_for_strategy "${strategy}")"
  provider="$(execution_provider_for_strategy "${strategy}")"
  decision="$(execution_decision_label "${strategy}" "${surface}")"
  path_id="$(execution_path_id_for_prompt "${prompt}")"
  path_label="$(execution_path_label_for_id "${path_id}")"
  path_state="$(execution_path_state_for_prompt "${prompt}")"

  printf 'EXECUTION BRIDGE\n'
  printf 'prompt         : %s\n' "${prompt}"
  printf 'intent class   : %s\n' "${intent}"
  printf 'route family   : %s\n' "${route}"
  printf 'action         : %s\n' "${action}"
  printf 'execution mode : %s\n' "${execution_mode}"
  printf 'strategy       : %s\n' "${strategy}"
  printf 'surface        : %s\n' "${surface}"
  printf 'provider       : %s\n' "${provider}"
  printf 'decision       : %s\n' "${decision}"
  printf 'path id        : %s\n' "${path_id}"
  printf 'path label     : %s\n' "${path_label}"
  printf 'path state     : %s\n' "${path_state}"

  if [ "${path_id}" != "none" ]; then
    printf 'path sequence  :\n'
    execution_path_sequence_for_id "${path_id}" | sed 's/^/  - /'
  fi
}

execution_run_path_open_directory() {
  local target_name target_path

  target_name="$(execution_extract_directory_target "$@")"
  if [ -z "${target_name}" ]; then
    printf 'EXECUTION ERROR\n'
    printf 'state          : invalid-target\n'
    return 1
  fi

  if ! target_path="$(execution_safe_directory_path "${target_name}")"; then
    printf 'EXECUTION ERROR\n'
    printf 'state          : target-not-safe-or-missing\n'
    printf 'target         : %s\n' "${target_name}"
    return 1
  fi

  printf 'EXECUTION RESULT\n'
  printf 'state          : executed\n'
  printf 'path id        : path-open-directory\n'
  printf 'target         : %s\n' "${target_name}"
  printf 'resolved path  : %s\n' "${target_path}"
  printf 'entries        :\n'
  ls -la "${target_path}"
}

execution_run_path_list_current_directory() {
  local workspace_root

  workspace_root="$(execution_workspace_root)"

  printf 'EXECUTION RESULT\n'
  printf 'state          : executed\n'
  printf 'path id        : path-list-current-directory\n'
  printf 'resolved path  : %s\n' "${workspace_root}"
  printf 'entries        :\n'
  ls -la "${workspace_root}"
}

execution_bridge_execute_prompt() {
  local prompt intent strategy surface path_id path_state

  prompt="${*:-}"
  intent="$(intent_classify "${prompt}")"
  strategy="$(execution_strategy_for_intent "${intent}")"
  surface="$(execution_surface_for_strategy "${strategy}")"
  path_id="$(execution_path_id_for_prompt "${prompt}")"
  path_state="$(execution_path_state_for_prompt "${prompt}")"

  case "${surface}:${path_id}" in
    gateway:none)
      return 10
      ;;
    shell:path-open-directory)
      execution_run_path_open_directory "${prompt}"
      ;;
    shell:path-list-current-directory)
      execution_run_path_list_current_directory
      ;;
    shell:none)
      printf 'EXECUTION RESULT\n'
      printf 'state          : %s\n' "${path_state}"
      printf 'path id        : none\n'
      return 11
      ;;
    system:none)
      printf 'EXECUTION RESULT\n'
      printf 'state          : %s\n' "${path_state}"
      printf 'path id        : none\n'
      return 12
      ;;
    *)
      printf 'EXECUTION RESULT\n'
      printf 'state          : unsupported\n'
      printf 'path id        : %s\n' "${path_id}"
      return 13
      ;;
  esac
}
