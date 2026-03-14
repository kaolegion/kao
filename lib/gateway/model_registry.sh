#!/usr/bin/env bash

if [ -n "${KAO_GATEWAY_MODEL_REGISTRY_LOADED:-}" ]; then
  return 0
fi
KAO_GATEWAY_MODEL_REGISTRY_LOADED=1

KAO_GATEWAY_MODEL_REGISTRY_ROOT="${KAO_GATEWAY_MODEL_REGISTRY_ROOT:-/home/kao}"

gateway_model_registry_entries() {
  cat <<'REGISTRY'
mistral|mistral-medium-latest|cloud|80|ready
ollama|llama3.2|local|40|degraded
REGISTRY
}

gateway_model_registry_has_provider() {
  local target provider model family base_score declared_state
  target="${1:-}"

  if [ -z "${target}" ]; then
    return 1
  fi

  while IFS='|' read -r provider model family base_score declared_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  return 1
}

gateway_model_registry_provider() {
  local index current provider model family base_score declared_state
  index="${1:-1}"
  current=0

  while IFS='|' read -r provider model family base_score declared_state; do
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
  local target provider model family base_score declared_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score declared_state; do
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
  local target provider model family base_score declared_state
  target="${1:-none}"

  if [ "${target}" = "none" ]; then
    printf 'none\n'
    return 0
  fi

  while IFS='|' read -r provider model family base_score declared_state; do
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
  local target provider model family base_score declared_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score declared_state; do
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
  local target provider model family base_score declared_state
  target="${1:-none}"

  while IFS='|' read -r provider model family base_score declared_state; do
    [ -n "${provider}" ] || continue
    if [ "${provider}" = "${target}" ]; then
      printf '%s\n' "${declared_state}"
      return 0
    fi
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf 'unknown\n'
  return 0
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
          local-real-ready|local-real-backend-ready|local-stub-ready)
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
      if [ "${base_score}" -ge 10 ] 2>/dev/null; then
        printf '%s\n' "$((base_score - 10))"
      else
        printf '0\n'
      fi
      ;;
  esac
}

gateway_model_registry_operator_rank_score() {
  local provider runtime_score declared_state
  provider="${1:-none}"
  runtime_score="$(gateway_model_registry_runtime_score "${provider}")"
  declared_state="$(gateway_model_registry_declared_state "${provider}")"

  case "${declared_state}" in
    ready)
      printf '%s\n' "$((runtime_score + 10))"
      ;;
    degraded)
      if [ "${runtime_score}" -ge 5 ] 2>/dev/null; then
        printf '%s\n' "$((runtime_score - 5))"
      else
        printf '0\n'
      fi
      ;;
    *)
      printf '%s\n' "${runtime_score}"
      ;;
  esac
}

gateway_model_registry_maturity_level() {
  local provider operator_rank_score
  provider="${1:-none}"
  operator_rank_score="$(gateway_model_registry_operator_rank_score "${provider}")"

  if [ "${operator_rank_score}" -ge 90 ] 2>/dev/null; then
    printf 'elite\n'
    return 0
  fi

  if [ "${operator_rank_score}" -ge 70 ] 2>/dev/null; then
    printf 'high\n'
    return 0
  fi

  if [ "${operator_rank_score}" -ge 40 ] 2>/dev/null; then
    printf 'medium\n'
    return 0
  fi

  if [ "${operator_rank_score}" -gt 0 ] 2>/dev/null; then
    printf 'low\n'
    return 0
  fi

  printf 'unknown\n'
}

gateway_model_registry_count() {
  local count provider model family base_score declared_state
  count=0

  while IFS='|' read -r provider model family base_score declared_state; do
    [ -n "${provider}" ] || continue
    count=$((count + 1))
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY

  printf '%s\n' "${count}"
}

gateway_model_registry_dump() {
  local provider model family base_score declared_state runtime_state runtime_score operator_rank_score maturity_level

  while IFS='|' read -r provider model family base_score declared_state; do
    [ -n "${provider}" ] || continue
    runtime_state="$(gateway_model_registry_runtime_state "${provider}")"
    runtime_score="$(gateway_model_registry_runtime_score "${provider}")"
    operator_rank_score="$(gateway_model_registry_operator_rank_score "${provider}")"
    maturity_level="$(gateway_model_registry_maturity_level "${provider}")"

    printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
      "${provider}" \
      "${model}" \
      "${family}" \
      "${base_score}" \
      "${declared_state}" \
      "${runtime_state}" \
      "${runtime_score}" \
      "${operator_rank_score}" \
      "${maturity_level}"
  done <<EOF_REGISTRY
$(gateway_model_registry_entries)
EOF_REGISTRY
}

gateway_model_registry_ranked_dump() {
  gateway_model_registry_dump | sort -t'|' -k8,8nr -k4,4nr -k1,1
}

gateway_model_registry_selected_provider() {
  if declare -F gateway_provider_select >/dev/null 2>&1; then
    gateway_provider_select
    return 0
  fi

  printf 'none\n'
}

gateway_model_registry_selected_model() {
  gateway_model_registry_model "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_family() {
  local selected_provider
  selected_provider="$(gateway_model_registry_selected_provider)"

  if [ "${selected_provider}" = "none" ]; then
    printf 'none\n'
    return 0
  fi

  gateway_model_registry_family "${selected_provider}"
}

gateway_model_registry_selected_base_score() {
  gateway_model_registry_base_score "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_declared_state() {
  gateway_model_registry_declared_state "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_runtime_state() {
  gateway_model_registry_runtime_state "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_runtime_score() {
  gateway_model_registry_runtime_score "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_operator_rank_score() {
  gateway_model_registry_operator_rank_score "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_selected_maturity_level() {
  gateway_model_registry_maturity_level "$(gateway_model_registry_selected_provider)"
}

gateway_model_registry_operator_surface() {
  local provider model family base_score declared_state runtime_state runtime_score operator_rank_score maturity_level

  printf 'MODEL REGISTRY\n'

  while IFS='|' read -r provider model family base_score declared_state runtime_state runtime_score operator_rank_score maturity_level; do
    [ -n "${provider}" ] || continue
    printf '%s | %s | family %s | base %s | declared %s | runtime %s | runtime-score %s | rank %s | maturity %s\n' \
      "${provider}" \
      "${model}" \
      "${family}" \
      "${base_score}" \
      "${declared_state}" \
      "${runtime_state}" \
      "${runtime_score}" \
      "${operator_rank_score}" \
      "${maturity_level}"
  done <<EOF_REGISTRY
$(gateway_model_registry_ranked_dump)
EOF_REGISTRY
}
