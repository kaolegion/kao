#!/usr/bin/env bash
set -euo pipefail

KROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RAY_BIN="${KROOT}/bin/ray"
SESSION_CURRENT="${KROOT}/state/runtime/session.current"
SESSION_HISTORY="${KROOT}/state/runtime/session.history"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

OPEN_OUT="${TMP_DIR}/ray_session_open.out"
STATUS_OUT="${TMP_DIR}/ray_session_status.out"
ASK_OUT="${TMP_DIR}/ray_session_ask.out"
CLOSE_OUT="${TMP_DIR}/ray_session_close.out"
HISTORY_OUT="${TMP_DIR}/ray_session_history.out"

rm -f "${SESSION_CURRENT}" "${SESSION_HISTORY}"

"${RAY_BIN}" session open > "${OPEN_OUT}"

grep -q 'RAY SESSION' "${OPEN_OUT}"
grep -q 'state    : ACTIVE' "${OPEN_OUT}"
grep -q '^SESSION_STATE=ACTIVE$' "${SESSION_CURRENT}"

"${RAY_BIN}" session > "${STATUS_OUT}"
grep -q 'RAY SESSION' "${STATUS_OUT}"
grep -q 'gateway  :' "${STATUS_OUT}"
grep -q 'internet :' "${STATUS_OUT}"

"${RAY_BIN}" ask "Open the notes folder" > "${ASK_OUT}"
grep -q 'RAY ASK' "${ASK_OUT}"
grep -q 'INTENT' "${ASK_OUT}"
grep -q '^SESSION_AGENTS=' "${SESSION_CURRENT}"
grep -q 'intent-router' "${SESSION_CURRENT}"

"${RAY_BIN}" session close > "${CLOSE_OUT}"
grep -q 'RAY SESSION CLOSED' "${CLOSE_OUT}"
grep -q 'duration :' "${CLOSE_OUT}"
test ! -f "${SESSION_CURRENT}"

"${RAY_BIN}" session history > "${HISTORY_OUT}"
grep -q 'RAY SESSION HISTORY' "${HISTORY_OUT}"
grep -q 'SESSION_CLOSED|' "${HISTORY_OUT}"

printf 'OK ray_session scenario\n'
