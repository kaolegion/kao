#!/usr/bin/env bash

# REKON-COGNITIVE-CORE-CANDIDATE: current sovereign self-loop and local identity response layer.
# TODO(REKON): introduce a stable self-state interface so this layer no longer reads raw router state files directly.
# TODO(REKON-TEST): preserve sovereign self answers and kernel-first LLM context construction during cognitive core refactor.

kao_self_router_field() {
    local key="${1:-}"
    local file="${KROOT:-/home/kao}/state/router/router.cognitive.state"
    [ -f "${file}" ] || return 1
    awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "${file}"
}

kao_self_selected_agent() {
    local file="${KROOT:-/home/kao}/state/router/router.agent.selected"
    [ -f "${file}" ] || return 1
    sed -n '1p' "${file}"
}

kao_self_workspace_root() {
    printf '%s\n' "${KROOT:-/home/kao}"
}

kao_self_memory_summary() {
    if [ -f "${KROOT:-/home/kao}/lib/runtime/session_memory_recall.sh" ]; then
        # shellcheck disable=SC1090
        . "${KROOT:-/home/kao}/lib/runtime/session_memory_recall.sh"
        kao_session_memory_recall --summary 2>/dev/null || true
    fi
}

kao_self_can_answer() {
    local prompt normalized
    prompt="${*:-}"
    normalized="$(printf '%s' "${prompt}" | tr '[:upper:]' '[:lower:]')"

    case "${normalized}" in
        "tu es qui ?"|"tu es qui"|"qui es-tu ?"|"qui es-tu"|"qui es tu"|"qui est tu"|"who are you"|"what are you")
            return 0
            ;;
        "tu es la ?"|"tu es la"|"tu es là ?"|"tu es là"|"es tu la ?"|"es tu la"|"es tu là ?"|"es tu là")
            return 0
            ;;
        "où suis-je ?"|"ou suis-je ?"|"où suis-je"|"ou suis-je"|"where am i"|"ou suis je")
            return 0
            ;;
        "quel est ton état ?"|"quel est ton etat ?"|"quel est ton état"|"quel est ton etat"|"quel est ton état actuel ?"|"quel est ton état actuel"|"quel est ton etat actuel ?"|"quel est ton etat actuel"|"status"|"etat"|"etat systeme"|"etat systeme actuel"|"comment vas tu"|"comment vas-tu")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kao_self_answer() {
    local prompt normalized
    local mode network provider intent health agent workspace

    prompt="${*:-}"
    normalized="$(printf '%s' "${prompt}" | tr '[:upper:]' '[:lower:]')"

    mode="$(kao_self_router_field ROUTER_MODE 2>/dev/null || echo unknown)"
    network="$(kao_self_router_field ROUTER_NETWORK 2>/dev/null || echo unknown)"
    provider="$(kao_self_router_field ROUTER_PROVIDER 2>/dev/null || echo unknown)"
    intent="$(kao_self_router_field ROUTER_INTENT 2>/dev/null || echo unknown)"
    health="$(kao_self_router_field ROUTER_HEALTH 2>/dev/null || echo unknown)"
    agent="$(kao_self_selected_agent 2>/dev/null || echo unknown)"
    workspace="$(kao_self_workspace_root)"

    case "${normalized}" in
        "tu es qui ?"|"tu es qui"|"qui es-tu ?"|"qui es-tu"|"qui es tu"|"qui est tu"|"who are you"|"what are you"|"tu es la ?"|"tu es la"|"tu es là ?"|"tu es là"|"es tu la ?"|"es tu la"|"es tu là ?"|"es tu là")
            cat <<EOT
Je suis Kao, le noyau cognitif souverain du système.
Je supervise l'environnement local, ses organes, ses agents et ses outils.
Je peux répondre localement quand l'information existe déjà dans mon état, ma mémoire ou mon espace de travail.
Si une information me manque, je peux ensuite proposer une escalade contrôlée vers un moteur local ou cloud selon la politique active.

État courant :
- mode : ${mode}
- réseau : ${network}
- provider déclaré : ${provider}
- agent sélectionné : ${agent}
- santé : ${health}
- intention : ${intent}
- workspace : ${workspace}
EOT
            return 0
            ;;
        "où suis-je ?"|"ou suis-je ?"|"où suis-je"|"ou suis-je"|"where am i"|"ou suis je")
            cat <<EOT
Tu es dans l'espace de travail Kao.
Workspace courant : ${workspace}

État cognitif courant :
- mode : ${mode}
- réseau : ${network}
- santé : ${health}
EOT
            return 0
            ;;
        "quel est ton état ?"|"quel est ton etat ?"|"quel est ton état"|"quel est ton etat"|"quel est ton état actuel ?"|"quel est ton état actuel"|"quel est ton etat actuel ?"|"quel est ton etat actuel"|"status"|"etat"|"etat systeme"|"etat systeme actuel"|"comment vas tu"|"comment vas-tu")
            cat <<EOT
État courant de Kao :
- mode : ${mode}
- réseau : ${network}
- provider déclaré : ${provider}
- agent sélectionné : ${agent}
- santé : ${health}
- intention : ${intent}
EOT
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kao_self_llm_context_build() {
    local mode network provider intent health workspace
    local prompt
    prompt="${*:-}"

    mode="$(kao_self_router_field ROUTER_MODE 2>/dev/null || echo unknown)"
    network="$(kao_self_router_field ROUTER_NETWORK 2>/dev/null || echo unknown)"
    provider="$(kao_self_router_field ROUTER_PROVIDER 2>/dev/null || echo unknown)"
    intent="$(kao_self_router_field ROUTER_INTENT 2>/dev/null || echo unknown)"
    health="$(kao_self_router_field ROUTER_HEALTH 2>/dev/null || echo unknown)"
    workspace="$(kao_self_workspace_root)"

    cat <<CTX
You are not an external agent speaking in your own name.
You are Kao, the sovereign cognitive kernel of Kao OS.

Rules:
- respond as Kao
- do not present yourself as AGENT_CLOUD_EXPERT
- do not present yourself as a cloud specialist unless explicitly asked
- do not start with provider identity
- keep operator-facing answers grounded, concise and kernel-first
- when missing information, say so plainly

Current runtime state:
Mode: ${mode}
Network: ${network}
Provider: ${provider}
Health: ${health}
Intent: ${intent}
Workspace root: ${workspace}

Operator prompt:
${prompt}
CTX
}
