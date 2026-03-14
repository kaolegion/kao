#!/usr/bin/env bash

. /home/kao/lib/ksl/ksl_agent_field.sh

ksl_agent_field_demo() {
    ksl_agent_field_emit "ray" "gateway" "active" "0"
    ksl_agent_field_emit "router-local" "agent" "active" "1"
    ksl_agent_field_emit "timeline" "agent" "success" "2"
    ksl_agent_field_emit "watcher" "observer" "idle" "3"
}

ksl_agent_field_demo
