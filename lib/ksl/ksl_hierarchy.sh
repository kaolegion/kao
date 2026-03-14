#!/usr/bin/env bash

kao_ksl_event_layer() {
  local event="$1"

  case "$event" in
    session.*)
      echo "LIFECYCLE"
      ;;
    network.*)
      echo "INFRA"
      ;;
    router.*)
      echo "COGNITION"
      ;;
    agent.*)
      echo "EXECUTION"
      ;;
    memory.*)
      echo "MEMORY"
      ;;
    system.*)
      echo "CRITICAL"
      ;;
    *)
      echo "GENERIC"
      ;;
  esac
}
