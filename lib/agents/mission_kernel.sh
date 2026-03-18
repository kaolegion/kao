#!/usr/bin/env bash

kao_agent_task_id_generate() {
    printf "task-%s-%s\n" "$(date +%s)" "$RANDOM"
}

kao_agent_task_attach() {

    local agent_file="state/router/router.agent.selected"
    local state_file="state/router/router.cognitive.state"

    local agent level mode intent
    local task_id task_file

    agent="$(sed -n '1p' "${agent_file}" 2>/dev/null)"
    level="$(grep '^ROUTER_COGNITIVE_LEVEL=' "${state_file}" 2>/dev/null | cut -d= -f2)"
    mode="$(grep '^ROUTER_MODE=' "${state_file}" 2>/dev/null | cut -d= -f2)"
    intent="$(grep '^ROUTER_INTENT=' "${state_file}" 2>/dev/null | cut -d= -f2)"

    task_id="$(kao_agent_task_id_generate)"
    task_file="state/agents/tasks/${task_id}.env"

    mkdir -p state/agents/tasks

    cat <<TASK > "${task_file}"
TASK_ID=${task_id}
TASK_AGENT=${agent}
TASK_LEVEL=${level}
TASK_MODE=${mode}
TASK_INTENT=${intent}
TASK_STATE=attached
TASK_CREATED_AT=$(date +%s)
TASK

    printf "%s\n" "${task_id}" > state/agents/task.current
}

kao_agent_task_current_read() {
    sed -n '1p' state/agents/task.current 2>/dev/null
}
