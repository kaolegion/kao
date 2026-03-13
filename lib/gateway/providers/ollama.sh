#!/usr/bin/env bash

gateway_provider_ollama_stub_enabled() {
  case "${KAO_GATEWAY_OLLAMA_STUB_ENABLED:-1}" in
    1|true|TRUE|yes|YES|on|ON)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

gateway_provider_ollama_binary_available() {
  command -v ollama >/dev/null 2>&1
}

gateway_provider_ollama_service_ready() {
  if ! gateway_provider_ollama_binary_available; then
    return 1
  fi

  ollama list >/dev/null 2>&1
}

gateway_provider_ollama_model() {
  printf '%s\n' "${OLLAMA_MODEL:-llama3.2}"
}

gateway_provider_ollama_model_list_raw() {
  if ! gateway_provider_ollama_service_ready; then
    return 1
  fi

  ollama list 2>/dev/null
}

gateway_provider_ollama_model_available() {
  local target
  target="$(gateway_provider_ollama_model)"

  if ! gateway_provider_ollama_service_ready; then
    return 1
  fi

  gateway_provider_ollama_model_list_raw | awk 'NR>1 {print $1}' | grep -Fxq "${target}"
}

gateway_provider_ollama_model_state() {
  if ! gateway_provider_ollama_service_ready; then
    printf 'unknown\n'
    return 0
  fi

  if gateway_provider_ollama_model_available; then
    printf 'ready\n'
    return 0
  fi

  printf 'missing\n'
}

gateway_provider_ollama_runtime_state() {
  if gateway_provider_ollama_service_ready; then
    case "$(gateway_provider_ollama_model_state)" in
      ready)
        printf 'real-model-ready\n'
        ;;
      missing)
        printf 'real-backend-ready\n'
        ;;
      *)
        printf 'real-backend-ready\n'
        ;;
    esac
    return 0
  fi

  if gateway_provider_ollama_stub_enabled; then
    printf 'stub-runtime\n'
    return 0
  fi

  printf 'unavailable\n'
}

gateway_provider_ollama_health() {
  case "$(gateway_provider_ollama_runtime_state)" in
    real-model-ready)
      printf 'local-real-ready\n'
      ;;
    real-backend-ready)
      printf 'local-real-backend-ready\n'
      ;;
    stub-runtime)
      printf 'local-stub-ready\n'
      ;;
    *)
      printf 'unavailable\n'
      ;;
  esac
}

gateway_provider_ollama_kind() {
  case "$(gateway_provider_ollama_health)" in
    local-real-ready|local-real-backend-ready)
      printf 'local-real\n'
      ;;
    local-stub-ready)
      printf 'local-stub\n'
      ;;
    *)
      printf 'local\n'
      ;;
  esac
}

gateway_provider_ollama_note() {
  case "$(gateway_provider_ollama_health)" in
    local-real-ready)
      printf 'local ollama backend reachable -> target model ready for real execution\n'
      ;;
    local-real-backend-ready)
      printf 'local ollama backend reachable -> target model missing\n'
      ;;
    local-stub-ready)
      printf 'local provider declared available but still stubbed\n'
      ;;
    *)
      printf 'local provider unavailable\n'
      ;;
  esac
}

gateway_provider_ollama_available() {
  case "$(gateway_provider_ollama_health)" in
    local-real-ready|local-real-backend-ready|local-stub-ready)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

gateway_provider_ollama_real_calls_enabled() {
  case "${KAO_GATEWAY_OLLAMA_REAL_CALLS:-0}" in
    1|true|TRUE|yes|YES|on|ON)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

gateway_provider_ollama_real_execution_state() {
  local health
  health="$(gateway_provider_ollama_health)"

  case "${health}" in
    local-real-ready)
      if gateway_provider_ollama_real_calls_enabled; then
        printf 'callable\n'
      else
        printf 'blocked-policy\n'
      fi
      ;;
    local-real-backend-ready)
      printf 'blocked-no-model\n'
      ;;
    local-stub-ready)
      printf 'stub-only\n'
      ;;
    *)
      printf 'unavailable\n'
      ;;
  esac
}

gateway_provider_ollama_real_infer() {
  local query model
  query="${1:-}"
  model="$(gateway_provider_ollama_model)"

  if [ -z "${query}" ]; then
    printf 'OLLAMA_ERROR missing query\n' >&2
    return 1
  fi

  if ! gateway_provider_ollama_service_ready; then
    printf 'OLLAMA_ERROR local runtime unavailable\n' >&2
    return 1
  fi

  if ! gateway_provider_ollama_model_available; then
    printf 'OLLAMA_ERROR local model unavailable: %s\n' "${model}" >&2
    return 1
  fi

  ollama run "${model}" "${query}"
}

gateway_provider_ollama_infer() {
  local query health model model_state
  query="${1:-}"

  if [ -z "${query}" ]; then
    printf 'OLLAMA_ERROR missing query\n' >&2
    return 1
  fi

  health="$(gateway_provider_ollama_health)"
  model="$(gateway_provider_ollama_model)"
  model_state="$(gateway_provider_ollama_model_state)"

  case "${health}" in
    unavailable)
      printf 'OLLAMA_ERROR local provider unavailable\n' >&2
      return 1
      ;;
    local-real-ready)
      if gateway_provider_ollama_real_calls_enabled; then
        gateway_provider_ollama_real_infer "${query}"
        return $?
      fi

      printf '[ollama-stub] local backend reachable but real calls disabled\n'
      printf 'model: %s\n' "${model}"
      printf 'model state: %s\n' "${model_state}"
      printf 'query: %s\n' "${query}"
      return 0
      ;;
    local-real-backend-ready)
      printf '[ollama-stub] local backend reachable but target model unavailable\n'
      printf 'model: %s\n' "${model}"
      printf 'model state: %s\n' "${model_state}"
      printf 'query: %s\n' "${query}"
      return 0
      ;;
    local-stub-ready)
      printf '[ollama-stub] local provider not configured yet\n'
      printf 'model: %s\n' "${model}"
      printf 'model state: %s\n' "${model_state}"
      printf 'query: %s\n' "${query}"
      return 0
      ;;
    *)
      printf 'OLLAMA_ERROR unknown local provider state\n' >&2
      return 1
      ;;
  esac
}
