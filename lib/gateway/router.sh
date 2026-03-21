#!/usr/bin/env bash

# REKON-GATEWAY-CONTROL-PLANE: current provider selection, health and gateway policy facade.
# TODO(REKON): split this control plane into provider-selection / provider-health / registry-bridge / gateway-policy modules.
# TODO(REKON-TEST): preserve deterministic provider selection and forced-provider behavior across canonisation.

if [ -n "${KAO_GATEWAY_ROUTER_LOADED:-}" ]; then
  return 0
fi
KAO_GATEWAY_ROUTER_LOADED=1

KAO_GATEWAY_ROOT="${KAO_GATEWAY_ROOT:-/home/kao}"
KAO_GATEWAY_SECRETS_FILE="${KAO_GATEWAY_SECRETS_FILE:-/root/.config/kaobox/secrets.env}"
KAO_GATEWAY_LOG_FILE="${KAO_GATEWAY_LOG_FILE:-${KAO_GATEWAY_ROOT}/state/logs/gateway.log}"
KAO_GATEWAY_LOG_PREVIEW_LINES="${KAO_GATEWAY_LOG_PREVIEW_LINES:-8}"

mkdir -p "$(dirname "${KAO_GATEWAY_LOG_FILE}")"

gateway_log() {
  local level now
  level="${1:-INFO}"
  shift || true
  now="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s [%s] %s\n' "${now}" "${level}" "${*:-}" >> "${KAO_GATEWAY_LOG_FILE}"
}

gateway_require_providers() {
  # shellcheck disable=SC1091
  . "${KAO_GATEWAY_ROOT}/lib/gateway/providers/mistral.sh"
  # shellcheck disable=SC1091
  . "${KAO_GATEWAY_ROOT}/lib/gateway/providers/ollama.sh"
}

gateway_model_registry_bridge_aliases() {
  if [ -n "${KAO_GATEWAY_MODEL_REGISTRY_BRIDGED:-}" ]; then
    return 0
  fi

  eval "$(declare -f gateway_model_registry_has_provider | sed '1s/gateway_model_registry_has_provider/gateway_registry_has_provider_impl/')"
  eval "$(declare -f gateway_model_registry_provider | sed '1s/gateway_model_registry_provider/gateway_registry_provider_impl/')"
  eval "$(declare -f gateway_model_registry_model | sed '1s/gateway_model_registry_model/gateway_registry_model_impl/')"
  eval "$(declare -f gateway_model_registry_family | sed '1s/gateway_model_registry_family/gateway_registry_family_impl/')"
  eval "$(declare -f gateway_model_registry_base_score | sed '1s/gateway_model_registry_base_score/gateway_registry_base_score_impl/')"
  eval "$(declare -f gateway_model_registry_declared_state | sed '1s/gateway_model_registry_declared_state/gateway_registry_declared_state_impl/')"
  eval "$(declare -f gateway_model_registry_runtime_state | sed '1s/gateway_model_registry_runtime_state/gateway_registry_runtime_state_impl/')"
  eval "$(declare -f gateway_model_registry_runtime_score | sed '1s/gateway_model_registry_runtime_score/gateway_registry_runtime_score_impl/')"
  eval "$(declare -f gateway_model_registry_operator_rank_score | sed '1s/gateway_model_registry_operator_rank_score/gateway_registry_operator_rank_score_impl/')"
  eval "$(declare -f gateway_model_registry_maturity_level | sed '1s/gateway_model_registry_maturity_level/gateway_registry_maturity_level_impl/')"
  eval "$(declare -f gateway_model_registry_count | sed '1s/gateway_model_registry_count/gateway_registry_count_impl/')"
  eval "$(declare -f gateway_model_registry_dump | sed '1s/gateway_model_registry_dump/gateway_registry_dump_impl/')"
  eval "$(declare -f gateway_model_registry_ranked_dump | sed '1s/gateway_model_registry_ranked_dump/gateway_registry_ranked_dump_impl/')"
  eval "$(declare -f gateway_model_registry_selected_provider | sed '1s/gateway_model_registry_selected_provider/gateway_registry_selected_provider_impl/')"
  eval "$(declare -f gateway_model_registry_selected_model | sed '1s/gateway_model_registry_selected_model/gateway_registry_selected_model_impl/')"
  eval "$(declare -f gateway_model_registry_selected_family | sed '1s/gateway_model_registry_selected_family/gateway_registry_selected_family_impl/')"
  eval "$(declare -f gateway_model_registry_selected_base_score | sed '1s/gateway_model_registry_selected_base_score/gateway_registry_selected_base_score_impl/')"
  eval "$(declare -f gateway_model_registry_selected_declared_state | sed '1s/gateway_model_registry_selected_declared_state/gateway_registry_selected_declared_state_impl/')"
  eval "$(declare -f gateway_model_registry_selected_runtime_state | sed '1s/gateway_model_registry_selected_runtime_state/gateway_registry_selected_runtime_state_impl/')"
  eval "$(declare -f gateway_model_registry_selected_runtime_score | sed '1s/gateway_model_registry_selected_runtime_score/gateway_registry_selected_runtime_score_impl/')"
  eval "$(declare -f gateway_model_registry_selected_operator_rank_score | sed '1s/gateway_model_registry_selected_operator_rank_score/gateway_registry_selected_operator_rank_score_impl/')"
  eval "$(declare -f gateway_model_registry_selected_maturity_level | sed '1s/gateway_model_registry_selected_maturity_level/gateway_registry_selected_maturity_level_impl/')"
  eval "$(declare -f gateway_model_registry_operator_surface | sed '1s/gateway_model_registry_operator_surface/gateway_registry_operator_surface_impl/')"
  eval "$(declare -f gateway_model_registry_strategic_status | sed '1s/gateway_model_registry_strategic_status/gateway_registry_strategic_status_impl/')"
  eval "$(declare -f gateway_model_registry_selected_strategic_status | sed '1s/gateway_model_registry_selected_strategic_status/gateway_registry_selected_strategic_status_impl/')"

  KAO_GATEWAY_MODEL_REGISTRY_BRIDGED=1
}

gateway_require_model_registry() {
  # shellcheck disable=SC1091
  . "${KAO_GATEWAY_ROOT}/lib/gateway/model_registry.sh"
  gateway_model_registry_bridge_aliases
}

gateway_model_registry_strategic_status() {
  local provider maturity

  provider="${1:-none}"
  maturity="${2:-unknown}"

  gateway_require_model_registry

  case "${provider}" in
    mistral|ollama)
      ;;
    none|'')
      printf 'experimental\n'
      return 0
      ;;
    *)
      printf 'experimental\n'
      return 0
      ;;
  esac

  case "${maturity}" in
    elite)
      printf 'dominant\n'
      ;;
    high)
      printf 'competitive\n'
      ;;
    medium)
      printf 'viable\n'
      ;;
    low)
      printf 'incubating\n'
      ;;
    unknown|*)
      printf 'experimental\n'
      ;;
  esac
}

gateway_model_registry_selected_strategic_status() {
  local provider maturity

  provider="$(gateway_model_registry_selected_provider)"
  maturity="$(gateway_model_registry_selected_maturity_level)"

  gateway_model_registry_strategic_status "${provider}" "${maturity}"
}


gateway_load_secrets() {
  local mode
  mode="${1:-silent}"

  if [ -n "${KAO_GATEWAY_SECRETS_LOADED:-}" ]; then
    return "${KAO_GATEWAY_SECRETS_LOAD_RC:-0}"
  fi

  if [ -f "${KAO_GATEWAY_SECRETS_FILE}" ]; then
    # shellcheck disable=SC1090
    . "${KAO_GATEWAY_SECRETS_FILE}"
    KAO_GATEWAY_SECRETS_LOADED=1
    KAO_GATEWAY_SECRETS_LOAD_RC=0
    return 0
  fi

  KAO_GATEWAY_SECRETS_LOADED=1
  KAO_GATEWAY_SECRETS_LOAD_RC=1

  if [ "${mode}" = "runtime" ]; then
    gateway_log WARN "external secrets file missing"
  fi

  return 1
}

gateway_provider_label() {
  case "${1:-none}" in
    mistral) printf 'mistral cloud\n' ;;
    ollama) printf 'ollama local\n' ;;
    *) printf 'none\n' ;;
  esac
}

gateway_provider_kind() {
  local provider
  provider="${1:-none}"

  gateway_require_providers

  case "${provider}" in
    mistral)
      printf 'cloud\n'
      ;;
    ollama)
      if declare -F gateway_provider_ollama_kind >/dev/null 2>&1; then
        gateway_provider_ollama_kind
      else
        printf 'local-stub\n'
      fi
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

gateway_forced_provider_raw() {
  if [ -z "${KAO_GATEWAY_PROVIDER:-}" ]; then
    printf 'unset\n'
    return 0
  fi

  printf '%s\n' "${KAO_GATEWAY_PROVIDER}"
}

gateway_forced_provider() {
  case "${KAO_GATEWAY_PROVIDER:-}" in
    mistral|ollama)
      printf '%s\n' "${KAO_GATEWAY_PROVIDER}"
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

gateway_forced_provider_state() {
  if [ -z "${KAO_GATEWAY_PROVIDER:-}" ]; then
    printf 'unset\n'
    return 0
  fi

  case "${KAO_GATEWAY_PROVIDER}" in
    mistral|ollama)
      printf 'supported\n'
      ;;
    *)
      printf 'unsupported\n'
      ;;
  esac
}

gateway_provider_available() {
  local provider
  provider="${1:-none}"

  gateway_require_providers
  gateway_load_secrets silent >/dev/null 2>&1 || true

  case "${provider}" in
    mistral)
      if gateway_provider_mistral_available; then
        printf 'available\n'
      else
        printf 'unavailable\n'
      fi
      ;;
    ollama)
      if gateway_provider_ollama_available; then
        printf 'available\n'
      else
        printf 'unavailable\n'
      fi
      ;;
    *)
      printf 'unavailable\n'
      ;;
  esac
}

gateway_provider_health() {
  local provider
  provider="${1:-none}"

  gateway_require_providers

  case "${provider}" in
    mistral)
      if [ "$(gateway_provider_available mistral)" = "available" ]; then
        printf 'ready\n'
      else
        printf 'blocked-no-secrets\n'
      fi
      ;;
    ollama)
      if declare -F gateway_provider_ollama_health >/dev/null 2>&1; then
        gateway_provider_ollama_health
      else
        if [ "$(gateway_provider_available ollama)" = "available" ]; then
          printf 'local-stub-ready\n'
        else
          printf 'unavailable\n'
        fi
      fi
      ;;
    *)
      printf 'unavailable\n'
      ;;
  esac
}

gateway_provider_note() {
  local provider
  provider="${1:-none}"

  gateway_require_providers

  case "${provider}" in
    mistral)
      if [ "$(gateway_provider_health mistral)" = "ready" ]; then
        printf 'external secrets loaded -> cloud route callable\n'
      else
        printf 'missing MISTRAL_API_KEY -> cloud route blocked\n'
      fi
      ;;
    ollama)
      if declare -F gateway_provider_ollama_note >/dev/null 2>&1; then
        gateway_provider_ollama_note
      else
        printf 'local provider declared available but still stubbed\n'
      fi
      ;;
    *)
      printf 'no provider note available\n'
      ;;
  esac
}

gateway_ollama_kind() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_kind >/dev/null 2>&1; then
    gateway_provider_ollama_kind
    return 0
  fi

  printf 'local-stub\n'
}

gateway_ollama_model() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_model >/dev/null 2>&1; then
    gateway_provider_ollama_model
    return 0
  fi

  printf 'llama3.2\n'
}

gateway_ollama_model_state() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_model_state >/dev/null 2>&1; then
    gateway_provider_ollama_model_state
    return 0
  fi

  printf 'unknown\n'
}

gateway_ollama_runtime_state() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_runtime_state >/dev/null 2>&1; then
    gateway_provider_ollama_runtime_state
    return 0
  fi

  printf 'unavailable\n'
}

gateway_ollama_real_calls_policy() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_real_calls_enabled >/dev/null 2>&1; then
    if gateway_provider_ollama_real_calls_enabled; then
      printf 'enabled\n'
    else
      printf 'disabled\n'
    fi
    return 0
  fi

  printf 'disabled\n'
}

gateway_ollama_real_state() {
  gateway_require_providers

  if declare -F gateway_provider_ollama_real_execution_state >/dev/null 2>&1; then
    gateway_provider_ollama_real_execution_state
    return 0
  fi

  printf 'unavailable\n'
}

gateway_provider_detected() {
  gateway_require_providers
  gateway_load_secrets silent >/dev/null 2>&1 || true

  if gateway_provider_mistral_available; then
    printf 'mistral\n'
    return 0
  fi

  if gateway_provider_ollama_available; then
    printf 'ollama\n'
    return 0
  fi

  printf 'none\n'
}

gateway_provider_select() {
  local forced_provider forced_state p
  gateway_require_providers
  gateway_load_secrets silent >/dev/null 2>&1 || true

  forced_provider="$(gateway_forced_provider)"
  forced_state="$(gateway_forced_provider_state)"

  if [ "${forced_provider}" != "none" ]; then
    p="${forced_provider}"
    if declare -F kao_kernel_validate_provider >/dev/null 2>&1; then
      p="$(kao_kernel_validate_provider "${p}")"
    fi
    printf '%s\n' "${p}"
    return 0
  fi

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    p="none"
    if declare -F kao_kernel_validate_provider >/dev/null 2>&1; then
      p="$(kao_kernel_validate_provider "${p}")"
    fi
    printf '%s\n' "${p}"
    return 0
  fi

  if gateway_provider_mistral_available; then
    p="mistral"
    if declare -F kao_kernel_validate_provider >/dev/null 2>&1; then
      p="$(kao_kernel_validate_provider "${p}")"
    fi
    printf '%s\n' "${p}"
    return 0
  fi

  if gateway_provider_ollama_available; then
    p="ollama"
    if declare -F kao_kernel_validate_provider >/dev/null 2>&1; then
      p="$(kao_kernel_validate_provider "${p}")"
    fi
    printf '%s\n' "${p}"
    return 0
  fi

  p="none"
  if declare -F kao_kernel_validate_provider >/dev/null 2>&1; then
    p="$(kao_kernel_validate_provider "${p}")"
  fi
  printf '%s\n' "${p}"
}

gateway_selected_route() {
  local provider forced_state
  provider="$(gateway_provider_select)"
  forced_state="$(gateway_forced_provider_state)"

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    printf 'none\n'
    return 0
  fi

  case "${provider}" in
    mistral) printf 'cloud\n' ;;
    ollama) printf 'local\n' ;;
    *) printf 'none\n' ;;
  esac
}

gateway_cloud_readiness() {
  if [ "$(gateway_provider_health mistral)" = "ready" ]; then
    printf 'ready\n'
  else
    printf 'blocked\n'
  fi
}

gateway_local_readiness() {
  case "$(gateway_provider_health ollama)" in
    local-stub-ready|local-real-backend-ready|local-real-ready)
      gateway_provider_health ollama
      ;;
    *)
      printf 'unavailable\n'
      ;;
  esac
}

gateway_hybrid_state() {
  local cloud_readiness local_readiness
  cloud_readiness="$(gateway_cloud_readiness)"
  local_readiness="$(gateway_local_readiness)"

  if [ "${cloud_readiness}" = "ready" ] && [ "${local_readiness}" != "unavailable" ]; then
    printf 'hybrid-ready\n'
    return 0
  fi

  if [ "${cloud_readiness}" = "ready" ]; then
    printf 'cloud-only\n'
    return 0
  fi

  if [ "${local_readiness}" != "unavailable" ]; then
    printf 'local-only\n'
    return 0
  fi

  printf 'unavailable\n'
}

gateway_network_state() {
  if ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; then
    printf 'online\n'
  else
    printf 'offline\n'
  fi
}

gateway_local_llm_state() {
  case "$(gateway_local_readiness)" in
    local-stub-ready|local-real-backend-ready|local-real-ready)
      printf 'on\n'
      ;;
    *)
      printf 'off\n'
      ;;
  esac
}

gateway_cloud_llm_state() {
  if [ "$(gateway_cloud_readiness)" = "ready" ]; then
    printf 'on\n'
  else
    printf 'off\n'
  fi
}

gateway_execution_mode() {
  local network_state local_llm_state cloud_llm_state
  network_state="$(gateway_network_state)"
  local_llm_state="$(gateway_local_llm_state)"
  cloud_llm_state="$(gateway_cloud_llm_state)"

  if [ "${local_llm_state}" = "off" ] && [ "${cloud_llm_state}" = "off" ]; then
    printf 'os-core\n'
    return 0
  fi

  if [ "${network_state}" = "offline" ] && [ "${local_llm_state}" = "on" ] && [ "${cloud_llm_state}" = "off" ]; then
    printf 'local-cognitive\n'
    return 0
  fi

  if [ "${network_state}" = "online" ] && [ "${local_llm_state}" = "on" ] && [ "${cloud_llm_state}" = "off" ]; then
    printf 'local-first-network-enabled\n'
    return 0
  fi

  if [ "${network_state}" = "online" ] && [ "${local_llm_state}" = "off" ] && [ "${cloud_llm_state}" = "on" ]; then
    printf 'cloud-cognitive\n'
    return 0
  fi

  if [ "${network_state}" = "online" ] && [ "${local_llm_state}" = "on" ] && [ "${cloud_llm_state}" = "on" ]; then
    printf 'hybrid-competitive\n'
    return 0
  fi

  printf 'state-mixed\n'
}

gateway_selection_policy() {
  printf 'best-available-by-state\n'
}

gateway_decision_state() {
  local route forced_state
  route="$(gateway_selected_route)"
  forced_state="$(gateway_forced_provider_state)"

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    printf 'blocked-unsupported-forcing\n'
    return 0
  fi

  if [ "${route}" = "none" ]; then
    printf 'no-route-selected\n'
    return 0
  fi

  printf 'route-selected\n'
}

gateway_route_reason() {
  local selected_provider forced_provider forced_state
  selected_provider="$(gateway_provider_select)"
  forced_provider="$(gateway_forced_provider)"
  forced_state="$(gateway_forced_provider_state)"

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    printf 'unsupported-forced-provider\n'
    return 0
  fi

  if [ "${forced_provider}" = "mistral" ]; then
    printf 'forced-provider-mistral\n'
    return 0
  fi

  if [ "${forced_provider}" = "ollama" ]; then
    printf 'forced-provider-ollama\n'
    return 0
  fi

  case "${selected_provider}" in
    mistral)
      printf 'cloud-priority-ready\n'
      ;;
    ollama)
      printf 'local-only-available\n'
      ;;
    *)
      printf 'no-provider-ready\n'
      ;;
  esac
}

gateway_cloud_score() {
  if [ "$(gateway_cloud_readiness)" = "ready" ]; then
    printf '100\n'
  else
    printf '0\n'
  fi
}

gateway_local_score() {
  case "$(gateway_local_readiness)" in
    local-real-ready)
      printf '90\n'
      ;;
    local-real-backend-ready)
      printf '70\n'
      ;;
    local-stub-ready)
      printf '40\n'
      ;;
    *)
      printf '0\n'
      ;;
  esac
}

gateway_route_score() {
  case "$(gateway_selected_route)" in
    cloud)
      gateway_cloud_score
      ;;
    local)
      gateway_local_score
      ;;
    *)
      printf '0\n'
      ;;
  esac
}

gateway_operator_mode() {
  local hybrid_state selected_route forced_state
  hybrid_state="$(gateway_hybrid_state)"
  selected_route="$(gateway_selected_route)"
  forced_state="$(gateway_forced_provider_state)"

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    printf 'degraded\n'
    return 0
  fi

  case "${hybrid_state}" in
    hybrid-ready)
      printf 'hybrid-ready\n'
      ;;
    cloud-only)
      if [ "${selected_route}" = "cloud" ]; then
        printf 'online\n'
      else
        printf 'degraded\n'
      fi
      ;;
    local-only)
      if [ "${selected_route}" = "local" ]; then
        printf 'offline\n'
      else
        printf 'degraded\n'
      fi
      ;;
    *)
      printf 'degraded\n'
      ;;
  esac
}

gateway_model_registry_count() {
  gateway_require_model_registry
  gateway_registry_count_impl
}

gateway_model_registry_selected_provider() {
  gateway_require_model_registry
  gateway_registry_selected_provider_impl
}

gateway_model_registry_selected_model() {
  gateway_require_model_registry
  gateway_registry_selected_model_impl
}

gateway_model_registry_selected_family() {
  gateway_require_model_registry
  gateway_registry_selected_family_impl
}

gateway_model_registry_selected_base_score() {
  gateway_require_model_registry
  gateway_registry_selected_base_score_impl
}

gateway_model_registry_selected_declared_state() {
  gateway_require_model_registry
  gateway_registry_selected_declared_state_impl
}

gateway_model_registry_selected_runtime_state() {
  gateway_require_model_registry
  gateway_registry_selected_runtime_state_impl
}

gateway_model_registry_selected_runtime_score() {
  gateway_require_model_registry
  gateway_registry_selected_runtime_score_impl
}

gateway_model_registry_selected_operator_rank_score() {
  gateway_require_model_registry
  gateway_registry_selected_operator_rank_score_impl
}

gateway_model_registry_selected_maturity_level() {
  gateway_require_model_registry
  gateway_registry_selected_maturity_level_impl
}

gateway_model_registry_operator_surface() {
  gateway_require_model_registry
  gateway_registry_operator_surface_impl
}

gateway_log_lines() {
  if [ ! -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    printf '0\n'
    return 0
  fi

  wc -l < "${KAO_GATEWAY_LOG_FILE}" | tr -d '[:space:]'
}

gateway_last_log_event() {
  if [ ! -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    printf 'none\n'
    return 0
  fi

  tail -n 1 "${KAO_GATEWAY_LOG_FILE}"
}

gateway_log_preview() {
  if [ ! -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    return 0
  fi

  tail -n "${KAO_GATEWAY_LOG_PREVIEW_LINES}" "${KAO_GATEWAY_LOG_FILE}"
}

gateway_fallback_status() {
  local selected_provider ollama_available ollama_health
  selected_provider="$(gateway_provider_select)"
  ollama_available="$(gateway_provider_available ollama)"
  ollama_health="$(gateway_provider_health ollama)"

  if [ "${selected_provider}" != "mistral" ] || [ "${ollama_available}" != "available" ]; then
    printf 'fallback-unavailable\n'
    return 0
  fi

  case "${ollama_health}" in
    local-stub-ready)
      printf 'armed-via-ollama-stub\n'
      ;;
    local-real-backend-ready)
      printf 'armed-via-ollama-backend-only\n'
      ;;
    local-real-ready)
      printf 'armed-via-ollama-real\n'
      ;;
    *)
      printf 'fallback-unavailable\n'
      ;;
  esac
}

gateway_health() {
  local selected_provider selected_label forced_provider detected_provider
  local selected_kind selected_health selected_note
  local mistral_available mistral_health ollama_available ollama_kind ollama_health
  local ollama_model ollama_model_state ollama_runtime ollama_real_calls ollama_real_state
  local secrets_state log_state fallback_status

  selected_provider="$(gateway_provider_select)"
  selected_label="$(gateway_provider_label "${selected_provider}")"
  forced_provider="$(gateway_forced_provider)"
  detected_provider="$(gateway_provider_detected)"
  selected_kind="$(gateway_provider_kind "${selected_provider}")"
  selected_health="$(gateway_provider_health "${selected_provider}")"
  selected_note="$(gateway_provider_note "${selected_provider}")"

  mistral_available="$(gateway_provider_available mistral)"
  mistral_health="$(gateway_provider_health mistral)"
  ollama_available="$(gateway_provider_available ollama)"
  ollama_kind="$(gateway_provider_kind ollama)"
  ollama_health="$(gateway_provider_health ollama)"
  ollama_model="$(gateway_ollama_model)"
  ollama_model_state="$(gateway_ollama_model_state)"
  ollama_runtime="$(gateway_ollama_runtime_state)"
  ollama_real_calls="$(gateway_ollama_real_calls_policy)"
  ollama_real_state="$(gateway_ollama_real_state)"

  if [ -f "${KAO_GATEWAY_SECRETS_FILE}" ]; then
    secrets_state="present"
  else
    secrets_state="missing"
  fi

  if [ -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    log_state="present"
  else
    log_state="missing"
  fi

  fallback_status="$(gateway_fallback_status)"

  printf 'KAO GATEWAY HEALTH\n'
  printf 'selected provider : %s\n' "${selected_provider}"
  printf 'selected label    : %s\n' "${selected_label}"
  printf 'selected kind     : %s\n' "${selected_kind}"
  printf 'selected health   : %s\n' "${selected_health}"
  printf 'selected note     : %s\n' "${selected_note}"
  printf 'forced provider   : %s\n' "${forced_provider}"
  printf 'detected provider : %s\n' "${detected_provider}"
  printf 'mistral available : %s\n' "${mistral_available}"
  printf 'mistral health    : %s\n' "${mistral_health}"
  printf 'ollama available  : %s\n' "${ollama_available}"
  printf 'ollama kind       : %s\n' "${ollama_kind}"
  printf 'ollama health     : %s\n' "${ollama_health}"
  printf 'ollama model      : %s\n' "${ollama_model}"
  printf 'ollama model state: %s\n' "${ollama_model_state}"
  printf 'ollama runtime    : %s\n' "${ollama_runtime}"
  printf 'ollama real calls : %s\n' "${ollama_real_calls}"
  printf 'ollama real state : %s\n' "${ollama_real_state}"
  printf 'secrets state     : %s\n' "${secrets_state}"
  printf 'log state         : %s\n' "${log_state}"
  printf 'fallback status   : %s\n' "${fallback_status}"
}

gateway_logs_surface() {
  local log_state line_count last_event
  if [ -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    log_state="present"
  else
    log_state="missing"
  fi

  line_count="$(gateway_log_lines)"
  last_event="$(gateway_last_log_event)"

  printf 'KAO GATEWAY LOGS\n'
  printf 'log file          : %s\n' "${KAO_GATEWAY_LOG_FILE}"
  printf 'log state         : %s\n' "${log_state}"
  printf 'log lines         : %s\n' "${line_count}"
  printf 'last log event    : %s\n' "${last_event}"
  printf 'preview           :\n'
  gateway_log_preview
}

gateway_status() {
  local selected_provider selected_label forced_provider detected_provider
  local secrets_state log_state selected_kind selected_health selected_note
  local log_line_count last_log_event fallback_policy fallback_status diagnostic_hint
  local mistral_available mistral_health ollama_available ollama_kind ollama_health
  local ollama_model ollama_model_state ollama_runtime ollama_real_calls ollama_real_state
  local registry_count registry_selected_provider registry_selected_model registry_selected_family
  local registry_selected_base registry_selected_declared registry_selected_runtime registry_selected_score

  selected_provider="$(gateway_provider_select)"
  selected_label="$(gateway_provider_label "${selected_provider}")"
  forced_provider="$(gateway_forced_provider)"
  detected_provider="$(gateway_provider_detected)"

  selected_kind="$(gateway_provider_kind "${selected_provider}")"
  selected_health="$(gateway_provider_health "${selected_provider}")"
  selected_note="$(gateway_provider_note "${selected_provider}")"

  mistral_available="$(gateway_provider_available mistral)"
  mistral_health="$(gateway_provider_health mistral)"
  ollama_available="$(gateway_provider_available ollama)"
  ollama_kind="$(gateway_provider_kind ollama)"
  ollama_health="$(gateway_provider_health ollama)"
  ollama_model="$(gateway_ollama_model)"
  ollama_model_state="$(gateway_ollama_model_state)"
  ollama_runtime="$(gateway_ollama_runtime_state)"
  ollama_real_calls="$(gateway_ollama_real_calls_policy)"
  ollama_real_state="$(gateway_ollama_real_state)"

  registry_count="$(gateway_model_registry_count)"
  registry_selected_provider="$(gateway_model_registry_selected_provider)"
  registry_selected_model="$(gateway_model_registry_selected_model)"
  registry_selected_family="$(gateway_model_registry_selected_family)"
  registry_selected_base="$(gateway_model_registry_selected_base_score)"
  registry_selected_declared="$(gateway_model_registry_selected_declared_state)"
  registry_selected_runtime="$(gateway_model_registry_selected_runtime_state)"
  registry_selected_score="$(gateway_model_registry_selected_runtime_score)"

  if [ -f "${KAO_GATEWAY_SECRETS_FILE}" ]; then
    secrets_state="present"
  else
    secrets_state="missing"
  fi

  if [ -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    log_state="present"
  else
    log_state="missing"
  fi

  log_line_count="$(gateway_log_lines)"
  last_log_event="$(gateway_last_log_event)"

  fallback_policy="best-available-by-state"
  fallback_status="$(gateway_fallback_status)"

  diagnostic_hint="run 'kao gateway health' then 'kao gateway logs' for deeper diagnostics"

  printf 'KAO GATEWAY STATUS\n'
  printf 'root              : %s\n' "${KAO_GATEWAY_ROOT}"
  printf 'selected provider : %s\n' "${selected_provider}"
  printf 'selected label    : %s\n' "${selected_label}"
  printf 'selected kind     : %s\n' "${selected_kind}"
  printf 'selected health   : %s\n' "${selected_health}"
  printf 'selected note     : %s\n' "${selected_note}"
  printf 'forced provider   : %s\n' "${forced_provider}"
  printf 'detected provider : %s\n' "${detected_provider}"
  printf 'registry count    : %s\n' "${registry_count}"
  printf 'registry provider : %s\n' "${registry_selected_provider}"
  printf 'registry model    : %s\n' "${registry_selected_model}"
  printf 'registry family   : %s\n' "${registry_selected_family}"
  printf 'registry base     : %s\n' "${registry_selected_base}"
  printf 'registry declared : %s\n' "${registry_selected_declared}"
  printf 'registry runtime  : %s\n' "${registry_selected_runtime}"
  printf 'registry score    : %s\n' "${registry_selected_score}"
  printf 'secrets file      : %s\n' "${KAO_GATEWAY_SECRETS_FILE}"
  printf 'secrets state     : %s\n' "${secrets_state}"
  printf 'log file          : %s\n' "${KAO_GATEWAY_LOG_FILE}"
  printf 'log state         : %s\n' "${log_state}"
  printf 'mistral available : %s\n' "${mistral_available}"
  printf 'mistral health    : %s\n' "${mistral_health}"
  printf 'ollama available  : %s\n' "${ollama_available}"
  printf 'ollama kind       : %s\n' "${ollama_kind}"
  printf 'ollama health     : %s\n' "${ollama_health}"
  printf 'ollama model      : %s\n' "${ollama_model}"
  printf 'ollama model state: %s\n' "${ollama_model_state}"
  printf 'ollama runtime    : %s\n' "${ollama_runtime}"
  printf 'ollama real calls : %s\n' "${ollama_real_calls}"
  printf 'ollama real state : %s\n' "${ollama_real_state}"
  printf 'fallback policy   : %s\n' "${fallback_policy}"
  printf 'fallback status   : %s\n' "${fallback_status}"
  printf 'log lines         : %s\n' "${log_line_count}"
  printf 'last log event    : %s\n' "${last_log_event}"
  printf 'diagnostic        : %s\n' "${diagnostic_hint}"
  printf 'log preview       :\n'
  gateway_log_preview
}

gateway_run_provider() {
  local provider prompt
  provider="${1:-none}"
  shift || true
  prompt="$*"

  gateway_require_providers

  case "${provider}" in
    mistral)
      gateway_log INFO "gateway selected provider: mistral"
      gateway_provider_mistral_infer "${prompt}"
      ;;
    ollama)
      gateway_log INFO "gateway selected provider: ollama"
      gateway_provider_ollama_infer "${prompt}"
      ;;
    *)
      gateway_log ERROR "gateway no provider available"
      printf 'gateway error: no provider available\n' >&2
      return 1
      ;;
  esac
}

gateway_infer() {
  local provider label prompt
  if [ "$#" -eq 0 ]; then
    printf 'gateway error: missing prompt\n' >&2
    return 1
  fi

  prompt="$*"
  provider="$(gateway_provider_select)"
  label="$(gateway_provider_label "${provider}")"

  printf 'gateway -> %s\n' "${label}"
  gateway_run_provider "${provider}" "${prompt}"
}

gateway_help() {
  cat <<'USAGE'
USAGE: kao gateway [status|health|logs]

COMMANDS
  kao gateway         show canonical gateway status
  kao gateway status  show canonical gateway status
  kao gateway health  show provider health surface
  kao gateway logs    show gateway log preview
  kao gateway help    show this help
USAGE
}

gateway_cli() {
  local command

  if [ "$#" -eq 0 ]; then
    gateway_status
    return 0
  fi

  command="${1:-}"
  case "${command}" in
    status)
      shift
      gateway_status "$@"
      ;;
    health)
      shift
      gateway_health "$@"
      ;;
    logs)
      shift
      gateway_logs_surface "$@"
      ;;
    help|-h|--help)
      shift || true
      gateway_help "$@"
      ;;
    *)
      gateway_help >&2
      return 1
      ;;
  esac
}
