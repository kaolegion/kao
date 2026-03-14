#!/usr/bin/env bash

source /home/kao/lib/ksl/ksl_engine.sh
source /home/kao/lib/ksl/ksl_render.sh

kao_ksl_timeline_stream() {
  local mode="${1:-ascii}"
  local count="${2:-20}"
  local line
  local signal

  tail -n "$count" /home/kao/board/runtime/ksl-timeline.log 2>/dev/null | while IFS= read -r line; do
    signal="${line##*SIGNAL=}"
    if [ "$mode" = "ansi" ]; then
      kao_ksl_render_ansi "KSL::$signal"
    else
      kao_ksl_render_ascii "$signal"
    fi
  done
}
