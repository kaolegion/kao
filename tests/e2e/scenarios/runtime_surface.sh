#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RAW_LOG="${ROOT_DIR}/state/runtime/events.raw.log"
SIGNALS_LOG="${ROOT_DIR}/state/sense/signals.log"

rm -f "${RAW_LOG}" "${SIGNALS_LOG}"

KAO_CAPTURE_SYNC=1 "${ROOT_DIR}/lib/runtime/live_capture.sh" capture COMMAND_RUN "kao status"
KAO_CAPTURE_SYNC=1 "${ROOT_DIR}/lib/runtime/live_capture.sh" capture SESSION_OPEN "session-e2e"
KAO_CAPTURE_SYNC=1 "${ROOT_DIR}/lib/runtime/live_capture.sh" capture UNKNOWN_EVENT "payload-e2e"

test -f "${RAW_LOG}"
test -f "${SIGNALS_LOG}"

grep -q 'COMMAND_RUN|kao status' "${RAW_LOG}"
grep -q 'SESSION_OPEN|session-e2e' "${RAW_LOG}"
grep -q 'operator|command|run|kao status' "${SIGNALS_LOG}"
grep -q 'runtime|session|open|session-e2e' "${SIGNALS_LOG}"
grep -q 'system|unknown|unknown|payload-e2e' "${SIGNALS_LOG}"

printf 'OK: runtime_surface deterministic normalizer\n'
