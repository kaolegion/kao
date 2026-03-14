#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/event_normalizer.sh"
source "${KROOT}/lib/runtime/timeline_query.sh"
source "${KROOT}/lib/runtime/ksl_hook.sh"
source "${KROOT}/lib/ksl/ksl_bar.sh"

kao_session_current_file() {
  printf '%s/state/runtime/session.current\n' "${KROOT}"
}

kao_session_history_file() {
  printf '%s/state/runtime/session.history\n' "${KROOT}"
}

kao_session_timeline_file() {
  printf '%s/state/runtime/session.timeline\n' "${KROOT}"
}

kao_session_snapshots_dir() {
  printf '%s/state/sessions\n' "${KROOT}"
}

kao_session_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_session_new_id() {
  date -u +"session-%Y%m%d-%H%M%S-$RANDOM"
}

kao_session_new_event_id() {
  date -u +"evt-%Y%m%d-%H%M%S-$RANDOM"
}

kao_session_require_paths() {
  mkdir -p "${KROOT}/state/runtime" "${KROOT}/state/sessions"
  touch "$(kao_session_history_file)"
  touch "$(kao_session_timeline_file)"
}

kao_session_current_has_active() {
  [ -f "$(kao_session_current_file)" ]
}

kao_session_current_field() {
  local key="${1:-}"
  local file
  file="$(kao_session_current_file)"

  [ -f "${file}" ] || return 1
  awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "${file}"
}

kao_session_write_current() {
  local session_id="${1:-}"
  local opened_at="${2:-}"
  local gateway_provider="${3:-unknown}"
  local gateway_agent="${4:-unknown}"

  cat <<EOF2 > "$(kao_session_current_file)"
SESSION_ID=${session_id}
OPENED_AT=${opened_at}
GATEWAY_PROVIDER=${gateway_provider}
GATEWAY_AGENT=${gateway_agent}
EOF2
}

kao_session_detect_gateway_provider() {
  if command -v gateway_provider_select >/dev/null 2>&1; then
    gateway_provider_select
  else
    printf 'unknown\n'
  fi
}

kao_session_detect_gateway_agent() {
  if command -v gateway_provider_select >/dev/null 2>&1; then
    gateway_provider_select
  else
    printf 'unknown\n'
  fi
}

kao_session_append_history() {
  local session_id="${1:-}"
  local opened_at="${2:-}"
  local closed_at="${3:-}"
  local gateway_provider="${4:-unknown}"
  local gateway_agent="${5:-unknown}"

  printf '%s|opened_at=%s|closed_at=%s|provider=%s|gateway_agent=%s\n' \
    "${session_id}" \
    "${opened_at}" \
    "${closed_at}" \
    "${gateway_provider}" \
    "${gateway_agent}" >> "$(kao_session_history_file)"
}

kao_session_snapshot_current() {
  local session_id="${1:-}"
  local snapshot_file

  snapshot_file="$(kao_session_snapshots_dir)/${session_id}.snapshot"
  cp "$(kao_session_current_file)" "${snapshot_file}"
}

kao_session_append_timeline_event() {
  local event_type="${1:-unknown}"
  local provider="${2:-unknown}"
  local gateway_agent="${3:-unknown}"
  local raw_detail="${4:-none}"
  local session_id event_id ts detail

  kao_session_require_paths

  if kao_session_current_has_active; then
    session_id="$(kao_session_current_field SESSION_ID)"
  else
    session_id="session-none"
  fi

  event_id="$(kao_session_new_event_id)"
  ts="$(kao_session_now_utc)"
  detail="$(kao_event_enrich_detail "${event_type}" "${raw_detail}")"

  printf 'SESSION_EVENT|ts=%s|event_version=2|event_id=%s|session_id=%s|type=%s|provider=%s|gateway_agent=%s|detail=%s\n' \
    "${ts}" \
    "${event_id}" \
    "${session_id}" \
    "${event_type}" \
    "${provider}" \
    "${gateway_agent}" \
    "${detail}" >> "$(kao_session_timeline_file)"

  kao_runtime_ksl_emit_from_session_event "${event_type}" "${provider}" "${raw_detail}"
}

kao_session_open() {
  local session_id opened_at provider agent

  kao_session_require_paths

  if kao_session_current_has_active; then
    return 0
  fi

  session_id="$(kao_session_new_id)"
  opened_at="$(kao_session_now_utc)"
  provider="$(kao_session_detect_gateway_provider)"
  agent="$(kao_session_detect_gateway_agent)"

  kao_session_write_current "${session_id}" "${opened_at}" "${provider}" "${agent}"
  kao_session_append_timeline_event "session-open" "${provider}" "${agent}" "action=operator-session-open"
}

kao_session_touch() {
  local provider="${1:-unknown}"
  local agent="${2:-unknown}"
  local raw_detail="${3:-none}"

  kao_session_require_paths

  if ! kao_session_current_has_active; then
    kao_session_open
  fi

  [ -n "${provider}" ] || provider="unknown"
  [ -n "${agent}" ] || agent="unknown"
  [ -n "${raw_detail}" ] || raw_detail="none"

  kao_session_append_timeline_event "session-touch" "${provider}" "${agent}" "${raw_detail}"
}

kao_session_close() {
  local session_id opened_at provider agent closed_at

  kao_session_require_paths

  if ! kao_session_current_has_active; then
    printf 'RAY SESSION\nnone\n'
    return 0
  fi

  session_id="$(kao_session_current_field SESSION_ID)"
  opened_at="$(kao_session_current_field OPENED_AT)"
  provider="$(kao_session_current_field GATEWAY_PROVIDER)"
  agent="$(kao_session_current_field GATEWAY_AGENT)"
  closed_at="$(kao_session_now_utc)"

  kao_session_append_timeline_event "session-close" "${provider}" "${agent}" "action=operator-session-close"
  kao_session_append_history "${session_id}" "${opened_at}" "${closed_at}" "${provider}" "${agent}"
  kao_session_snapshot_current "${session_id}"
  rm -f "$(kao_session_current_file)"

  printf 'RAY SESSION CLOSED\n'
  printf 'session id : %s\n' "${session_id}"
  printf 'opened at  : %s\n' "${opened_at}"
  printf 'closed at  : %s\n' "${closed_at}"
  printf 'provider   : %s\n' "${provider}"
  printf 'agent      : %s\n' "${agent}"
}

kao_session_render_status() {
  local session_id opened_at provider agent

  kao_session_require_paths

  printf 'RAY SESSION\n'

  if ! kao_session_current_has_active; then
    printf 'state      : inactive\n'
    printf '\n'
    kao_ksl_bar_render
    return 0
  fi

  session_id="$(kao_session_current_field SESSION_ID)"
  opened_at="$(kao_session_current_field OPENED_AT)"
  provider="$(kao_session_current_field GATEWAY_PROVIDER)"
  agent="$(kao_session_current_field GATEWAY_AGENT)"

  printf 'state      : active\n'
  printf 'session id : %s\n' "${session_id}"
  printf 'opened at  : %s\n' "${opened_at}"
  printf 'provider   : %s\n' "${provider}"
  printf 'agent      : %s\n' "${agent}"
  printf '\n'
  kao_ksl_bar_render
}

kao_session_render_history() {
  local history_file
  history_file="$(kao_session_history_file)"

  kao_session_require_paths

  printf 'RAY SESSION HISTORY\n'
  if [ ! -s "${history_file}" ]; then
    printf 'none\n'
    return 0
  fi

  tail -n 20 "${history_file}"
}

kao_session_render_timeline() {
  local timeline_file
  timeline_file="$(kao_session_timeline_file)"

  kao_session_require_paths

  printf 'RAY SESSION TIMELINE\n'
  if [ ! -s "${timeline_file}" ]; then
    printf 'none\n'
    return 0
  fi

  tail -n 40 "${timeline_file}"
}

kao_session_render_breathing() {
  local provider
  local mode
  local load

  provider="$(kao_ksl_get_state "ROUTER" "unknown")"
  mode="$(kao_ksl_get_state "MODE" "unknown")"
  load="$(kao_ksl_get_state "LOAD" "i1")"

  printf 'SESSION BREATHING\n'
  printf 'router : %s\n' "${provider}"
  printf 'mode   : %s\n' "${mode}"
  printf 'load   : %s\n' "${load}"
}

kao_session_demo_live_flow() {
  kao_session_open
  kao_session_touch "local" "gateway-local" "action=operator-status"
  kao_session_touch "mistral" "gateway-cloud" "action=operator-registry"
  kao_session_touch "mistral" "gateway-cloud" "action=execution-gateway"
  kao_session_touch "local-shell" "local-shell" "action=execution-local-shell"
  kao_session_close
}
