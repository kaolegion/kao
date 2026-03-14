#!/usr/bin/env bash

scenario_ray_timeline() {
  local timeline_file current_file output timeline_output

  e2e_section "ray timeline surface"

  timeline_file="/home/kao/state/runtime/session.timeline"
  current_file="/home/kao/state/runtime/session.current"

  rm -f "${timeline_file}" "${current_file}"
  rm -f /home/kao/state/sessions/session-*.snapshot 2>/dev/null || true

  output="$(/home/kao/bin/ray session open)"
  assert_contains "${output}" "RAY SESSION" "ray session open banner visible"
  assert_contains "${output}" "state    : ACTIVE" "ray session open active state visible"

  /home/kao/bin/ray status >/dev/null
  /home/kao/bin/ray registry >/dev/null

  timeline_output="$(/home/kao/bin/ray session timeline)"
  assert_contains "${timeline_output}" "RAY SESSION TIMELINE" "ray session timeline banner visible"
  assert_contains "${timeline_output}" "SESSION_EVENT|" "ray session timeline event lines visible"

  assert_file_exists "${timeline_file}" "session timeline file present"

  output="$(cat "${timeline_file}")"
  assert_contains "${output}" "type=session-open" "session open event recorded"
  assert_contains "${output}" "type=session-touch" "session touch event recorded"
  assert_contains "${output}" "detail=ray-status" "ray status detail recorded"
  assert_contains "${output}" "detail=ray-registry" "ray registry detail recorded"

  output="$(/home/kao/bin/ray session close)"
  assert_contains "${output}" "RAY SESSION CLOSED" "ray session close banner visible"

  assert_file_exists "${timeline_file}" "session timeline file still present after close"

  output="$(cat "${timeline_file}")"
  assert_contains "${output}" "type=session-close" "session close event recorded"

  timeline_output="$(/home/kao/bin/ray session timeline)"
  assert_contains "${timeline_output}" "type=session-open" "timeline surface shows open event"
  assert_contains "${timeline_output}" "type=session-touch" "timeline surface shows touch event"
  assert_contains "${timeline_output}" "type=session-close" "timeline surface shows close event"
}
