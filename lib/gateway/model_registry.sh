#!/usr/bin/env bash

if [ -n "${KAO_GATEWAY_MODEL_REGISTRY_LOADED:-}" ]; then
  return 0
fi
KAO_GATEWAY_MODEL_REGISTRY_LOADED=1

KAO_GATEWAY_MODEL_REGISTRY_ROOT="${KAO_GATEWAY_MODEL_REGISTRY_ROOT:-/home/kao}"

gateway_model_registry_entries() {
  cat <<'REGISTRY'
mistral|mistral-medium-latest|cloud|80|unknown
ollama|llama3.2|local|40|unknown
REGISTRY
}

gateway_model_registry_has_provider() {
  local target provider model family base_score runtime_state
  target="${1:-}"

  if [ -z "${target}" ]; then
    return 1
  fi

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  return 1
}

gateway_model_registry_runtime_state() {
  local provider
  provider="${1:-none}"

  case "${provider}" in
    mistral)
      if declare -F gateway_provider_health >/dev/null 2>&1; then
        case "$(gateway_provider_health mistral)" in
          ready) printf 'ready\n' ;;
          blocked-no-secrets) printf 'degraded\n' ;;
          *) printf 'unknown\n' ;;
        esac
      else
        printf 'unknown\n'
      fi
      ;;
    ollama)
      if declare -F gateway_provider_health >/dev/null 2>&1; then
        case "$(gateway_provider_health ollama)" in
          local-stub-ready|local-real-backend-ready|local-real-ready)
            printf 'ready\n'
            ;;
          unavailable)
            printf 'degraded\n'
            ;;
          *)
            printf 'unknown\n'
            ;;
        esac
      else
        printf 'unknown\n'
      fi
      ;;
    *)
      printf 'unknown\n'
      ;;
  esac
}

gateway_model_registry_runtime_score() {
  local provider base_score runtime_state
  provider="${1:-none}"
  base_score="$(gateway_model_registry_base_score "${provider}")"
  runtime_state="$(gateway_model_registry_runtime_state "${provider}")"

  case "${runtime_state}" in
    ready)
      printf '%s\n' "${base_score}"
      ;;
    degraded)
      if [ "${base_score}" -ge 20 ] 2>/dev/null; then
        printf '%s\n' "$((base_score - 20))"
      else
        printf '0\n'
      fi
      ;;
    *)
      printf '%s\n' "${base_score}"
      ;;
  esac
}

gateway_model_registry_provider() {
  local index current provider model family base_score runtime_state
  index="${1:-1}"
  current=0

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    current=$((current + 1))
    if [ "${current}" -eq "${index}" ]; then
      printf '%s\n' "${provider}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  return 1
}

gateway_model_registry_model() {
  local target provider model family base_score runtime_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      printf '%s\n' "${model}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf 'unknown\n'
  return 0
}

gateway_model_registry_family() {
  local target provider model family base_score runtime_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      printf '%s\n' "${family}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf 'unknown\n'
  return 0
}

gateway_model_registry_base_score() {
  local target provider model family base_score runtime_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      printf '%s\n' "${base_score}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf '0\n'
  return 0
}

gateway_model_registry_declared_state() {
  local target provider model family base_score runtime_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      printf '%s\n' "${runtime_state}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf 'unknown\n'
  return 0
}

gateway_model_registry_count() {
  local count provider model family base_score runtime_state
  count=0

  while IFS='|' read -r provider model family base_score runtime_state; do
    [ -n "${provider}" ] || continue
    count=$((count + 1))
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf '%s\n' "${count}"
}

gateway_model_registry_dump() {
  local provider model family base_score declared_state runtime_state runtime_score

  while IFS='|' read -r provider model family base_score declared_state; do
    [ -n "${provider}" ] || continue
    runtime_state="$(gateway_model_registry_runtime_state "${provider}")"
    runtime_score="$(gateway_model_registry_runtime_score "${provider}")"
    printf '%s|%s|%s|%s|%s|%s|%s\n' \
      "${provider}" \
      "${model}" \
      "${family}" \
      "${base_score}" \
      "${declared_state}" \
      "${runtime_state}" \
      "${runtime_score}"
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY
}

gateway_model_registry_operator_surface() {
  local provider model family base_score declared_state runtime_state runtime_score

  printf 'MODEL REGISTRY\n'

  while IFS='|' read -r provider model family base_score declared_state runtime_state runtime_score; do
    [ -n "${provider}" ] || continue
    printf '%s | %s | family %s | base %s | declared %s | runtime %s | score %s\n' \
      "${provider}" \
      "${model}" \
      "${family}" \
      "${base_score}" \
      "${declared_state}" \
      "${runtime_state}" \
      "${runtime_score}"
  done <<EOF_REGISTRY
$(gateway_model_registry_dump)
EOF_REGISTRY
}
