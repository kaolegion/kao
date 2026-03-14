#!/usr/bin/env bash

source /home/kao/lib/ksl/ksl_priority.sh 2>/dev/null || true
source /home/kao/lib/ksl/ksl_hierarchy.sh 2>/dev/null || true

KSL_MAPPING_FILE="/home/kao/lib/ksl/ksl_mapping.env"
KSL_TIMELINE_FILE="/home/kao/board/runtime/ksl-timeline.log"
KSL_STATE_FILE="/home/kao/board/runtime/ksl-cognitive.state"
KSL_STREAM_FILE="/home/kao/board/runtime/ksl-hud.stream"

kao_ksl_ensure_runtime_paths() {
  mkdir -p /home/kao/board/runtime
  touch "$KSL_TIMELINE_FILE" "$KSL_STATE_FILE" "$KSL_STREAM_FILE"
}

kao_signal_resolve() {
  local event="$1"
  grep "^$event=" "$KSL_MAPPING_FILE" 2>/dev/null | cut -d= -f2
}

kao_ksl_event_symbol() {
  local signal="$1"

  case "$signal" in
    •/*|⏺/*) printf "●" ;;
    ⌁/*)     printf "⌁" ;;
    ▮/*)     printf "▮" ;;
    ◉/*)     printf "◉" ;;
    ◆/*)     printf "◆" ;;
    *)       printf "◆" ;;
  esac
}

kao_ksl_event_layer_name() {
  local signal="$1"

  case "$signal" in
    */SYS/*) printf "SYS" ;;
    */NET/*) printf "NET" ;;
    */ACT/*) printf "ACT" ;;
    */MEM/*) printf "MEM" ;;
    */RSN/*) printf "RSN" ;;
    */USR/*) printf "USR" ;;
    */TMP/*) printf "TMP" ;;
    */ALT/*) printf "ALT" ;;
    *)       printf "UNK" ;;
  esac
}

kao_ksl_extract_segment() {
  local signal="$1"
  local index="$2"
  printf "%s\n" "$signal" | awk -F'/' -v idx="$index" '{ print $idx }'
}

kao_ksl_extract_state() {
  local signal="$1"
  local value
  value="$(kao_ksl_extract_segment "$signal" 3)"
  [ -n "$value" ] && printf "%s\n" "$value" || printf "unknown\n"
}

kao_ksl_extract_intensity() {
  local signal="$1"
  local value
  value="$(kao_ksl_extract_segment "$signal" 4)"

  if printf "%s" "$value" | grep -Eq '^i[0-9]+$'; then
    printf "%s\n" "$value"
  else
    printf "i1\n"
  fi
}

kao_ksl_extract_pattern() {
  local signal="$1"
  local value
  value="$(kao_ksl_extract_segment "$signal" 5)"
  [ -n "$value" ] && printf "%s\n" "$value" || printf "steady\n"
}

kao_ksl_extract_object() {
  local signal="$1"
  local value
  value="$(kao_ksl_extract_segment "$signal" 6)"
  [ -n "$value" ] && printf "%s\n" "$value" || printf "object\n"
}

kao_ksl_semantic_role_from_event() {
  local event="$1"

  case "$event" in
    session.start|session.steady|session.end)
      printf "presence\n"
      ;;
    network.online|network.offline|network.lost)
      printf "context\n"
      ;;
    router.evaluate|router.local_selected|router.cloud_selected|router.fallback_local)
      printf "decision\n"
      ;;
    agent.spawn|agent.active|agent.done)
      printf "execution\n"
      ;;
    memory.recall|memory.hot)
      printf "memory\n"
      ;;
    *)
      printf "state\n"
      ;;
  esac
}

kao_ksl_scope_from_event() {
  local event="$1"

  case "$event" in
    session.start|session.steady|session.end)
      printf "session\n"
      ;;
    network.online|network.offline|network.lost)
      printf "global\n"
      ;;
    router.evaluate|router.local_selected|router.cloud_selected|router.fallback_local)
      printf "session\n"
      ;;
    agent.spawn|agent.active|agent.done)
      printf "local\n"
      ;;
    memory.recall|memory.hot)
      printf "session\n"
      ;;
    *)
      printf "local\n"
      ;;
  esac
}

kao_ksl_compose_surface_signal() {
  local signal="$1"
  local event="$2"
  local role
  local scope

  role="$(kao_ksl_semantic_role_from_event "$event")"
  scope="$(kao_ksl_scope_from_event "$event")"

  printf "%s@%s#%s\n" "$signal" "$scope" "$role"
}

kao_ksl_set_state() {
  local key="$1"
  local value="$2"

  kao_ksl_ensure_runtime_paths

  python3 - "$KSL_STATE_FILE" "$key" "$value" <<'PY'
import sys
from pathlib import Path

state_path = Path(sys.argv[1])
key = sys.argv[2]
value = sys.argv[3]

lines = []
if state_path.exists():
    lines = state_path.read_text().splitlines()

updated = False
out = []
for line in lines:
    if "=" in line and line.split("=", 1)[0] == key:
        out.append(f"{key}={value}")
        updated = True
    elif line.strip():
        out.append(line)

if not updated:
    out.append(f"{key}={value}")

state_path.write_text("\n".join(out) + ("\n" if out else ""))
PY
}

kao_ksl_get_state() {
  local key="$1"
  local fallback="${2:-unknown}"

  if [ ! -f "$KSL_STATE_FILE" ]; then
    printf "%s\n" "$fallback"
    return 0
  fi

  awk -F= -v key="$key" '$1 == key { print $2; found=1 } END { if (!found) print "" }' \
    "$KSL_STATE_FILE" | sed -n '1p' | awk -v fallback="$fallback" '
      NF { print; printed=1 }
      END { if (!printed) print fallback }
    '
}

kao_ksl_refresh_mode() {
  local net
  local router
  local session

  session="$(kao_ksl_get_state "SESSION" "inactive")"
  net="$(kao_ksl_get_state "NET" "unknown")"
  router="$(kao_ksl_get_state "ROUTER" "unknown")"

  if [ "$session" = "inactive" ]; then
    kao_ksl_set_state "MODE" "session-closed"
  elif [ "$net" = "online" ] && [ "$router" = "cloud" ]; then
    kao_ksl_set_state "MODE" "online-cloud"
  elif [ "$net" = "online" ] && [ "$router" = "fallback-local" ]; then
    kao_ksl_set_state "MODE" "hybrid-fallback"
  elif [ "$net" = "offline" ] && [ "$router" = "local" ]; then
    kao_ksl_set_state "MODE" "offline-local"
  elif [ "$net" = "online" ] && [ "$router" = "local" ]; then
    kao_ksl_set_state "MODE" "online-local"
  elif [ "$net" = "offline" ]; then
    kao_ksl_set_state "MODE" "offline"
  elif [ "$net" = "online" ]; then
    kao_ksl_set_state "MODE" "online"
  else
    kao_ksl_set_state "MODE" "unknown"
  fi
}

kao_ksl_refresh_state_from_event() {
  local event="$1"
  local signal="$2"
  local intensity="$3"
  local role
  local scope
  local pattern
  local object
  local surface_signal

  role="$(kao_ksl_semantic_role_from_event "$event")"
  scope="$(kao_ksl_scope_from_event "$event")"
  pattern="$(kao_ksl_extract_pattern "$signal")"
  object="$(kao_ksl_extract_object "$signal")"
  surface_signal="$(kao_ksl_compose_surface_signal "$signal" "$event")"

  case "$event" in
    session.start|session.steady)
      kao_ksl_set_state "SESSION" "active"
      ;;
    session.end)
      kao_ksl_set_state "SESSION" "inactive"
      kao_ksl_set_state "AGENT" "idle"
      ;;
  esac

  case "$event" in
    network.online)
      kao_ksl_set_state "NET" "online"
      ;;
    network.offline|network.lost)
      kao_ksl_set_state "NET" "offline"
      ;;
  esac

  case "$event" in
    router.local_selected)
      kao_ksl_set_state "ROUTER" "local"
      ;;
    router.cloud_selected)
      kao_ksl_set_state "ROUTER" "cloud"
      ;;
    router.fallback_local)
      kao_ksl_set_state "ROUTER" "fallback-local"
      ;;
  esac

  case "$event" in
    agent.spawn)
      kao_ksl_set_state "AGENT" "spawn"
      kao_ksl_set_state "AGENT_STATE" "spawned"
      ;;
    agent.active)
      kao_ksl_set_state "AGENT" "active"
      kao_ksl_set_state "AGENT_STATE" "running"
      ;;
    agent.done)
      kao_ksl_set_state "AGENT_STATE" "success"
      ;;
  esac

  case "$event" in
    memory.recall)
      kao_ksl_set_state "MEMORY" "warm"
      ;;
    memory.hot)
      kao_ksl_set_state "MEMORY" "hot"
      ;;
    session.end)
      kao_ksl_set_state "MEMORY" "warm"
      ;;
  esac

  if [ "$event" = "system.error" ]; then
    kao_ksl_set_state "AGENT_STATE" "error"
  fi

  kao_ksl_set_state "LOAD" "$intensity"
  kao_ksl_set_state "LAST_EVENT" "$event"
  kao_ksl_set_state "LAST_SIGNAL" "$surface_signal"
  kao_ksl_set_state "LAST_ROLE" "$role"
  kao_ksl_set_state "LAST_SCOPE" "$scope"
  kao_ksl_set_state "LAST_PATTERN" "$pattern"
  kao_ksl_set_state "LAST_OBJECT" "$object"
  kao_ksl_refresh_mode
}

kao_runtime_emit_event() {
  local event="$1"
  local signal
  local priority
  local layer
  local ts
  local symbol
  local intensity
  local state
  local pattern
  local object
  local role
  local scope

  kao_ksl_ensure_runtime_paths

  signal="$(kao_signal_resolve "$event")"
  priority="$(kao_ksl_event_priority "$event")"
  layer="$(kao_ksl_event_layer "$event")"
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  [ -n "$signal" ] || signal="unknown/$event"
  [ -n "$priority" ] || priority="P3"
  [ -n "$layer" ] || layer="$(kao_ksl_event_layer_name "$signal")"

  symbol="$(kao_ksl_event_symbol "$signal")"
  intensity="$(kao_ksl_extract_intensity "$signal")"
  state="$(kao_ksl_extract_state "$signal")"
  pattern="$(kao_ksl_extract_pattern "$signal")"
  object="$(kao_ksl_extract_object "$signal")"
  role="$(kao_ksl_semantic_role_from_event "$event")"
  scope="$(kao_ksl_scope_from_event "$event")"

  printf "%s | LAYER=%s | PRIORITY=%s | EVENT=%s | SIGNAL=%s | ROLE=%s | SCOPE=%s | PATTERN=%s | OBJECT=%s\n" \
    "$ts" "$layer" "$priority" "$event" "$signal" "$role" "$scope" "$pattern" "$object" >> "$KSL_TIMELINE_FILE"

  printf "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" \
    "$ts" "$layer" "$priority" "$event" "$signal" "$symbol" "$intensity" "$state" "$pattern" "$object" "$role" "$scope" >> "$KSL_STREAM_FILE"

  kao_ksl_refresh_state_from_event "$event" "$signal" "$intensity"
}

kao_ksl_hud_stream() {
  local ts layer priority event signal symbol intensity state pattern object role scope

  tail -n 20 -f "$KSL_STREAM_FILE" 2>/dev/null | while IFS='|' read -r ts layer priority event signal symbol intensity state pattern object role scope; do
    printf "%-20s | %-3s | %-2s | %-18s | %-28s | %-8s | %-10s | %-9s | %-9s | %s\n" \
      "$ts" "$layer" "$priority" "$event" "$role" "$scope" "$state" "$pattern" "$intensity" "$signal"
  done
}
