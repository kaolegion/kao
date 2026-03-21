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

kao_mission_gate_prompt_normalize() {
    local prompt="${*:-}"
    printf '%s' "${prompt}" | tr '[:upper:]' '[:lower:]'
}

kao_mission_gate_should_bypass() {
    local normalized
    normalized="$(kao_mission_gate_prompt_normalize "$*")"

    case "${normalized}" in
        "tu es qui"|"tu es qui ?"|"qui es-tu"|"qui es-tu ?"|"qui es tu"|"qui est tu"|\
        "où suis-je"|"où suis-je ?"|"ou suis-je"|"ou suis-je ?"|"ou suis je"|\
        "quel est ton état"|"quel est ton état ?"|"quel est ton etat"|"quel est ton etat ?"|\
        "status"|"etat"|\
        "résume cette réunion"|"resume cette réunion"|"résume cette reunion"|"resume cette reunion"|\
        "analyse ce dépôt"|"analyse ce depot"|\
        "explique ce fichier")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kao_mission_gate_is_ambiguous() {
    local normalized
    normalized="$(kao_mission_gate_prompt_normalize "$*")"

    case "${normalized}" in
        "aide-moi avec mon projet"|"aide moi avec mon projet"|\
        "gère ça"|"gere ca"|\
        "fais quelque chose pour ce repo")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kao_mission_gate_should_open() {
    local normalized
    normalized="$(kao_mission_gate_prompt_normalize "$*")"

    if kao_mission_gate_should_bypass "${normalized}"; then
        return 1
    fi

    if kao_mission_gate_is_ambiguous "${normalized}"; then
        return 1
    fi

    case "${normalized}" in
        *"prépare "*|*"prepare "*|*"organise "*|*"organiser "*|*"crée "*|*"cree "*|\
        *"créer "*|*"creer "*|*"rédige "*|*"redige "*|*"plan d'envoi"*|\
        *"inspecte puis corrige "*|*"inspecter puis corriger "*|*"structure de projet"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kao_mission_gate_intent() {
    local normalized
    normalized="$(kao_mission_gate_prompt_normalize "$*")"

    case "${normalized}" in
        *"cv"*|*"rédige "*|*"redige "*)
            printf 'document-build\n'
            ;;
        *"dossier "*|*"classe "*|*"organise "*|*"organiser "*)
            printf 'workspace-organization\n'
            ;;
        *"mail"*|*"envoi "*)
            printf 'operator-action\n'
            ;;
        *"service"*|*"corrige "*|*"corriger "*|*"inspecte "*|*"inspecter "*)
            printf 'system-inspection\n'
            ;;
        *"projet"*|*"structure de projet"*)
            printf 'project-structure\n'
            ;;
        *)
            printf 'operator-action\n'
            ;;
    esac
}

kao_mission_gate_mission_label() {
    local normalized
    normalized="$(kao_mission_gate_prompt_normalize "$*")"

    case "${normalized}" in
        *"cv"*)
            printf 'préparer un document opératoire de type cv\n'
            ;;
        *"dossier client"*)
            printf 'organiser un espace de travail client\n'
            ;;
        *"plan d'envoi mail"*)
            printf 'préparer un plan opératoire d’envoi mail\n'
            ;;
        *"service"*)
            printf 'inspecter puis assister une action système\n'
            ;;
        *"structure de projet"*)
            printf 'créer une structure de projet propre\n'
            ;;
        *)
            printf 'préparer une mission opératoire structurée\n'
            ;;
    esac
}

kao_mission_gate_steps() {
    local intent
    intent="$(kao_mission_gate_intent "$*")"

    case "${intent}" in
        document-build)
            printf '%s\n' \
              "1. reconnaissance de la demande" \
              "2. cadrage du document" \
              "3. préparation structurée" \
              "4. validation opérateur"
            ;;
        workspace-organization)
            printf '%s\n' \
              "1. reconnaissance de l’espace cible" \
              "2. cadrage de l’organisation" \
              "3. proposition d’actions ordonnées" \
              "4. validation opérateur"
            ;;
        system-inspection)
            printf '%s\n' \
              "1. reconnaissance du service visé" \
              "2. inspection prudente" \
              "3. proposition de correction" \
              "4. validation opérateur"
            ;;
        project-structure)
            printf '%s\n' \
              "1. reconnaissance du besoin projet" \
              "2. cadrage de la structure" \
              "3. proposition d’arborescence" \
              "4. validation opérateur"
            ;;
        *)
            printf '%s\n' \
              "1. reconnaissance de la demande" \
              "2. cadrage de la mission" \
              "3. préparation structurée" \
              "4. validation opérateur"
            ;;
    esac
}

kao_mission_gate_render() {
    local query intent mission
    query="${*:-}"
    intent="$(kao_mission_gate_intent "${query}")"
    mission="$(kao_mission_gate_mission_label "${query}")"

    cat <<EOF_RENDER
KAO MISSION GATE
recon      : Rekon
guard      : Sentinel
kernel     : Kao

intent     : ${intent}
mission    : ${mission}
agents     : Rekon, Sentinel, Kao
steps      :
EOF_RENDER

    kao_mission_gate_steps "${query}" | sed 's/^/  /'

    cat <<'EOF_RENDER_TAIL'
status     : awaiting-operator-validation

REKON NOTE
- demande reconnue comme missionnable
- ouverture prudente : oui

SENTINEL NOTE
- validation opérateur requise
- exécution non engagée dans ce mode
EOF_RENDER_TAIL
}

kao_mission_gate_handle() {
    local query="${*:-}"

    if ! kao_mission_gate_should_open "${query}"; then
        return 1
    fi

    kao_mission_gate_render "${query}"
    return 0
}
