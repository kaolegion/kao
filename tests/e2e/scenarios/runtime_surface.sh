#!/usr/bin/env bash
scenario_runtime_surface() {

RUNTIME_USER_ENV="/home/kao/config/user.env"
RUNTIME_USER_STATE="/home/kao/config/user.state"
RUNTIME_STATE_DIR="/home/kao/state/runtime"
RUNTIME_SNAPSHOT_FILE="${RUNTIME_STATE_DIR}/runtime.snapshot"
RUNTIME_STATUS_FILE="${RUNTIME_STATE_DIR}/runtime.state"
RUNTIME_LOG_FILE="/home/kao/state/logs/runtime.log"

USER_ENV_BACKUP="/tmp/kao-runtime-surface.user.env.$$"
USER_STATE_BACKUP="/tmp/kao-runtime-surface.user.state.$$"

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
}
trap cleanup_runtime_surface RETURN

if [ -f "${RUNTIME_USER_ENV}" ]; then
  cp "${RUNTIME_USER_ENV}" "${USER_ENV_BACKUP}"
fi

if [ -f "${RUNTIME_USER_STATE}" ]; then
  cp "${RUNTIME_USER_STATE}" "${USER_STATE_BACKUP}"
fi

mkdir -p "${RUNTIME_STATE_DIR}" /home/kao/state/logs

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

if /home/kao/bin/kao runtime deactivate >/tmp/kao-runtime-deactivate.$$.out 2>&1; then
  e2e_ok "runtime deactivate ok"
else
  e2e_error "runtime deactivate failed"
fi

if grep -q 'RUNTIME ACTIVE ACTOR : owner' /tmp/kao-runtime-deactivate.$$.out; then
  e2e_ok "runtime deactivate restored owner baseline"
else
  e2e_error "runtime deactivate did not restore owner baseline"
fi

if [ ! -f "${RUNTIME_USER_STATE}" ]; then
  e2e_ok "runtime user state flag removed"
else
  e2e_error "runtime user state flag still present"
fi

if [ -f "${RUNTIME_STATUS_FILE}" ] && grep -q '^KAO_RUNTIME_ACTIVE_ACTOR=owner$' "${RUNTIME_STATUS_FILE}"; then
  e2e_ok "runtime state file aligned with owner baseline"
else
  e2e_error "runtime state file not aligned"
fi

if [ -f "${RUNTIME_LOG_FILE}" ] && grep -q 'runtime activate user name=runtime user' "${RUNTIME_LOG_FILE}" && grep -q 'runtime deactivate -> owner baseline' "${RUNTIME_LOG_FILE}"; then
  e2e_ok "runtime log contains activation and deactivation trace"
else
  e2e_error "runtime log trace missing"
fi

rm -f \
  /tmp/kao-runtime-status-before.$$.out \
  /tmp/kao-runtime-activate.$$.out \
  /tmp/kao-runtime-snapshot.$$.out \
  /tmp/kao-runtime-diff.$$.out \
  /tmp/kao-runtime-deactivate.$$.out
}
