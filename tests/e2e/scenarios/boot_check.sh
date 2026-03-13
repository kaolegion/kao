#!/usr/bin/env bash
scenario_boot_check() {

[ -d /home/kao ] && e2e_ok "root exists" || e2e_error "root missing"
[ -d /home/kao/bin ] && e2e_ok "bin exists" || e2e_error "bin missing"
[ -d /home/kao/lib ] && e2e_ok "lib exists" || e2e_error "lib missing"
[ -x /home/kao/bin/kao ] && e2e_ok "kao executable ok" || e2e_error "kao executable missing"
[ -x /home/kao/bin/kao-boot ] && e2e_ok "kao-boot executable ok" || e2e_error "kao-boot executable missing"
[ -x /home/kao/bin/kao-owner ] && e2e_ok "kao-owner executable ok" || e2e_error "kao-owner executable missing"
[ -x /home/kao/bin/kao-user ] && e2e_ok "kao-user executable ok" || e2e_error "kao-user executable missing"
[ -x /home/kao/lib/kao-owner-state.sh ] && e2e_ok "kao-owner-state executable ok" || e2e_error "kao-owner-state executable missing"
[ -x /home/kao/lib/kao-user-state.sh ] && e2e_ok "kao-user-state executable ok" || e2e_error "kao-user-state executable missing"
command -v bash >/dev/null && e2e_ok "bash ok" || e2e_error "bash missing"

OWNER_ENV_DIR="/home/kao/config"
OWNER_ENV_FILE="${OWNER_ENV_DIR}/owner.env"
OWNER_PROFILE_SELECTOR_FILE="${OWNER_ENV_DIR}/owner.profile"
OWNER_PRESETS_DIR="/home/kao/profiles/owners"
OWNER_LOG_DIR="/home/kao/state/logs"
OWNER_LOG_FILE="${OWNER_LOG_DIR}/owner.log"
USER_ENV_FILE="${OWNER_ENV_DIR}/user.env"
USER_STATE_FILE="${OWNER_ENV_DIR}/user.state"
USER_SNAPSHOT_FILE="${OWNER_ENV_DIR}/user.active.snapshot.env"

OWNER_ENV_BACKUP="/tmp/kao-owner.env.e2e.backup.$$"
OWNER_PROFILE_SELECTOR_BACKUP="/tmp/kao-owner.profile.e2e.backup.$$"
OWNER_LOG_BACKUP="/tmp/kao-owner.log.e2e.backup.$$"
USER_ENV_BACKUP="/tmp/kao-user.env.e2e.backup.$$"
USER_STATE_BACKUP="/tmp/kao-user.state.e2e.backup.$$"
USER_SNAPSHOT_BACKUP="/tmp/kao-user.snapshot.e2e.backup.$$"

OWNER_ENV_EXISTED=0
OWNER_PROFILE_SELECTOR_EXISTED=0
OWNER_LOG_EXISTED=0
USER_ENV_EXISTED=0
USER_STATE_EXISTED=0
USER_SNAPSHOT_EXISTED=0

mkdir -p "${OWNER_ENV_DIR}" "${OWNER_PRESETS_DIR}" "${OWNER_LOG_DIR}"

if [ -f "${OWNER_ENV_FILE}" ]; then cp "${OWNER_ENV_FILE}" "${OWNER_ENV_BACKUP}"; OWNER_ENV_EXISTED=1; fi
if [ -f "${OWNER_PROFILE_SELECTOR_FILE}" ]; then cp "${OWNER_PROFILE_SELECTOR_FILE}" "${OWNER_PROFILE_SELECTOR_BACKUP}"; OWNER_PROFILE_SELECTOR_EXISTED=1; fi
if [ -f "${OWNER_LOG_FILE}" ]; then cp "${OWNER_LOG_FILE}" "${OWNER_LOG_BACKUP}"; OWNER_LOG_EXISTED=1; fi
if [ -f "${USER_ENV_FILE}" ]; then cp "${USER_ENV_FILE}" "${USER_ENV_BACKUP}"; USER_ENV_EXISTED=1; fi
if [ -f "${USER_STATE_FILE}" ]; then cp "${USER_STATE_FILE}" "${USER_STATE_BACKUP}"; USER_STATE_EXISTED=1; fi
if [ -f "${USER_SNAPSHOT_FILE}" ]; then cp "${USER_SNAPSHOT_FILE}" "${USER_SNAPSHOT_BACKUP}"; USER_SNAPSHOT_EXISTED=1; fi

cleanup_boot_check() {
  if [ "${OWNER_ENV_EXISTED}" -eq 1 ]; then cp "${OWNER_ENV_BACKUP}" "${OWNER_ENV_FILE}" >/dev/null 2>&1 || true; else rm -f "${OWNER_ENV_FILE}"; fi
  if [ "${OWNER_PROFILE_SELECTOR_EXISTED}" -eq 1 ]; then cp "${OWNER_PROFILE_SELECTOR_BACKUP}" "${OWNER_PROFILE_SELECTOR_FILE}" >/dev/null 2>&1 || true; else rm -f "${OWNER_PROFILE_SELECTOR_FILE}"; fi
  if [ "${OWNER_LOG_EXISTED}" -eq 1 ]; then cp "${OWNER_LOG_BACKUP}" "${OWNER_LOG_FILE}" >/dev/null 2>&1 || true; else rm -f "${OWNER_LOG_FILE}"; fi
  if [ "${USER_ENV_EXISTED}" -eq 1 ]; then cp "${USER_ENV_BACKUP}" "${USER_ENV_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_ENV_FILE}"; fi
  if [ "${USER_STATE_EXISTED}" -eq 1 ]; then cp "${USER_STATE_BACKUP}" "${USER_STATE_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_STATE_FILE}"; fi
  if [ "${USER_SNAPSHOT_EXISTED}" -eq 1 ]; then cp "${USER_SNAPSHOT_BACKUP}" "${USER_SNAPSHOT_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_SNAPSHOT_FILE}"; fi
  rm -f "${OWNER_ENV_BACKUP}" "${OWNER_PROFILE_SELECTOR_BACKUP}" "${OWNER_LOG_BACKUP}" "${USER_ENV_BACKUP}" "${USER_STATE_BACKUP}" "${USER_SNAPSHOT_BACKUP}"
}
trap cleanup_boot_check EXIT

cat > "${OWNER_ENV_FILE}" <<'EOF_OWNER'
KAO_OWNER_NAME="kao"
KAO_OWNER_ROLE="machine and system owner"
KAO_OWNER_ID="owner-kao"
EOF_OWNER

rm -f "${OWNER_PROFILE_SELECTOR_FILE}" "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

USER_HELP_OUTPUT="$(/home/kao/bin/kao user help)"
printf '%s\n' "${USER_HELP_OUTPUT}" | grep -Fq 'KAO USER COMMAND' \
  && e2e_ok "user help header visible" \
  || e2e_error "user help header missing"

USER_CURRENT_INACTIVE_OUTPUT="$(/home/kao/bin/kao user current)"
printf '%s\n' "${USER_CURRENT_INACTIVE_OUTPUT}" | grep -Fq 'result_state     : INACTIVE' \
  && e2e_ok "user current inactive state visible" \
  || e2e_error "user current inactive state missing"

BOOT_INACTIVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'KAO :: LOGIN SCENE' \
  && e2e_ok "boot header visible" \
  || e2e_error "boot header missing"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner' \
  && e2e_ok "boot inactive system scene visible" \
  || e2e_error "boot inactive system scene missing"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'USER STATE        : INACTIVE' \
  && e2e_ok "boot inactive user state visible" \
  || e2e_error "boot inactive user state missing"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'ACTIVE            : owner' \
  && e2e_ok "boot inactive active entities visible" \
  || e2e_error "boot inactive active entities missing"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'USER SYNC MODE    : NO_ACTIVE_SNAPSHOT' \
  && e2e_ok "boot inactive sync mode visible" \
  || e2e_error "boot inactive sync mode missing"

cat > "${USER_ENV_FILE}" <<'EOF_USER'
KAO_USER_NAME="boot check user"
KAO_USER_ROLE="operator user"
KAO_USER_ID="user-boot-check"
KAO_USER_TITLE="boot profile"
KAO_USER_HANDLE="bootcheck"
KAO_USER_ORG="kaobox"
EOF_USER
rm -f "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

BOOT_AVAILABLE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot available system scene visible" \
  || e2e_error "boot available system scene missing"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER STATE        : AVAILABLE' \
  && e2e_ok "boot available user state visible" \
  || e2e_error "boot available user state missing"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER MODE         : available' \
  && e2e_ok "boot available user mode visible" \
  || e2e_error "boot available user mode missing"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER SOURCE       : canonical runtime user' \
  && e2e_ok "boot available user source visible" \
  || e2e_error "boot available user source missing"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER ACT HINT     : run kao user activate' \
  && e2e_ok "boot available activation hint visible" \
  || e2e_error "boot available activation hint missing"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER SYNC MODE    : NO_ACTIVE_SNAPSHOT' \
  && e2e_ok "boot available sync mode visible" \
  || e2e_error "boot available sync mode missing"

printf 'active\n' > "${USER_STATE_FILE}"
cp "${USER_ENV_FILE}" "${USER_SNAPSHOT_FILE}"

BOOT_ACTIVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot active user state visible" \
  || e2e_error "boot active user state missing"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER MODE         : active' \
  && e2e_ok "boot active user mode visible" \
  || e2e_error "boot active user mode missing"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'ACTIVE            : owner user' \
  && e2e_ok "boot active entities owner user visible" \
  || e2e_error "boot active entities owner user missing"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER SYNC MODE    : CURRENT' \
  && e2e_ok "boot active current sync mode visible" \
  || e2e_error "boot active current sync mode missing"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER DIFF COUNT   : 0' \
  && e2e_ok "boot active diff count zero visible" \
  || e2e_error "boot active diff count zero missing"

cat > "${USER_ENV_FILE}" <<'EOF_USER_MODIFIED'
KAO_USER_NAME="boot check user"
KAO_USER_ROLE="operator user"
KAO_USER_ID="user-boot-check"
KAO_USER_TITLE="boot profile modified"
KAO_USER_HANDLE="bootcheck"
KAO_USER_ORG="kaobox"
EOF_USER_MODIFIED

BOOT_MODIFIED_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot modified active state visible" \
  || e2e_error "boot modified active state missing"

printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER SYNC MODE    : MODIFIED_SINCE_ACTIVATION' \
  && e2e_ok "boot modified sync mode visible" \
  || e2e_error "boot modified sync mode missing"

printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER DIFF COUNT   : 1' \
  && e2e_ok "boot modified diff count visible" \
  || e2e_error "boot modified diff count missing"

printf '???\n' > "${USER_STATE_FILE}"

BOOT_BROKEN_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER STATE        : BROKEN' \
  && e2e_ok "boot broken user state visible" \
  || e2e_error "boot broken user state missing"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER MODE         : broken' \
  && e2e_ok "boot broken user mode visible" \
  || e2e_error "boot broken user mode missing"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER BROKEN WHY   : invalid state marker' \
  && e2e_ok "boot broken reason visible" \
  || e2e_error "boot broken reason missing"

cat > "${USER_ENV_FILE}" <<'EOF_INVALID'
KAO_USER_NAME="broken
EOF_INVALID
printf 'active\n' > "${USER_STATE_FILE}"
rm -f "${USER_SNAPSHOT_FILE}"

BOOT_INVALID_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'USER STATE        : INVALID' \
  && e2e_ok "boot invalid user state visible" \
  || e2e_error "boot invalid user state missing"

printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'USER MODE         : invalid' \
  && e2e_ok "boot invalid user mode visible" \
  || e2e_error "boot invalid user mode missing"

printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'USER SOURCE       : invalid runtime user' \
  && e2e_ok "boot invalid user source visible" \
  || e2e_error "boot invalid user source missing"

printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'USER SYNC MODE    : INVALID_SOURCE' \
  && e2e_ok "boot invalid sync mode visible" \
  || e2e_error "boot invalid sync mode missing"

}
