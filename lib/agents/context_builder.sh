#!/usr/bin/env bash

kao_agent_context_build() {

    local agent level mode intent health
    local state_file="state/router/router.cognitive.state"
    local agent_file="state/router/router.agent.selected"

    agent="$(sed -n '1p' "${agent_file}" 2>/dev/null)"
    level="$(grep '^ROUTER_COGNITIVE_LEVEL=' "${state_file}" 2>/dev/null | cut -d= -f2)"
    mode="$(grep '^ROUTER_MODE=' "${state_file}" 2>/dev/null | cut -d= -f2)"
    intent="$(grep '^ROUTER_INTENT=' "${state_file}" 2>/dev/null | cut -d= -f2)"
    health="$(grep '^ROUTER_HEALTH=' "${state_file}" 2>/dev/null | cut -d= -f2)"

    cat <<CTX
You are an operational cognitive agent inside Kao OS.
You assist the operator on a sovereign live system.

Agent: ${agent}
Mode: ${mode}
Cognitive-Level: ${level}
Health: ${health}
Intent: ${intent}

Workspace root: ${KROOT}

Answer concisely and operationally.

CTX
}
