#!/usr/bin/env bash

scenario_ray_session_timeline_v2() {
  local timeline_file current_file output

  e2e_section "ray session timeline v2 semantic surface"

  timeline_file="/home/kao/state/runtime/session.timeline"
  current_file="/home/kao/state/runtime/session.current"

  rm -f "${timeline_file}" "${current_file}"
  rm -f /home/kao/state/sessions/session-*.snapshot 2>/dev/null || true

  /home/kao/bin/ray session open >/dev/null
  /home/kao/bin/ray status >/dev/null
  /home/kao/bin/ray registry >/dev/null
  /home/kao/bin/ray session close >/dev/null

  assert_file_exists "${timeline_file}" "session timeline file present for v2 semantic checks"

  output="$(cat "${timeline_file}")"
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
}
