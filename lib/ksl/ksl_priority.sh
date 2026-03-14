#!/usr/bin/env bash

kao_ksl_event_priority() {
  local event="$1"

  case "$event" in
    system.error|system.blocked)
      echo "P1"
      ;;
    network.lost|router.fallback_local|session.end)
      echo "P2"
      ;;
    session.start|network.online|router.evaluate|router.local_selected|router.cloud_selected|agent.active|agent.done|memory.hot)
      echo "P3"
      ;;
    memory.recall|agent.spawn|session.steady|network.offline)
      echo "P4"
      ;;
    *)
      echo "P5"
      ;;
  esac
}
