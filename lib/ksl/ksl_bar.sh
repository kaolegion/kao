#!/usr/bin/env bash

source /home/kao/lib/ksl/ksl_engine.sh

kao_ksl_bar_render() {
  local session net router agent agent_state load mode memory last_event

  session="$(kao_ksl_get_state "SESSION" "inactive")"
  net="$(kao_ksl_get_state "NET" "unknown")"
  router="$(kao_ksl_get_state "ROUTER" "unknown")"
  agent="$(kao_ksl_get_state "AGENT" "idle")"
  agent_state="$(kao_ksl_get_state "AGENT_STATE" "idle")"
  load="$(kao_ksl_get_state "LOAD" "i1")"
  mode="$(kao_ksl_get_state "MODE" "unknown")"
  memory="$(kao_ksl_get_state "MEMORY" "warm")"
  last_event="$(kao_ksl_get_state "LAST_EVENT" "none")"

  printf "SESSION●:%s  NET⌁:%s  ROUTER◆:%s  AGENT▮:%s(%s)  LOAD≈:%s  MODE◎:%s  MEM◉:%s  LAST◆:%s\n" \
    "$session" "$net" "$router" "$agent" "$agent_state" "$load" "$mode" "$memory" "$last_event"
}

kao_ksl_bar_demo() {
  kao_runtime_emit_event "session.start"
  kao_runtime_emit_event "router.local_selected"
  kao_runtime_emit_event "agent.spawn"
  kao_runtime_emit_event "memory.recall"
  kao_ksl_bar_render
  sleep 1

  kao_runtime_emit_event "network.online"
  kao_runtime_emit_event "router.cloud_selected"
  kao_runtime_emit_event "agent.active"
  kao_runtime_emit_event "memory.hot"
  kao_ksl_bar_render
  sleep 1

  kao_runtime_emit_event "network.lost"
  kao_runtime_emit_event "router.fallback_local"
  kao_runtime_emit_event "agent.done"
  kao_ksl_bar_render
}
