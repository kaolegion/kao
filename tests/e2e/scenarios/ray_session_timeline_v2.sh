#!/usr/bin/env bash

scenario_ray_session_timeline_v2() {
  local timeline_file current_file history_file hud_file state_file output hud_output state_output
  local router_count network_count steady_count

  e2e_section "ray session timeline v2 semantic surface"

  timeline_file="/home/kao/state/runtime/session.timeline"
  current_file="/home/kao/state/runtime/session.current"
  history_file="/home/kao/state/runtime/session.history"
  hud_file="/home/kao/board/runtime/ksl-hud.stream"
  state_file="/home/kao/board/runtime/ksl-cognitive.state"

  rm -f "${timeline_file}" "${current_file}" "${history_file}"
  rm -f "${hud_file}" "${state_file}"
  rm -f /home/kao/state/sessions/session-*.snapshot 2>/dev/null || true

  mkdir -p /home/kao/state/runtime /home/kao/state/sessions /home/kao/board/runtime

  /home/kao/bin/ray session open >/dev/null
  /home/kao/bin/ray status >/dev/null
  /home/kao/bin/ray registry >/dev/null
  /home/kao/bin/ray session close >/dev/null

  assert_file_exists "${timeline_file}" "session timeline file present for v2 semantic checks"
  assert_file_exists "${history_file}" "session history file present for session convergence checks"
  assert_file_exists "${hud_file}" "derived KSL HUD stream present"
  assert_file_exists "${state_file}" "derived KSL cognitive state present"

  output="$(cat "${timeline_file}")"
  assert_contains "${output}" "SESSION_EVENT|" "timeline prefix preserved"
  assert_contains "${output}" "event_version=2" "timeline event version visible"
  assert_contains "${output}" "event_id=evt-" "timeline event id visible"
  assert_contains "${output}" "type=session-open" "v2 timeline open event visible"
  assert_contains "${output}" "type=session-close" "v2 timeline close event visible"
  assert_contains "${output}" "family=session_lifecycle" "session lifecycle family visible"
  assert_contains "${output}" "scope=environment" "environment scope visible"
  assert_contains "${output}" "intensity=narrative" "narrative intensity visible"
  assert_contains "${output}" "surface=system" "system surface visible"
  assert_contains "${output}" "detail=action=operator-status" "operator status semantic action visible"
  assert_contains "${output}" "detail=action=operator-registry" "operator registry semantic action visible"
  assert_contains "${output}" "family=operator_surface" "operator surface family visible"
  assert_contains "${output}" "surface=operator" "operator surface semantic layer visible"

  hud_output="$(cat "${hud_file}")"
  assert_contains "${hud_output}" "session.start" "KSL HUD derives session start"
  assert_contains "${hud_output}" "session.steady" "KSL HUD derives operator steady state"
  assert_contains "${hud_output}" "agent.done" "KSL HUD derives agent completion on session close"
  assert_contains "${hud_output}" "session.end" "KSL HUD derives session end"

  router_count="$(printf '%s\n' "${hud_output}" | grep -c 'router.cloud_selected' || true)"
  network_count="$(printf '%s\n' "${hud_output}" | grep -c 'network.online' || true)"
  steady_count="$(printf '%s\n' "${hud_output}" | grep -c 'session.steady' || true)"

  assert_equals "${router_count}" "1" "derived KSL cloud route emitted once when state unchanged"
  assert_equals "${network_count}" "1" "derived KSL online network emitted once when state unchanged"
  assert_equals "${steady_count}" "3" "derived KSL steady state remains visible for operator surfaces"

  state_output="$(cat "${state_file}")"
  assert_contains "${state_output}" "SESSION=inactive" "derived KSL state ends inactive after close"
  assert_contains "${state_output}" "LAST_EVENT=session.end" "derived KSL state tracks last session event"
  assert_contains "${state_output}" "AGENT_STATE=success" "derived KSL state tracks successful completion"
  assert_contains "${state_output}" "AGENT=idle" "derived KSL state resets agent after session close"
  assert_contains "${state_output}" "MODE=session-closed" "derived KSL state exposes closed session mode"
}
