#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

"${ROOT_DIR}/tests/unit/test_kao_entrypoint.sh"
"${ROOT_DIR}/tests/unit/test_mission_gate.sh"

bash "${ROOT_DIR}/tests/unit/test_session_manager_contract.sh"
