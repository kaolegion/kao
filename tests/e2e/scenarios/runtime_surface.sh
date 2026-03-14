#!/usr/bin/env bash
scenario_runtime_surface() {

RUNTIME_USER_ENV="/home/kao/config/user.env"
RUNTIME_USER_STATE="/home/kao/config/user.state"
RUNTIME_STATE_DIR="/home/kao/state/runtime"
RUNTIME_SNAPSHOT_FILE="${RUNTIME_STATE_DIR}/runtime.snapshot"
RUNTIME_STATUS_FILE="${RUNTIME_STATE_DIR}/runtime.state"
RUNTIME_LOG_FILE="/home/kao/state/logs/runtime.log"
RUNTIME_TX_DIR="${RUNTIME_STATE_DIR}/.tx"
RUNTIME_LOCK_DIR="${RUNTIME_STATE_DIR}/.lock"
RUNTIME_JOURNAL_FILE="${RUNTIME_STATE_DIR}/runtime.journal"
SESSION_DIR="/home/kao/state/sessions"

USER_ENV_BACKUP="/tmp/kao-runtime-surface.user.env.$$"
USER_STATE_BACKUP="/tmp/kao-runtime-surface.user.state.$$"
RUNTIME_STATE_BACKUP="/tmp/kao-runtime-surface.runtime.state.$$"
STAGE_SOURCE_FILE="/tmp/kao-runtime-stage-source.$$"

cleanup_runtime_surface() {
  if [ -f "${USER_ENV_BACKUP}" ]; then
    cp "${USER_ENV_BACKUP}" "${RUNTIME_USER_ENV}"
    rm -f "${USER_ENV_BACKUP}"
  else
    rm -f "${RUNTIME_USER_ENV}"
  fi

  if [ -f "${USER_STATE_BACKUP}" ]; then
    cp "${USER_STATE_BACKUP}" "${RUNTIME_USER_STATE}"
    rm -f "${USER_STATE_BACKUP}"
  else
    rm -f "${RUNTIME_USER_STATE}"
  fi

  if [ -f "${RUNTIME_STATE_BACKUP}" ]; then
    cp "${RUNTIME_STATE_BACKUP}" "${RUNTIME_STATUS_FILE}"
    rm -f "${RUNTIME_STATE_BACKUP}"
  fi

  rm -f \
    "${STAGE_SOURCE_FILE}" \
    /tmp/kao-runtime-status-before.$$.out \
    /tmp/kao-runtime-activate.$$.out \
    /tmp/kao-runtime-snapshot.$$.out \
    /tmp/kao-runtime-diff.$$.out \
    /tmp/kao-runtime-deactivate.$$.out \
    /tmp/kao-runtime-snapshot-create.$$.out \
    /tmp/kao-runtime-transaction-begin.$$.out \
    /tmp/kao-runtime-transaction-commit.$$.out \
    /tmp/kao-runtime-transaction-stage.$$.out \
    /tmp/kao-runtime-transaction-stage-begin.$$.out \
    /tmp/kao-runtime-transaction-stage-commit.$$.out \
    /tmp/kao-runtime-transaction-recovery-begin.$$.out \
    /tmp/kao-runtime-transaction-recovery-status.$$.out

  rm -rf "${RUNTIME_LOCK_DIR}"
}
trap cleanup_runtime_surface RETURN

if [ -f "${RUNTIME_USER_ENV}" ]; then
  cp "${RUNTIME_USER_ENV}" "${USER_ENV_BACKUP}"
fi

if [ -f "${RUNTIME_USER_STATE}" ]; then
  cp "${RUNTIME_USER_STATE}" "${USER_STATE_BACKUP}"
fi

if [ -f "${RUNTIME_STATUS_FILE}" ]; then
  cp "${RUNTIME_STATUS_FILE}" "${RUNTIME_STATE_BACKUP}"
fi

mkdir -p "${RUNTIME_STATE_DIR}" /home/kao/state/logs "${SESSION_DIR}"

cat > "${RUNTIME_USER_ENV}" <<'EOF_USER_ENV'
# canonical runtime user source
KAO_USER_NAME="runtime user"
KAO_USER_ROLE="operator user"
KAO_USER_ID="user-runtime-user"
KAO_USER_TITLE="not set"
KAO_USER_HANDLE="not set"
KAO_USER_ORG="not set"
EOF_USER_ENV

if /home/kao/bin/kao runtime status >/tmp/kao-runtime-status-before.$$.out 2>&1; then
  e2e_ok "runtime status before activate ok"
else
  e2e_error "runtime status before activate failed"
fi

if grep -q 'RUNTIME ACTIVE ACTOR : owner' /tmp/kao-runtime-status-before.$$.out; then
  e2e_ok "runtime starts on owner baseline"
else
  e2e_error "runtime did not start on owner baseline"
fi

if /home/kao/bin/kao runtime activate user >/tmp/kao-runtime-activate.$$.out 2>&1; then
  e2e_ok "runtime activate user ok"
else
  e2e_error "runtime activate user failed"
fi

if grep -q 'RUNTIME ACTIVE ACTOR : user' /tmp/kao-runtime-activate.$$.out; then
  e2e_ok "runtime activate switched actor to user"
else
  e2e_error "runtime activate did not switch actor to user"
fi

if [ -f "${RUNTIME_USER_STATE}" ] && grep -q '^KAO_USER_ACTIVE=1$' "${RUNTIME_USER_STATE}"; then
  e2e_ok "runtime user state flag written"
else
  e2e_error "runtime user state flag missing"
fi

if /home/kao/bin/kao runtime snapshot >/tmp/kao-runtime-snapshot.$$.out 2>&1; then
  e2e_ok "runtime snapshot ok"
else
  e2e_error "runtime snapshot failed"
fi

if [ -f "${RUNTIME_SNAPSHOT_FILE}" ]; then
  e2e_ok "runtime snapshot file present"
else
  e2e_error "runtime snapshot file missing"
fi

if /home/kao/bin/kao runtime diff >/tmp/kao-runtime-diff.$$.out 2>&1; then
  e2e_ok "runtime diff ok"
else
  e2e_warn "runtime diff returned non-zero"
fi

if /home/kao/bin/kao snapshot create >/tmp/kao-runtime-snapshot-create.$$.out 2>&1; then
  e2e_ok "reliability snapshot create ok"
else
  e2e_error "reliability snapshot create failed"
fi

LATEST_RUNTIME_SNAPSHOT="$(awk -F': ' '/SNAPSHOT CREATED/ {print $2}' /tmp/kao-runtime-snapshot-create.$$.out | tail -n 1)"
if [ -n "${LATEST_RUNTIME_SNAPSHOT}" ] && [ -d "${SESSION_DIR}/${LATEST_RUNTIME_SNAPSHOT}" ]; then
  e2e_ok "reliability snapshot directory created"
else
  e2e_error "reliability snapshot directory missing"
fi

if [ -f "${SESSION_DIR}/${LATEST_RUNTIME_SNAPSHOT}/manifest.env" ]; then
  e2e_ok "reliability snapshot manifest present"
else
  e2e_error "reliability snapshot manifest missing"
fi

if /home/kao/bin/kao transaction begin >/tmp/kao-runtime-transaction-begin.$$.out 2>&1; then
  e2e_ok "runtime transaction begin ok"
else
  e2e_error "runtime transaction begin failed"
fi

TXID="$(tail -n 1 /tmp/kao-runtime-transaction-begin.$$.out)"
TX_ENV_FILE="${RUNTIME_TX_DIR}/${TXID}/transaction.env"

if [ -n "${TXID}" ] && [ -f "${TX_ENV_FILE}" ]; then
  e2e_ok "runtime transaction env created"
else
  e2e_error "runtime transaction env missing"
fi

if [ -d "${RUNTIME_LOCK_DIR}" ] && [ -f "${RUNTIME_LOCK_DIR}/pid" ]; then
  e2e_ok "runtime transaction lock acquired"
else
  e2e_error "runtime transaction lock missing"
fi

if [ -f "${RUNTIME_JOURNAL_FILE}" ] && grep -q "tx=${TXID}|action=begin" "${RUNTIME_JOURNAL_FILE}"; then
  e2e_ok "runtime transaction begin journaled"
else
  e2e_error "runtime transaction begin not journaled"
fi

if /home/kao/bin/kao transaction commit "${TXID}" >/tmp/kao-runtime-transaction-commit.$$.out 2>&1; then
  e2e_ok "runtime transaction commit ok"
else
  e2e_error "runtime transaction commit failed"
fi

if [ ! -d "${RUNTIME_LOCK_DIR}" ]; then
  e2e_ok "runtime transaction lock released"
else
  e2e_error "runtime transaction lock still present"
fi

if [ -f "${TX_ENV_FILE}" ] && grep -q '^STATE=committed$' "${TX_ENV_FILE}"; then
  e2e_ok "runtime transaction committed state written"
else
  e2e_error "runtime transaction committed state missing"
fi

if [ -f "${RUNTIME_JOURNAL_FILE}" ] && grep -q "tx=${TXID}|action=commit" "${RUNTIME_JOURNAL_FILE}"; then
  e2e_ok "runtime transaction commit journaled"
else
  e2e_error "runtime transaction commit not journaled"
fi

cat > "${STAGE_SOURCE_FILE}" <<'EOF_STAGE_APPLY'
KAO_RUNTIME_ACTIVE_ACTOR=staged-apply
KAO_RUNTIME_APPLY_TEST=1
EOF_STAGE_APPLY

if /home/kao/bin/kao transaction begin >/tmp/kao-runtime-transaction-stage-begin.$$.out 2>&1; then
  e2e_ok "runtime transaction stage begin ok"
else
  e2e_error "runtime transaction stage begin failed"
fi

TX_STAGE_ID="$(tail -n 1 /tmp/kao-runtime-transaction-stage-begin.$$.out)"
TX_STAGE_ENV_FILE="${RUNTIME_TX_DIR}/${TX_STAGE_ID}/transaction.env"
TX_STAGE_FILE="${RUNTIME_TX_DIR}/${TX_STAGE_ID}/stage/runtime.state"
TX_STAGE_WAL_FILE="${RUNTIME_TX_DIR}/${TX_STAGE_ID}/wal/runtime.wal"
TX_STAGE_MANIFEST_FILE="${RUNTIME_TX_DIR}/${TX_STAGE_ID}/resources.manifest"

if /home/kao/bin/kao transaction stage "${TX_STAGE_ID}" "${RUNTIME_STATUS_FILE}" "${STAGE_SOURCE_FILE}" >/tmp/kao-runtime-transaction-stage.$$.out 2>&1; then
  e2e_ok "runtime transaction stage command ok"
else
  e2e_error "runtime transaction stage command failed"
fi

if [ -f "${TX_STAGE_FILE}" ] && grep -q '^KAO_RUNTIME_ACTIVE_ACTOR=staged-apply$' "${TX_STAGE_FILE}"; then
  e2e_ok "runtime transaction stage file written"
else
  e2e_error "runtime transaction stage file missing"
fi

if [ -f "${TX_STAGE_WAL_FILE}" ]; then
  e2e_ok "runtime transaction wal file written"
else
  e2e_error "runtime transaction wal file missing"
fi

if [ -f "${TX_STAGE_WAL_FILE}" ] && grep -q '^WAL_STAGE|tx='"${TX_STAGE_ID}"'|target=runtime.state|' "${TX_STAGE_WAL_FILE}"; then
  e2e_ok "runtime transaction wal stage entry written"
else
  e2e_error "runtime transaction wal stage entry missing"
fi

if [ -f "${TX_STAGE_MANIFEST_FILE}" ] && grep -q '^runtime.state$' "${TX_STAGE_MANIFEST_FILE}"; then
  e2e_ok "runtime transaction manifest written"
else
  e2e_error "runtime transaction manifest missing runtime.state"
fi

if [ -f "${TX_STAGE_ENV_FILE}" ] && grep -q '^BARRIER_STATE=staged$' "${TX_STAGE_ENV_FILE}"; then
  e2e_ok "runtime transaction barrier state staged"
else
  e2e_error "runtime transaction barrier state not staged"
fi

if [ -f "${TX_STAGE_ENV_FILE}" ] && grep -q '^RESOURCE_COUNT=1$' "${TX_STAGE_ENV_FILE}"; then
  e2e_ok "runtime transaction resource count updated"
else
  e2e_error "runtime transaction resource count incorrect"
fi

if [ -f "${RUNTIME_JOURNAL_FILE}" ] && grep -q "tx=${TX_STAGE_ID}|action=stage|detail=runtime.state" "${RUNTIME_JOURNAL_FILE}"; then
  e2e_ok "runtime transaction stage journaled"
else
  e2e_error "runtime transaction stage not journaled"
fi

if /home/kao/bin/kao transaction commit "${TX_STAGE_ID}" >/tmp/kao-runtime-transaction-stage-commit.$$.out 2>&1; then
  e2e_ok "runtime transaction staged commit ok"
else
  e2e_error "runtime transaction staged commit failed"
fi

if [ -f "${RUNTIME_STATUS_FILE}" ] && grep -q '^KAO_RUNTIME_ACTIVE_ACTOR=staged-apply$' "${RUNTIME_STATUS_FILE}" && grep -q '^KAO_RUNTIME_APPLY_TEST=1$' "${RUNTIME_STATUS_FILE}"; then
  e2e_ok "runtime transaction staged apply reached runtime state"
else
  e2e_error "runtime transaction staged apply missing from runtime state"
fi

if [ -f "${TX_STAGE_ENV_FILE}" ] && grep -q '^STATE=committed$' "${TX_STAGE_ENV_FILE}" && grep -q '^BARRIER_STATE=applied$' "${TX_STAGE_ENV_FILE}"; then
  e2e_ok "runtime transaction staged commit state applied"
else
  e2e_error "runtime transaction staged commit state missing applied barrier"
fi

if [ -f "${RUNTIME_JOURNAL_FILE}" ] && grep -q "tx=${TX_STAGE_ID}|action=apply|detail=runtime.state" "${RUNTIME_JOURNAL_FILE}"; then
  e2e_ok "runtime transaction apply journaled"
else
  e2e_error "runtime transaction apply not journaled"
fi

cat > "${RUNTIME_STATUS_FILE}" <<'EOF_RUNTIME_BASELINE'
KAO_RUNTIME_ACTIVE_ACTOR=owner
EOF_RUNTIME_BASELINE

cat > "${STAGE_SOURCE_FILE}" <<'EOF_STAGE_RECOVERY'
KAO_RUNTIME_ACTIVE_ACTOR=crash-staged
KAO_RUNTIME_RECOVERY_TEST=1
EOF_STAGE_RECOVERY

if /home/kao/bin/kao transaction begin >/tmp/kao-runtime-transaction-recovery-begin.$$.out 2>&1; then
  e2e_ok "runtime recovery transaction begin ok"
else
  e2e_error "runtime recovery transaction begin failed"
fi

TX_RECOVERY_ID="$(tail -n 1 /tmp/kao-runtime-transaction-recovery-begin.$$.out)"
TX_RECOVERY_ENV_FILE="${RUNTIME_TX_DIR}/${TX_RECOVERY_ID}/transaction.env"
TX_RECOVERY_STAGE_FILE="${RUNTIME_TX_DIR}/${TX_RECOVERY_ID}/stage/runtime.state"
TX_RECOVERY_WAL_FILE="${RUNTIME_TX_DIR}/${TX_RECOVERY_ID}/wal/runtime.wal"

if /home/kao/bin/kao transaction stage "${TX_RECOVERY_ID}" "${RUNTIME_STATUS_FILE}" "${STAGE_SOURCE_FILE}" >/tmp/kao-runtime-transaction-stage.$$.out 2>&1; then
  e2e_ok "runtime recovery stage command ok"
else
  e2e_error "runtime recovery stage command failed"
fi

if [ -f "${TX_RECOVERY_STAGE_FILE}" ] && grep -q '^KAO_RUNTIME_ACTIVE_ACTOR=crash-staged$' "${TX_RECOVERY_STAGE_FILE}"; then
  e2e_ok "runtime recovery stage file written"
else
  e2e_error "runtime recovery stage file missing"
fi

if [ -f "${TX_RECOVERY_WAL_FILE}" ] && grep -q '^WAL_STAGE|tx='"${TX_RECOVERY_ID}"'|target=runtime.state|' "${TX_RECOVERY_WAL_FILE}"; then
  e2e_ok "runtime recovery wal entry written"
else
  e2e_error "runtime recovery wal entry missing"
fi

if [ -f "${TX_RECOVERY_ENV_FILE}" ] && grep -q '^STATE=open$' "${TX_RECOVERY_ENV_FILE}" && grep -q '^BARRIER_STATE=staged$' "${TX_RECOVERY_ENV_FILE}"; then
  e2e_ok "runtime recovery state barrier prepared"
else
  e2e_error "runtime recovery state barrier not prepared"
fi

if [ -d "${RUNTIME_LOCK_DIR}" ]; then
  printf '999999\n' > "${RUNTIME_LOCK_DIR}/pid"
  e2e_ok "runtime recovery orphan lock simulated"
else
  e2e_error "runtime recovery lock missing before orphan simulation"
fi

if /home/kao/bin/kao transaction status >/tmp/kao-runtime-transaction-recovery-status.$$.out 2>&1; then
  e2e_ok "runtime recovery boot path command ok"
else
  e2e_error "runtime recovery boot path command failed"
fi

if grep -q 'RUNTIME RECOVERY : applied' /tmp/kao-runtime-transaction-recovery-status.$$.out; then
  e2e_ok "runtime recovery applied on boot path"
else
  e2e_error "runtime recovery did not apply on boot path"
fi

if [ ! -d "${RUNTIME_LOCK_DIR}" ]; then
  e2e_ok "runtime recovery orphan lock cleared"
else
  e2e_error "runtime recovery orphan lock still present"
fi

if [ -f "${TX_RECOVERY_ENV_FILE}" ] && grep -q '^STATE=aborted$' "${TX_RECOVERY_ENV_FILE}" && grep -q '^BARRIER_STATE=reverted$' "${TX_RECOVERY_ENV_FILE}"; then
  e2e_ok "runtime recovery transaction marked aborted with reverted barrier"
else
  e2e_error "runtime recovery transaction not marked aborted with reverted barrier"
fi

if [ -f "${RUNTIME_STATUS_FILE}" ] && grep -q '^KAO_RUNTIME_ACTIVE_ACTOR=owner$' "${RUNTIME_STATUS_FILE}" && ! grep -q '^KAO_RUNTIME_RECOVERY_TEST=1$' "${RUNTIME_STATUS_FILE}"; then
  e2e_ok "runtime recovery restored pre-crash runtime state"
else
  e2e_error "runtime recovery did not restore pre-crash runtime state"
fi

if [ -f "${RUNTIME_JOURNAL_FILE}" ] && grep -q "tx=${TX_RECOVERY_ID}|action=recovery.rollback" "${RUNTIME_JOURNAL_FILE}"; then
  e2e_ok "runtime recovery rollback journaled with state-aware flow"
else
  e2e_error "runtime recovery rollback not journaled with state-aware flow"
fi
}
