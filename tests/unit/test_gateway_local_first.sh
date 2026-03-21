#!/usr/bin/env bash
set -e

export KAO_GATEWAY_ROOT="/home/kao"

source /home/kao/lib/gateway/router.sh

gateway_provider_ollama_available(){ return 0; }
gateway_provider_mistral_available(){ return 0; }

out="$(gateway_provider_select)"

if [ "$out" = "ollama" ]; then
  echo "[PASS] local-first provider selection"
else
  echo "[FAIL] local-first provider selection"
  exit 1
fi
