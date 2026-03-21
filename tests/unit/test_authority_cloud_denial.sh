#!/usr/bin/env bash
set -e

export KAO_GATEWAY_ROOT="/home/kao"
export KAO_ALLOW_CLOUD=0

source /home/kao/lib/gateway/router.sh

# prevent provider reload overriding mocks
gateway_require_providers(){ :; }

gateway_provider_ollama_available(){ return 1; }
gateway_provider_mistral_available(){ return 0; }

result="$(gateway_provider_select)"

if [ "$result" = "none" ]; then
  echo "[PASS] cloud denial correct"
else
  echo "[FAIL] cloud denial incorrect"
  exit 1
fi
