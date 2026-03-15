#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"

source "${KROOT}/lib/runtime/runtime_mutation.sh"

kao_runtime_state_file() {
  printf '%s/state/runtime/runtime.state\n' "${KROOT}"
}

kao_runtime_state_set() {

  local key="$1"
  local value="$2"

  [ -n "${key}" ] || return 1

  TXID="$(kao_runtime_mutation_begin)" || return 1

  mkdir -p "${KROOT}/state/runtime"

  if [ ! -f "$(kao_runtime_state_file)" ]; then
    touch "$(kao_runtime_state_file)"
  fi

  if grep -q "^${key}=" "$(kao_runtime_state_file)"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$(kao_runtime_state_file)"
  else
    echo "${key}=${value}" >> "$(kao_runtime_state_file)"
  fi

  kao_runtime_mutation_commit "${TXID}"
}

kao_runtime_set_phase() {
  local phase="$1"

  case "${phase}" in
    BOOT|IDLE|ACTIVE_SESSION|COMMITTING|STOPPING)
      ;;
    *)
      echo "ERROR: invalid runtime phase ${phase}" >&2
      return 1
      ;;
  esac

  kao_runtime_state_set KAO_RUNTIME_PHASE "${phase}"
}


kao_router_decide_gateway() {

  local net local_llm cloud

  net="$(grep '^KAO_CONNECTIVITY_NETWORK=' "$(kao_runtime_state_file)" | cut -d= -f2)"
  local_llm="$(grep '^KAO_LOCAL_LLM=' "$(kao_runtime_state_file)" | cut -d= -f2)"
  cloud="$(grep '^KAO_CLOUD_ACCESS=' "$(kao_runtime_state_file)" | cut -d= -f2)"

  case "${net}" in
    offline)
      if [ "${local_llm}" = "present" ]; then
        echo "local|network_offline"
      else
        echo "none|no_route"
      fi
      return
      ;;
    online|degraded)
      if [ "${cloud}" = "available" ]; then
        echo "cloud|cloud_preferred"
      elif [ "${local_llm}" = "present" ]; then
        echo "local|fallback_local"
      else
        echo "none|no_route"
      fi
      return
      ;;
    *)
      echo "none|boot"
      ;;
  esac
}


kao_router_apply_gateway_decision() {

  local decision gateway reason

  decision="$(kao_router_decide_gateway)"
  gateway="$(echo "${decision}" | cut -d'|' -f1)"
  reason="$(echo "${decision}" | cut -d'|' -f2)"

  kao_runtime_state_set KAO_ROUTER_GATEWAY "${gateway}"
  kao_runtime_state_set KAO_ROUTER_REASON "${reason}"
}

