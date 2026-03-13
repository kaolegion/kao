#!/usr/bin/env bash

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
  local forced_provider forced_state
  gateway_require_providers
  gateway_load_secrets silent >/dev/null 2>&1 || true

  forced_provider="$(gateway_forced_provider)"
  forced_state="$(gateway_forced_provider_state)"

  if [ "${forced_provider}" != "none" ]; then
    printf '%s\n' "${forced_provider}"
    return 0
  fi

  if [ -n "${KAO_GATEWAY_PROVIDER:-}" ] && [ "${forced_state}" = "unsupported" ]; then
    printf 'none\n'
    return 0
  fi

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

gateway_secrets_state() {
  if [ -f "${KAO_GATEWAY_SECRETS_FILE}" ]; then
    printf 'present\n'
  else
    printf 'missing\n'
  fi
}

gateway_log_state() {
  if [ -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    printf 'present\n'
  else
    printf 'missing\n'
  fi
}

gateway_log_line_count() {
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

  tail -n 1 "${KAO_GATEWAY_LOG_FILE}" 2>/dev/null || printf 'none\n'
}

gateway_log_preview() {
  if [ ! -f "${KAO_GATEWAY_LOG_FILE}" ]; then
    printf '(no gateway log yet)\n'
    return 0
  fi

  tail -n "${KAO_GATEWAY_LOG_PREVIEW_LINES}" "${KAO_GATEWAY_LOG_FILE}" 2>/dev/null || true
}

gateway_log_preview_print() {
  local line
  while IFS= read -r line; do
    printf '  %s\n' "${line}"
  done <<EOF_PREVIEW
$(gateway_log_preview)
EOF_PREVIEW
}

gateway_fallback_policy() {
  printf 'mistral -> ollama on inference failure\n'
}

gateway_fallback_status() {
  case "$(gateway_provider_health ollama)" in
    local-real-ready)
      printf 'armed-via-ollama-real\n'
      ;;
    local-real-backend-ready)
      printf 'armed-via-ollama-backend-only\n'
      ;;
    local-stub-ready)
      printf 'armed-via-ollama-stub\n'
      ;;
    *)
      printf 'fallback-unavailable\n'
      ;;
  esac
}

gateway_operator_hint() {
  local selected forced_provider secrets_state ollama_real_state detected_provider
  selected="$(gateway_provider_select)"
  forced_provider="$(gateway_forced_provider)"
  detected_provider="$(gateway_provider_detected)"
  secrets_state="$(gateway_secrets_state)"
  ollama_real_state="$(gateway_ollama_real_state)"

  if [ "${forced_provider}" = "ollama" ]; then
    printf 'forced provider active -> ollama (%s / %s / model=%s / real=%s)\n' \
      "$(gateway_provider_kind ollama)" \
      "$(gateway_provider_health ollama)" \
      "$(gateway_ollama_model_state)" \
      "${ollama_real_state}"
    return 0
  fi

  if [ "${forced_provider}" = "mistral" ]; then
    printf 'forced provider active -> mistral cloud\n'
    return 0
  fi

  if [ "${selected}" = "mistral" ] && [ "${secrets_state}" = "present" ]; then
    printf 'cloud route ready -> mistral selected from external secrets\n'
    return 0
  fi

  if [ "${selected}" = "ollama" ] && [ "${detected_provider}" = "ollama" ]; then
    printf 'local route active -> ollama selected (%s / %s / model=%s / real=%s)\n' \
      "$(gateway_provider_kind ollama)" \
      "$(gateway_provider_health ollama)" \
      "$(gateway_ollama_model_state)" \
      "${ollama_real_state}"
    return 0
  fi

  if [ "${selected}" = "none" ]; then
    printf 'no provider ready -> verify secrets or local provider runtime\n'
    return 0
  fi

  printf 'gateway inspection available -> verify selected provider and fallback status\n'
}

gateway_print_status() {
  local selected forced_provider forced_state detected_provider
  local selected_label selected_kind selected_health selected_note
  local mistral_available mistral_health mistral_note
  local ollama_available ollama_kind ollama_health ollama_note
  local ollama_model ollama_model_state ollama_runtime_state
  local ollama_real_calls ollama_real_state
  local secrets_state log_state log_lines last_log_event fallback_policy fallback_status operator_hint

  selected="$(gateway_provider_select)"
  forced_provider="$(gateway_forced_provider)"
  forced_state="$(gateway_forced_provider_state)"
  detected_provider="$(gateway_provider_detected)"

  selected_label="$(gateway_provider_label "${selected}")"
  selected_kind="$(gateway_provider_kind "${selected}")"
  selected_health="$(gateway_provider_health "${selected}")"
  selected_note="$(gateway_provider_note "${selected}")"

  mistral_available="$(gateway_provider_available mistral)"
  mistral_health="$(gateway_provider_health mistral)"
  mistral_note="$(gateway_provider_note mistral)"

  ollama_available="$(gateway_provider_available ollama)"
  ollama_kind="$(gateway_ollama_kind)"
  ollama_health="$(gateway_provider_health ollama)"
  ollama_note="$(gateway_provider_note ollama)"
  ollama_model="$(gateway_ollama_model)"
  ollama_model_state="$(gateway_ollama_model_state)"
  ollama_runtime_state="$(gateway_ollama_runtime_state)"
  ollama_real_calls="$(gateway_ollama_real_calls_policy)"
  ollama_real_state="$(gateway_ollama_real_state)"

  secrets_state="$(gateway_secrets_state)"
  log_state="$(gateway_log_state)"
  log_lines="$(gateway_log_line_count)"
  last_log_event="$(gateway_last_log_event)"
  fallback_policy="$(gateway_fallback_policy)"
  fallback_status="$(gateway_fallback_status)"
  operator_hint="$(gateway_operator_hint)"

  printf 'KAO GATEWAY STATUS\n'
  printf 'root              : %s\n' "${KAO_GATEWAY_ROOT}"
  printf 'selected provider : %s\n' "${selected}"
  printf 'selected label    : %s\n' "${selected_label}"
  printf 'selected kind     : %s\n' "${selected_kind}"
  printf 'selected health   : %s\n' "${selected_health}"
  printf 'selected note     : %s\n' "${selected_note}"
  printf 'forced provider   : %s\n' "${forced_provider}"
  printf 'forced state      : %s\n' "${forced_state}"
  printf 'detected provider : %s\n' "${detected_provider}"
  printf 'mistral available : %s\n' "${mistral_available}"
  printf 'mistral health    : %s\n' "${mistral_health}"
  printf 'mistral note      : %s\n' "${mistral_note}"
  printf 'ollama available  : %s\n' "${ollama_available}"
  printf 'ollama kind       : %s\n' "${ollama_kind}"
  printf 'ollama health     : %s\n' "${ollama_health}"
  printf 'ollama note       : %s\n' "${ollama_note}"
  printf 'ollama model      : %s\n' "${ollama_model}"
  printf 'ollama model state: %s\n' "${ollama_model_state}"
  printf 'ollama runtime    : %s\n' "${ollama_runtime_state}"
  printf 'ollama real calls : %s\n' "${ollama_real_calls}"
  printf 'ollama real state : %s\n' "${ollama_real_state}"
  printf 'secrets file      : %s\n' "${KAO_GATEWAY_SECRETS_FILE}"
  printf 'secrets state     : %s\n' "${secrets_state}"
  printf 'log file          : %s\n' "${KAO_GATEWAY_LOG_FILE}"
  printf 'log state         : %s\n' "${log_state}"
  printf 'log lines         : %s\n' "${log_lines}"
  printf 'last log event    : %s\n' "${last_log_event}"
  printf 'fallback policy   : %s\n' "${fallback_policy}"
  printf 'fallback status   : %s\n' "${fallback_status}"
  printf 'diagnostic        : %s\n' "${operator_hint}"
  printf 'log preview       :\n'
  gateway_log_preview_print
}

gateway_print_health() {
  local selected forced_provider forced_state detected_provider
  local selected_kind selected_health
  local mistral_available mistral_health
  local ollama_available ollama_kind ollama_health
  local ollama_model ollama_model_state ollama_runtime_state
  local ollama_real_calls ollama_real_state
  local fallback_status operator_hint

  selected="$(gateway_provider_select)"
  forced_provider="$(gateway_forced_provider)"
  forced_state="$(gateway_forced_provider_state)"
  detected_provider="$(gateway_provider_detected)"

  selected_kind="$(gateway_provider_kind "${selected}")"
  selected_health="$(gateway_provider_health "${selected}")"

  mistral_available="$(gateway_provider_available mistral)"
  mistral_health="$(gateway_provider_health mistral)"

  ollama_available="$(gateway_provider_available ollama)"
  ollama_kind="$(gateway_ollama_kind)"
  ollama_health="$(gateway_provider_health ollama)"
  ollama_model="$(gateway_ollama_model)"
  ollama_model_state="$(gateway_ollama_model_state)"
  ollama_runtime_state="$(gateway_ollama_runtime_state)"
  ollama_real_calls="$(gateway_ollama_real_calls_policy)"
  ollama_real_state="$(gateway_ollama_real_state)"

  fallback_status="$(gateway_fallback_status)"
  operator_hint="$(gateway_operator_hint)"

  printf 'KAO GATEWAY HEALTH\n'
  printf 'selected provider : %s\n' "${selected}"
  printf 'selected kind     : %s\n' "${selected_kind}"
  printf 'selected health   : %s\n' "${selected_health}"
  printf 'forced provider   : %s\n' "${forced_provider}"
  printf 'forced state      : %s\n' "${forced_state}"
  printf 'detected provider : %s\n' "${detected_provider}"
  printf 'mistral available : %s\n' "${mistral_available}"
  printf 'mistral health    : %s\n' "${mistral_health}"
  printf 'ollama available  : %s\n' "${ollama_available}"
  printf 'ollama kind       : %s\n' "${ollama_kind}"
  printf 'ollama health     : %s\n' "${ollama_health}"
  printf 'ollama model      : %s\n' "${ollama_model}"
  printf 'ollama model state: %s\n' "${ollama_model_state}"
  printf 'ollama runtime    : %s\n' "${ollama_runtime_state}"
  printf 'ollama real calls : %s\n' "${ollama_real_calls}"
  printf 'ollama real state : %s\n' "${ollama_real_state}"
  printf 'fallback status   : %s\n' "${fallback_status}"
  printf 'diagnostic        : %s\n' "${operator_hint}"
}

gateway_print_logs() {
  printf 'KAO GATEWAY LOGS\n'
  printf 'log file          : %s\n' "${KAO_GATEWAY_LOG_FILE}"
  printf 'log state         : %s\n' "$(gateway_log_state)"
  printf 'log lines         : %s\n' "$(gateway_log_line_count)"
  printf 'last log event    : %s\n' "$(gateway_last_log_event)"
  printf 'preview           :\n'
  gateway_log_preview_print
}

gateway_help() {
  printf 'USAGE: kao gateway [status|health|logs]\n'
}

gateway_cli() {
  local subcommand
  subcommand="${1:-status}"

  case "${subcommand}" in
    ""|status)
      gateway_print_status
      ;;
    health)
      gateway_print_health
      ;;
    logs)
      gateway_print_logs
      ;;
    help|-h|--help)
      gateway_help
      ;;
    *)
      printf 'ERROR: unknown gateway subcommand: %s\n' "${subcommand}" >&2
      gateway_help >&2
      return 1
      ;;
  esac
}

gateway_infer() {
  local query provider response fallback_response
  local ollama_health ollama_real_state ollama_model ollama_model_state

  query="${1:-}"

  if [ -z "${query}" ]; then
    printf 'GATEWAY_ERROR missing query\n' >&2
    return 1
  fi

  gateway_require_providers
  gateway_load_secrets runtime >/dev/null 2>&1 || true

  provider="$(gateway_provider_select)"

  if [ "${provider}" = "none" ]; then
    gateway_log ERROR "no provider available"
    printf 'GATEWAY_ERROR no provider available\n' >&2
    return 1
  fi

  gateway_log INFO "provider selected: ${provider}"
  printf 'gateway -> %s\n' "$(gateway_provider_label "${provider}")"

  case "${provider}" in
    mistral)
      if response="$(gateway_provider_mistral_infer "${query}")"; then
        gateway_log INFO "mistral inference ok"
        printf '%s\n' "${response}"
        return 0
      fi

      gateway_log WARN "mistral inference failed, trying ollama fallback"
      printf 'gateway fallback -> %s\n' "$(gateway_provider_label "ollama")"

      ollama_health="$(gateway_provider_health ollama)"
      ollama_real_state="$(gateway_ollama_real_state)"
      ollama_model="$(gateway_ollama_model)"
      ollama_model_state="$(gateway_ollama_model_state)"

      gateway_log INFO "ollama fallback target model: ${ollama_model} (${ollama_model_state})"

      if [ "${ollama_health}" = "local-real-ready" ]; then
        gateway_log INFO "ollama real fallback attempt"
      fi

      if fallback_response="$(gateway_provider_ollama_infer "${query}")"; then
        case "${ollama_real_state}" in
          callable)
            gateway_log INFO "ollama real fallback response ok"
            ;;
          blocked-policy|blocked-no-model|stub-only)
            gateway_log INFO "ollama stub fallback response ok"
            ;;
          *)
            gateway_log INFO "ollama fallback response ok"
            ;;
        esac
        printf '%s\n' "${fallback_response}"
        return 0
      fi

      gateway_log ERROR "fallback inference failed"
      printf 'GATEWAY_ERROR fallback inference failed\n' >&2
      return 1
      ;;
    ollama)
      ollama_health="$(gateway_provider_health ollama)"
      ollama_real_state="$(gateway_ollama_real_state)"
      ollama_model="$(gateway_ollama_model)"
      ollama_model_state="$(gateway_ollama_model_state)"

      gateway_log INFO "ollama target model: ${ollama_model} (${ollama_model_state})"

      if [ "${ollama_health}" = "local-real-ready" ]; then
        gateway_log INFO "ollama real inference attempt"
      fi

      if response="$(gateway_provider_ollama_infer "${query}")"; then
        case "${ollama_real_state}" in
          callable)
            gateway_log INFO "ollama real inference ok"
            ;;
          blocked-policy|blocked-no-model|stub-only)
            gateway_log INFO "ollama stub inference ok"
            ;;
          *)
            if [ "${ollama_health}" = "local-real-ready" ]; then
              gateway_log INFO "ollama real inference ok"
            else
              gateway_log INFO "ollama inference ok"
            fi
            ;;
        esac
        printf '%s\n' "${response}"
        return 0
      fi

      gateway_log ERROR "ollama inference failed"
      printf 'GATEWAY_ERROR ollama inference failed\n' >&2
      return 1
      ;;
    *)
      gateway_log ERROR "unsupported provider selected: ${provider}"
      printf 'GATEWAY_ERROR unsupported provider selected\n' >&2
      return 1
      ;;
  esac
}

gateway_selected_route() {
  local provider
  provider="$(gateway_provider_select)"

  case "${provider}" in
    mistral)
      printf 'cloud\n'
      ;;
    ollama)
      printf 'local\n'
      ;;
    *)
      printf 'none\n'
      ;;
  esac
}

gateway_cloud_readiness() {
  printf '%s\n' "$(gateway_provider_health mistral)"
}

gateway_local_readiness() {
  printf '%s\n' "$(gateway_provider_health ollama)"
}

gateway_hybrid_state() {
  local cloud_health local_health cloud_ready local_ready
  cloud_health="$(gateway_cloud_readiness)"
  local_health="$(gateway_local_readiness)"
  cloud_ready=0
  local_ready=0

  if [ "${cloud_health}" = "ready" ]; then
    cloud_ready=1
  fi

  case "${local_health}" in
    local-stub-ready|local-real-backend-ready|local-real-ready)
      local_ready=1
      ;;
  esac

  if [ "${cloud_ready}" = "1" ] && [ "${local_ready}" = "1" ]; then
    printf 'hybrid-ready\n'
    return 0
  fi

  if [ "${cloud_ready}" = "1" ]; then
    printf 'cloud-only\n'
    return 0
  fi

  if [ "${local_ready}" = "1" ]; then
    printf 'local-only\n'
    return 0
  fi

  printf 'unavailable\n'
}

gateway_operator_mode() {
  case "$(gateway_hybrid_state)" in
    hybrid-ready)
      printf 'hybrid-ready\n'
      ;;
    cloud-only)
      printf 'online\n'
      ;;
    local-only)
      printf 'offline\n'
      ;;
    *)
      printf 'degraded\n'
      ;;
  esac
}
