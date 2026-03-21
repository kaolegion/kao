#!/usr/bin/env bash
set -euo pipefail

KROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "${KROOT}/lib/router/router_core_contract.sh"

echo "[TEST] router-core self"
router_core_contract_build "qui es tu"
test "${ROUTER_CORE_DECISION}" = "self"

echo "[TEST] router-core local"
router_core_contract_build "ouvre ce fichier"
test "${ROUTER_CORE_DECISION}" = "local-agent"

echo "[TEST] router-core llm"
router_core_contract_build "analyse cette architecture"
test "${ROUTER_CORE_DECISION}" = "gateway-llm"

echo "router-core contract OK"
