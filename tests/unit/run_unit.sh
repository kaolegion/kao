#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "[UNIT] entrypoint"
"${ROOT_DIR}/tests/unit/test_kao_entrypoint.sh"

echo "[UNIT] mission gate"
"${ROOT_DIR}/tests/unit/test_mission_gate.sh"

echo "[UNIT] router-core contract"
"${ROOT_DIR}/tests/unit/test_router_core_contract.sh"

echo "[UNIT] session manager"
bash "${ROOT_DIR}/tests/unit/test_session_manager_contract.sh"

echo "[UNIT] all tests OK"
