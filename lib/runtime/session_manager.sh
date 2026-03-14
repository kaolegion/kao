#!/usr/bin/env bash

kao_session_runtime_dir() {
  printf '%s\n' "${KROOT}/state/runtime"
}

kao_session_archive_dir() {
  printf '%s\n' "${KROOT}/state/sessions"
}

kao_session_current_file() {
  printf '%s/session.current\n' "$(kao_session_runtime_dir)"
}

kao_session_history_file() {
  printf '%s/session.history\n' "$(kao_session_runtime_dir)"
}

kao_session_timeline_file() {
  printf '%s/session.timeline\n' "$(kao_session_runtime_dir)"
}

kao_session_now() {
  date '+%Y-%m-%d %H:%M:%S'
}

kao_session_epoch() {
  date '+%s'
}

kao_session_stamp_compact() {
  date '+%Y%m%d-%H%M%S'
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

kao_session_escape_field() {
  printf '%s' "${1:-}" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//; s/|/\//g'
}

kao_session_value() {
  local file key
  file="${1}"
  key="${2}"

  [ -f "${file}" ] || return 0
  awk -F= -v key="${key}" '$1 == key { sub($1 "=", ""); print; exit }' "${file}"
}

kao_session_ensure_dirs() {
  mkdir -p "$(kao_session_runtime_dir)"
  mkdir -p "$(kao_session_archive_dir)"
}

kao_session_build_id() {
  printf 'session-%s-%s\n' "$(kao_session_stamp_compact)" "$$"
}

kao_session_build_event_id() {
  local event_type
  event_type="${1:-unknown}"
  printf 'evt-%s-%s-%s\n' "$(kao_session_stamp_compact)" "$$" "$(printf '%s' "${event_type}" | tr -c '[:alnum:]' '-')"
}

kao_session_archive_file_for_id() {
  local session_id
  session_id="${1}"
  printf '%s/%s.snapshot\n' "$(kao_session_archive_dir)" "${session_id}"
}

kao_session_write_current() {
  local session_id start_at start_epoch machine_name user_name internet_state llm_state gateway_agent secondary_agents
  local file

  session_id="${1}"
  start_at="${2}"
  start_epoch="${3}"
  machine_name="${4}"
  user_name="${5}"
  internet_state="${6}"
  llm_state="${7}"
  gateway_agent="${8}"
  secondary_agents="${9}"

  kao_session_ensure_dirs
  file="$(kao_session_current_file)"

  cat > "${file}" <<EOF_CURRENT
SESSION_ID=${session_id}
SESSION_STATE=ACTIVE
SESSION_STATUS=ACTIVE
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

kao_session_append_timeline_event() {
  local event_type session_id machine_name user_name internet_state llm_state gateway_agent agents detail
  local file at enriched_detail event_id event_version

  event_type="${1}"
  session_id="${2}"
  machine_name="${3}"
  user_name="${4}"
  internet_state="${5}"
  llm_state="${6}"
  gateway_agent="${7}"
  agents="${8}"
  detail="${9:-none}"

  kao_session_ensure_dirs
  file="$(kao_session_timeline_file)"
  at="$(kao_session_now)"
  event_id="$(kao_session_build_event_id "${event_type}")"
  event_version="2"
  touch "${file}"

  if [ -f "${KROOT}/lib/runtime/event_normalizer.sh" ]; then
    # shellcheck disable=SC1091
    . "${KROOT}/lib/runtime/event_normalizer.sh"
    enriched_detail="$(kao_event_enrich_detail "${event_type}" "${detail}")"
  else
    enriched_detail="${detail}"
  fi

  printf '%s\n' \
    "SESSION_EVENT|event_version=$(kao_session_escape_field "${event_version}")|event_id=$(kao_session_escape_field "${event_id}")|at=$(kao_session_escape_field "${at}")|session_id=$(kao_session_escape_field "${session_id}")|type=$(kao_session_escape_field "${event_type}")|machine=$(kao_session_escape_field "${machine_name}")|user=$(kao_session_escape_field "${user_name}")|internet=$(kao_session_escape_field "${internet_state}")|llm=$(kao_session_escape_field "${llm_state}")|gateway=$(kao_session_escape_field "${gateway_agent}")|agents=$(kao_session_escape_field "${agents}")|detail=$(kao_session_escape_field "${enriched_detail}")" \
    >> "${file}"
}

kao_session_ensure_active() {
  local file session_id start_at start_epoch machine_name user_name internet_state llm_state gateway_agent secondary_agents

  kao_session_ensure_dirs
  file="$(kao_session_current_file)"
  if [ -f "${file}" ]; then
    return 0
  fi

  session_id="$(kao_session_build_id)"
  start_at="$(kao_session_now)"
  start_epoch="$(kao_session_epoch)"
  machine_name="$(kao_session_machine_name)"
  user_name="$(kao_session_user_name)"
  internet_state="$(kao_session_internet_state)"
  llm_state="$(kao_session_llm_state)"
  gateway_agent="$(kao_session_selected_provider)"
  secondary_agents="gateway-router"

  kao_session_write_current \
    "${session_id}" \
    "${start_at}" \
    "${start_epoch}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${secondary_agents}"

  kao_session_append_timeline_event \
    "session-open" \
    "${session_id}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${secondary_agents}" \
    "opened-by-ensure-active"
}

kao_session_touch() {
  local gateway_agent secondary_agents detail
  local file session_id start_at start_epoch machine_name user_name internet_state llm_state existing_agents merged_agents

  gateway_agent="${1:-$(kao_session_selected_provider)}"
  secondary_agents="${2:-}"
  detail="${3:-touch}"

  kao_session_ensure_active

  file="$(kao_session_current_file)"
  session_id="$(kao_session_value "${file}" SESSION_ID)"
  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_internet_state)"
  llm_state="$(kao_session_llm_state)"
  existing_agents="$(kao_session_value "${file}" SESSION_AGENTS)"
  merged_agents="$(kao_session_merge_agents "${existing_agents}" "${secondary_agents}")"

  kao_session_write_current \
    "${session_id}" \
    "${start_at}" \
    "${start_epoch}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${merged_agents}"

  kao_session_append_timeline_event \
    "session-touch" \
    "${session_id}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${merged_agents}" \
    "${detail}"
}

kao_session_open() {
  kao_session_ensure_active
}

kao_session_duration_human() {
  local seconds
  seconds="${1:-0}"

  if [ "${seconds}" -lt 60 ]; then
    printf '%ss\n' "${seconds}"
    return 0
  fi

  if [ "${seconds}" -lt 3600 ]; then
    printf '%sm%ss\n' "$((seconds / 60))" "$((seconds % 60))"
    return 0
  fi

  printf '%sh%sm%ss\n' "$((seconds / 3600))" "$(((seconds % 3600) / 60))" "$((seconds % 60))"
}

kao_session_close() {
  local file session_id start_at start_epoch machine_name user_name internet_state llm_state gateway_agent agents
  local end_at end_epoch duration_seconds duration_human archive_file history_file

  kao_session_ensure_dirs
  file="$(kao_session_current_file)"
  [ -f "${file}" ] || return 0

  session_id="$(kao_session_value "${file}" SESSION_ID)"
  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"

  end_at="$(kao_session_now)"
  end_epoch="$(kao_session_epoch)"
  duration_seconds="$((end_epoch - start_epoch))"
  duration_human="$(kao_session_duration_human "${duration_seconds}")"
  archive_file="$(kao_session_archive_file_for_id "${session_id}")"
  history_file="$(kao_session_history_file)"

  kao_session_append_timeline_event \
    "session-close" \
    "${session_id}" \
    "${machine_name}" \
    "${user_name}" \
    "${internet_state}" \
    "${llm_state}" \
    "${gateway_agent}" \
    "${agents}" \
    "closed-duration=${duration_human}"

  cp "${file}" "${archive_file}"

  printf '%s\n' \
    "SESSION_CLOSED|id=$(kao_session_escape_field "${session_id}")|start=$(kao_session_escape_field "${start_at}")|end=$(kao_session_escape_field "${end_at}")|duration_seconds=$(kao_session_escape_field "${duration_seconds}")|duration_human=$(kao_session_escape_field "${duration_human}")|machine=$(kao_session_escape_field "${machine_name}")|user=$(kao_session_escape_field "${user_name}")|internet=$(kao_session_escape_field "${internet_state}")|llm=$(kao_session_escape_field "${llm_state}")|gateway=$(kao_session_escape_field "${gateway_agent}")|agents=$(kao_session_escape_field "${agents}")|archive=$(kao_session_escape_field "${archive_file}")" \
    >> "${history_file}"

  rm -f "${file}"
}

kao_session_render_status() {
  local file session_id start_at start_epoch machine_name user_name internet_state llm_state gateway_agent agents duration_seconds duration_human last_event_at
  local now_epoch

  kao_session_ensure_dirs
  file="$(kao_session_current_file)"

  printf 'RAY SESSION\n'
  if [ ! -f "${file}" ]; then
    printf 'state    : none\n'
    return 0
  fi

  session_id="$(kao_session_value "${file}" SESSION_ID)"
  start_at="$(kao_session_value "${file}" SESSION_START_AT)"
  start_epoch="$(kao_session_value "${file}" SESSION_START_EPOCH)"
  machine_name="$(kao_session_value "${file}" SESSION_MACHINE)"
  user_name="$(kao_session_value "${file}" SESSION_USER)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"
  last_event_at="$(kao_session_value "${file}" SESSION_LAST_EVENT_AT)"

  now_epoch="$(kao_session_epoch)"
  duration_seconds="$((now_epoch - start_epoch))"
  duration_human="$(kao_session_duration_human "${duration_seconds}")"

  printf 'state    : active\n'
  printf 'id       : %s\n' "${session_id}"
  printf 'start    : %s\n' "${start_at}"
  printf 'last     : %s\n' "${last_event_at}"
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

  kao_session_ensure_dirs
  file="$(kao_session_history_file)"

  printf 'RAY SESSION HISTORY\n'
  [ -f "${file}" ] || {
    printf 'none\n'
    return 0
  }

  tail -n 20 "${file}"
}

kao_session_render_timeline() {
  local file

  file="$(kao_session_timeline_file)"
  printf 'RAY SESSION TIMELINE\n'
  [ -f "${file}" ] || {
    printf 'none\n'
    return 0
  }

  tail -n 50 "${file}"
}

kao_session_render_breathing() {
  local file session_id internet_state llm_state gateway_agent agents
  file="$(kao_session_current_file)"

  kao_session_ensure_active

  session_id="$(kao_session_value "${file}" SESSION_ID)"
  internet_state="$(kao_session_value "${file}" SESSION_INTERNET)"
  llm_state="$(kao_session_value "${file}" SESSION_LLM)"
  gateway_agent="$(kao_session_value "${file}" SESSION_GATEWAY)"
  agents="$(kao_session_value "${file}" SESSION_AGENTS)"

  printf 'SESSION BREATHING\n'
  printf 'session  : %s\n' "${session_id}"
  printf 'internet : %s\n' "${internet_state}"
  printf 'llm      : %s\n' "${llm_state}"
  printf 'gateway  : %s\n' "${gateway_agent}"
  printf 'agents   : %s\n' "${agents}"
}
