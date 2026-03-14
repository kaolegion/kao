#!/usr/bin/env bash

intent_prompt_normalize() {
  local prompt
  prompt="${*:-}"
  printf '%s' "${prompt}" | tr '[:upper:]' '[:lower:]'
}

intent_prompt_contains_any() {
  local prompt
  prompt="${1:-}"
  shift || true

  local needle
  for needle in "$@"; do
    if [[ "${prompt}" == *"${needle}"* ]]; then
      return 0
    fi
  done

  return 1
}

intent_classify() {
  local raw normalized
  raw="${*:-}"
  normalized="$(intent_prompt_normalize "${raw}")"

  if [ -z "${normalized}" ]; then
    printf 'unknown\n'
    return 0
  fi

  if intent_prompt_contains_any "${normalized}" \
    "ouvre " \
    "ouvrir " \
    "dossier" \
    "fichier" \
    "répertoire" \
    "repertoire" \
    "ls " \
    "mkdir" \
    "rm " \
    "cp " \
    "mv " \
    "chmod" \
    "chown"; then
    printf 'file-op\n'
    return 0
  fi

  if intent_prompt_contains_any "${normalized}" \
    "service" \
    "daemon" \
    "systemctl" \
    "journalctl" \
    "processus" \
    "process" \
    "réseau" \
    "reseau" \
    "port " \
    "ssh" \
    "docker" \
    "cpu" \
    "ram" \
    "gpu" \
    "kernel"; then
    printf 'system-op\n'
    return 0
  fi

  if intent_prompt_contains_any "${normalized}" \
    "résume" \
    "resume" \
    "synthèse" \
    "synthese" \
    "analyse" \
    "explique" \
    "compare" \
    "stratégie" \
    "strategie" \
    "architecture" \
    "plan" \
    "roadmap" \
    "réunion" \
    "reunion" \
    "vidéo" \
    "video" \
    "transcription"; then
    printf 'cognitive-heavy\n'
    return 0
  fi

  printf 'cognitive-light\n'
}

intent_route_family() {
  local intent
  intent="${1:-unknown}"

  case "${intent}" in
    file-op|system-op)
      printf 'local-agent\n'
      ;;
    cognitive-heavy)
      printf 'llm-heavy\n'
      ;;
    cognitive-light)
      printf 'llm-light\n'
      ;;
    *)
      printf 'unknown\n'
      ;;
  esac
}

intent_action_label() {
  local intent
  intent="${1:-unknown}"

  case "${intent}" in
    file-op)
      printf 'filesystem operator\n'
      ;;
    system-op)
      printf 'system operator\n'
      ;;
    cognitive-heavy)
      printf 'deep cognitive inference\n'
      ;;
    cognitive-light)
      printf 'light cognitive inference\n'
      ;;
    *)
      printf 'unclassified\n'
      ;;
  esac
}

intent_operator_surface() {
  local prompt intent route action
  prompt="${*:-}"
  intent="$(intent_classify "${prompt}")"
  route="$(intent_route_family "${intent}")"
  action="$(intent_action_label "${intent}")"

  printf 'INTENT : %s\n' "${intent}"
  printf 'ROUTE  : %s\n' "${route}"
  printf 'ACTION : %s\n' "${action}"
}
