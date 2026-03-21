#!/usr/bin/env bash
set -euo pipefail

KROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
. "${KROOT}/lib/runtime/session_manager.sh"

if ! declare -F kao_session_emit >/dev/null 2>&1; then
  echo "[FAIL] session manager exposes kao_session_emit"
  exit 1
fi

if ! declare -F kao_event_enrich_detail >/dev/null 2>&1; then
  echo "[FAIL] session manager loads event normalizer contract"
  exit 1
fi

echo "[PASS] session manager exposes kao_session_emit"
echo "[PASS] session manager loads event normalizer contract"
