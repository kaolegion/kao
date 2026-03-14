#!/usr/bin/env bash

kao_session_runtime_dir() {
  printf '%s\n' "${KROOT}/state/runtime"
}

kao_session_current_file() {
  printf '%s/session.current\n' "$(kao_session_runtime_dir)"
}

kao_session_history_file() {
  printf '%s/session.history\n' "$(kao_session_runtime_dir)"
}

kao_session_now() {
  date '+%Y-%m-%d %H:%M:%S'
}

kao_session_epoch() {
  date '+%s'
}

kao_session_machine_name() {
  hostname 2>/dev/null || printf 'unknown\n'
}

kao_session_user_name() {
  whoami 2>/dev/null || printf '%s\n' "${USER:-unknown}"
}

kao_session_internet_state() {
  if command -v gateway_network_state >/dev/null 2>&1; then
    gateway_network_state
  else
    printf 'unknown\n'
  fi
}

kao_session_selected_provider() {
  if command -v gateway_provider_select >/dev/null 2>&1; then
    gateway_provider_select
  else
    printf 'none\n'
  fi
}

kao_session_selected_route() {
  if command -v gateway_selected_route >/dev/null 2>&1; then
    gateway_selected_route
  else
    printf 'unknown\n'
  fi
}

kao_session_llm_state() {
  local provider
  provider="$(kao_session_selected_provider)"

  case "${provider}" in
    none|"")
      printf 'none\n'
      ;;
    ollama|local)
      printf 'local\n'
      ;;
    *)
      printf 'cloud\n'
      ;;
  esac
}

kao_session_escape_csv() {
  printf '%s' "${1:-}" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//; s/,/;/g'
}

kao_session_value() {
  local file key
  file="${1}"
  key="${2}"

  [ -f "${file}" ] || return 0
  awk -F= -v key="${key}" '$1 == key { sub($1 "=", ""); print; exit }' "${file}"
}

kao_session_write_current() {
  local start_at start_epoch machine_name user_name internet_state llm_state gateway_agent secondary_agents
  local file

  start_at="${1}"
  start_epoch="${2}"
  machine_name="${3}"
  user_name="${4}"
  internet_state="${5}"
  llm_state="${6}"
  gateway_agent="${7}"
  secondary_agents="${8}"

  file="$(kao_session_current_file)"

  cat > "${file}" <<EOF_CURRENT
SESSION_STATE=ACTIVE
SESSION_START_AT=${start_at}
SESSION_START_EPOCH=${start_epoch}
SESSION_MACHINE=${machine_name}
SESSION_USER=${user_name}
SESSION_INTERNET=${internet_state}
SESSION_LLM=${llm_state}
SESSION_GATEWAY=${gateway_agent}
SESSION_AGENTS=${secondary_agents}
SESSION_LAST_EVENT_AT=$(kao_session_now)
EOF_CURRENT
}

kao_session_merge_agents() {
  local existing incoming merged item
  existing="${1:-}"
  incoming="${2:-}"

  merged="${existing}"

  IFS=',' read -r -a incoming_items <<< "${incoming}"
  for item in "${incoming_items[@]}"; do
    item="$(printf '%s' "${item}" | sed 's/^ *//; s/ *$//')"
    [ -n "${item}" ] || continue
    case ",${merged}," in
      *,"${item}",*)
        ;;
      *)
        if [ -n "${merged}" ]; then
          merged="${merged},${item}"
        else
          merged="${item}"
        fi
        ;;
    esac
  done

  printf '%s\n' "${merged}"
}

kao_session_ensure_active() {
  local file start_at start_epoch machine_name user_name internet_state llm_state gateway_agent secondary_agents

  file="$(kao_session_current_file)"
  if [ -f "${file}" ]; then
    return 0
  fi

  start_at="$(kao_session_now)"
  start_epoch="$(kao_session_epoch)"
  machine_name="$(kao_session_machine_name)"
  user_name="$(kao_session_user_name)"
  internet_state="$(kao_session_internet_state)"
  llm_state="$(kao_session_llm_state)"
  gateway_agent="$(kao_session_selected_provider)"
  secondary_agents="gateway-router"

  kao_session_write_current \
    "${start_at}" \
    "${start_epoch}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${secondary_agents}"
}

kao_session_touch() {
  local gateway_agent secondary_agents
  local file start_at start_epoch machine_name user_name internet_state llm_state existing_agents merged_agents

  gateway_agent="${1:-$(kao_session_selected_provider)}"
  secondary_agents="${2:-}"

  kao_session_ensure_active

  file="$(kao_session_current_file)"
  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_internet_state)"
  llm_state="$(kao_session_llm_state)"
  existing_agents="$(kao_session_value "${file}" SESSION_AGENTS)"
  merged_agents="$(kao_session_merge_agents "${existing_agents}" "${secondary_agents}")"

  [ -n "${gateway_agent}" ] || gateway_agent="$(kao_session_selected_provider)"
  [ -n "${merged_agents}" ] || merged_agents="gateway-router"

  kao_session_write_current \
    "${start_at}" \
    "${start_epoch}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${merged_agents}"
}

kao_session_duration_seconds() {
  local start_epoch now_epoch

  start_epoch="${1:-0}"
  now_epoch="$(kao_session_epoch)"

  if [ "${start_epoch}" -le 0 ] 2>/dev/null; then
    printf '0\n'
    return 0
  fi

  printf '%s\n' "$((now_epoch - start_epoch))"
}

kao_session_duration_human() {
  local total hours minutes seconds

  total="${1:-0}"
  hours="$((total / 3600))"
  minutes="$(((total % 3600) / 60))"
  seconds="$((total % 60))"

  if [ "${hours}" -gt 0 ]; then
    printf '%sh%02sm%02ss\n' "${hours}" "${minutes}" "${seconds}"
    return 0
  fi

  if [ "${minutes}" -gt 0 ]; then
    printf '%sm%02ss\n' "${minutes}" "${seconds}"
    return 0
  fi

  printf '%ss\n' "${seconds}"
}

kao_session_append_history() {
  local start_at end_at duration_seconds duration_human machine_name user_name internet_state llm_state gateway_agent agents
  local file

  start_at="${1}"
  end_at="${2}"
  duration_seconds="${3}"
  duration_human="${4}"
  machine_name="${5}"
  user_name="${6}"
  internet_state="${7}"
  llm_state="${8}"
  gateway_agent="${9}"
  agents="${10}"

  file="$(kao_session_history_file)"
  touch "${file}"

  printf '%s\n' \
    "SESSION_CLOSED|start=${start_at}|end=${end_at}|duration_seconds=${duration_seconds}|duration_human=${duration_human}|machine=${machine_name}|user=${user_name}|internet=${internet_state}|llm=${llm_state}|gateway=${gateway_agent}|agents=${agents}" \
    >> "${file}"
}

kao_session_open() {
  kao_session_ensure_active
}

kao_session_close() {
  local file start_at start_epoch end_at machine_name user_name internet_state llm_state gateway_agent agents duration_seconds duration_human

  file="$(kao_session_current_file)"
  if [ ! -f "${file}" ]; then
    printf 'RAY SESSION\n'
    printf 'state    : INACTIVE\n'
    return 0
  fi

  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"

  end_at="$(kao_session_now)"
  duration_seconds="$(kao_session_duration_seconds "${start_epoch}")"
  duration_human="$(kao_session_duration_human "${duration_seconds}")"

  kao_session_append_history \
    "${start_at}" \
    "${end_at}" \
    "${duration_seconds}" \
    "${duration_human}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${agents}"

  rm -f "${file}"

  printf 'RAY SESSION CLOSED\n'
  printf 'start    : %s\n' "${start_at}"
  printf 'end      : %s\n' "${end_at}"
  printf 'duration : %s\n' "${duration_human}"
  printf 'machine  : %s\n' "${machine_name}"
  printf 'user     : %s\n' "${user_name}"
  printf 'internet : %s\n' "${internet_state}"
  printf 'llm      : %s\n' "${llm_state}"
  printf 'gateway  : %s\n' "${gateway_agent}"
  printf 'agents   : %s\n' "${agents}"
}

kao_session_render_status() {
  local file start_at start_epoch machine_name user_name internet_state llm_state gateway_agent agents duration_seconds duration_human

  file="$(kao_session_current_file)"
  if [ ! -f "${file}" ]; then
    printf 'RAY SESSION\n'
    printf 'state    : INACTIVE\n'
    return 0
  fi

  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"
  duration_seconds="$(kao_session_duration_seconds "${start_epoch}")"
  duration_human="$(kao_session_duration_human "${duration_seconds}")"

  printf 'RAY SESSION\n'
  printf 'state    : ACTIVE\n'
  printf 'start    : %s\n' "${start_at}"
  printf 'duration : %s\n' "${duration_human}"
  printf 'machine  : %s\n' "${machine_name}"
  printf 'user     : %s\n' "${user_name}"
  printf 'internet : %s\n' "${internet_state}"
  printf 'llm      : %s\n' "${llm_state}"
  printf 'gateway  : %s\n' "${gateway_agent}"
  printf 'agents   : %s\n' "${agents}"
}

kao_session_render_history() {
  local file

  file="$(kao_session_history_file)"
  printf 'RAY SESSION HISTORY\n'

  if [ ! -f "${file}" ] || [ ! -s "${file}" ]; then
    printf 'none\n'
    return 0
  fi

  tail -n 10 "${file}"
}

kao_session_render_breathing() {
  local file start_epoch gateway_agent agents internet_state llm_state duration_seconds duration_human

  kao_session_ensure_active
  file="$(kao_session_current_file)"

  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  duration_seconds="$(kao_session_duration_seconds "${start_epoch}")"
  duration_human="$(kao_session_duration_human "${duration_seconds}")"

  printf 'SESSION ACTIVE\n'
  printf 'internet : %s\n' "${internet_state}"
  printf 'llm      : %s\n' "${llm_state}"
  printf 'gateway  : %s\n' "${gateway_agent}"
  printf 'agents   : %s\n' "${agents}"
  printf 'duration : %s\n' "${duration_human}"
}
