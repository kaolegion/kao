#!/usr/bin/env bash

source /home/kao/lib/ksl/ksl_engine.sh
source /home/kao/lib/ksl/ksl_render.sh

kao_ksl_timeline_stream() {
  local mode="${1:-ascii}"
  local count="${2:-20}"
  local line
  local signal

  tail -n "$count" /home/kao/board/runtime/ksl-timeline.log 2>/dev/null | while IFS= read -r line; do
    signal="$(printf "%s\n" "$line" | sed -n 's/.*SIGNAL=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    if [ "$mode" = "ansi" ]; then
      kao_ksl_render_ansi "KSL::$signal"
    else
      kao_ksl_render_ascii "$signal"
    fi
  done
}

kao_ksl_timeline_semantic() {
  local count="${1:-20}"
  local ts layer priority event signal role scope pattern object
  tail -n "$count" /home/kao/board/runtime/ksl-timeline.log 2>/dev/null | \
  while IFS= read -r line; do
    ts="$(printf "%s\n" "$line" | cut -d'|' -f1 | sed 's/[[:space:]]*$//')"
    layer="$(printf "%s\n" "$line" | sed -n 's/.*LAYER=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    priority="$(printf "%s\n" "$line" | sed -n 's/.*PRIORITY=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    event="$(printf "%s\n" "$line" | sed -n 's/.*EVENT=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    signal="$(printf "%s\n" "$line" | sed -n 's/.*SIGNAL=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    role="$(printf "%s\n" "$line" | sed -n 's/.*ROLE=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    scope="$(printf "%s\n" "$line" | sed -n 's/.*SCOPE=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    pattern="$(printf "%s\n" "$line" | sed -n 's/.*PATTERN=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"
    object="$(printf "%s\n" "$line" | sed -n 's/.*OBJECT=\([^|]*\).*/\1/p' | sed 's/[[:space:]]*$//')"

    printf "%-20s | %-3s | %-2s | %-18s | %-10s | %-8s | %-14s | %s\n" \
      "$ts" "$layer" "$priority" "$event" "$role" "$scope" "$pattern" "$signal"
  done
}
