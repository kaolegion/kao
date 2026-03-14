#!/usr/bin/env bash

ray_timeline_query_timeline_path() {
  printf "%s\n" "/home/kao/state/runtime/session.timeline"
}

ray_timeline_query_require_file() {
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"

  if [ ! -f "$timeline_path" ]; then
    echo "ERROR: missing timeline file: $timeline_path" >&2
    return 1
  fi
}

ray_timeline_query_print_all() {
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"
  ray_timeline_query_require_file || return 1
  grep -v '^[[:space:]]*$' "$timeline_path"
}

ray_timeline_query_search_text() {
  local needle="$1"
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"
  ray_timeline_query_require_file || return 1
  grep -F "$needle" "$timeline_path"
}

ray_timeline_query_last() {
  local count="${1:-20}"
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"
  ray_timeline_query_require_file || return 1
  tail -n "$count" "$timeline_path"
}

ray_timeline_query_unique_field() {
  local field="$1"
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"
  ray_timeline_query_require_file || return 1

  awk -F'|' -v field="$field" '
    {
      for (i = 1; i <= NF; i++) {
        token = $i
        if (token ~ ("^" field "=")) {
          sub("^" field "=", "", token)
          if (token != "") print token
        }
      }
    }
  ' "$timeline_path" | sort -u
}

ray_timeline_query_match_field() {
  local field="$1"
  local value="$2"
  local timeline_path
  timeline_path="$(ray_timeline_query_timeline_path)"
  ray_timeline_query_require_file || return 1
  grep -F "${field}=${value}" "$timeline_path"
}

ray_timeline_query_sessions() { ray_timeline_query_unique_field "session_id"; }
ray_timeline_query_agents() {
  {
    ray_timeline_query_unique_field "gateway_agent"
    ray_timeline_query_unique_field "agent"
    ray_timeline_query_unique_field "secondary_agent"
  } | sort -u
}
ray_timeline_query_event_types() { ray_timeline_query_unique_field "event_type"; }
ray_timeline_query_cognitive_levels() {
  {
    ray_timeline_query_unique_field "cognitive_level"
    ray_timeline_query_unique_field "intent_class"
    ray_timeline_query_unique_field "route_family"
  } | sort -u
}
ray_timeline_query_providers() {
  {
    ray_timeline_query_unique_field "provider"
    ray_timeline_query_unique_field "provider_kind"
    ray_timeline_query_unique_field "selected_provider"
  } | sort -u
}
