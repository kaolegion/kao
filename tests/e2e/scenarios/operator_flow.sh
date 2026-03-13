#!/usr/bin/env bash
scenario_operator_flow() {

[ -x /home/kao/bin/kao ] && e2e_ok "kao entry ok" || e2e_warn "kao not executable"
[ -x /home/kao/bin/kao-user ] && e2e_ok "kao user command ok" || e2e_error "kao user command missing"
[ -d /home/kao/runtime ] && e2e_ok "runtime ok" || e2e_warn "runtime missing"
[ -d /home/kao/templates ] && e2e_ok "templates ok" || e2e_warn "templates missing"
[ -f /home/kao/lib/kao-owner-state.sh ] && e2e_ok "owner state lib present" || e2e_error "owner state lib missing"
[ -f /home/kao/lib/kao-user-state.sh ] && e2e_ok "user state lib present" || e2e_error "user state lib missing"

USER_ENV_FILE="/home/kao/config/user.env"
USER_STATE_FILE="/home/kao/config/user.state"
USER_SNAPSHOT_FILE="/home/kao/config/user.active.snapshot.env"

rm -f "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

OWNER_USE_ALIAS_OUTPUT="$(/home/kao/bin/kao owner use smoke 2>&1 || true)"
printf '%s\n' "${OWNER_USE_ALIAS_OUTPUT}" | grep -Fq 'OWNER PRESET ACTIVATED' \
  && e2e_ok "owner use alias command header visible" \
  || e2e_error "owner use alias command header missing"

BOOT_INACTIVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner' \
  && e2e_ok "boot inactive owner scene visible in operator flow" \
  || e2e_error "boot inactive owner scene missing in operator flow"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'USER STATE        : INACTIVE' \
  && e2e_ok "boot inactive user state visible in operator flow" \
  || e2e_error "boot inactive user state missing in operator flow"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'USER MODE         : inactive' \
  && e2e_ok "boot inactive user mode visible in operator flow" \
  || e2e_error "boot inactive user mode missing in operator flow"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'USER RECOVER      : none' \
  && e2e_ok "boot inactive user recover hint visible in operator flow" \
  || e2e_error "boot inactive user recover hint missing in operator flow"

printf '%s\n' "${BOOT_INACTIVE_OUTPUT}" | grep -Fq 'ACTIVE            : owner' \
  && e2e_ok "boot inactive active entities visible in operator flow" \
  || e2e_error "boot inactive active entities missing in operator flow"

cat > "${USER_ENV_FILE}" <<'EOF_USER_AVAILABLE'
KAO_USER_NAME="operator flow user"
KAO_USER_ROLE="operator user"
KAO_USER_ID="user-operator-flow"
KAO_USER_TITLE="flow profile"
KAO_USER_HANDLE="flowuser"
KAO_USER_ORG="kaobox"
EOF_USER_AVAILABLE

rm -f "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

BOOT_AVAILABLE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot available user scene visible in operator flow" \
  || e2e_error "boot available user scene missing in operator flow"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER NAME         : operator flow user' \
  && e2e_ok "boot available user name visible in operator flow" \
  || e2e_error "boot available user name missing in operator flow"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER STATE        : AVAILABLE' \
  && e2e_ok "boot available user state visible in operator flow" \
  || e2e_error "boot available user state missing in operator flow"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER MODE         : available' \
  && e2e_ok "boot available user mode visible in operator flow" \
  || e2e_error "boot available user mode missing in operator flow"

printf '%s\n' "${BOOT_AVAILABLE_OUTPUT}" | grep -Fq 'USER ACT HINT     : run kao user activate' \
  && e2e_ok "boot available activation hint visible in operator flow" \
  || e2e_error "boot available activation hint missing in operator flow"

printf 'active\n' > "${USER_STATE_FILE}"
cp "${USER_ENV_FILE}" "${USER_SNAPSHOT_FILE}"

BOOT_ACTIVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot active user scene visible in operator flow" \
  || e2e_error "boot active user scene missing in operator flow"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot active user state visible in operator flow" \
  || e2e_error "boot active user state missing in operator flow"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER MODE         : active' \
  && e2e_ok "boot active user mode visible in operator flow" \
  || e2e_error "boot active user mode missing in operator flow"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'ACTIVE            : owner user' \
  && e2e_ok "boot active entities include owner user in operator flow" \
  || e2e_error "boot active entities owner user missing in operator flow"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER SYNC MODE    : CURRENT' \
  && e2e_ok "boot active sync mode current in operator flow" \
  || e2e_error "boot active sync mode current missing in operator flow"

printf '???\n' > "${USER_STATE_FILE}"
rm -f "${USER_SNAPSHOT_FILE}"

BOOT_BROKEN_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot broken user scene visible in operator flow" \
  || e2e_error "boot broken user scene missing in operator flow"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER STATE        : BROKEN' \
  && e2e_ok "boot broken user state visible in operator flow" \
  || e2e_error "boot broken user state missing in operator flow"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER MODE         : broken' \
  && e2e_ok "boot broken user mode visible in operator flow" \
  || e2e_error "boot broken user mode missing in operator flow"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER RECOVER      : run kao user recover' \
  && e2e_ok "boot broken recover hint visible in operator flow" \
  || e2e_error "boot broken recover hint missing in operator flow"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'USER BROKEN WHY   : invalid state marker' \
  && e2e_ok "boot broken reason visible in operator flow" \
  || e2e_error "boot broken reason missing in operator flow"

printf '%s\n' "${BOOT_BROKEN_OUTPUT}" | grep -Fq 'ACTIVE            : owner' \
  && e2e_ok "boot broken active entities stay owner in operator flow" \
  || e2e_error "boot broken active entities missing in operator flow"

printf 'inactive\n' > "${USER_STATE_FILE}"

BOOT_RETURN_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_RETURN_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot deactivated user scene visible in operator flow" \
  || e2e_error "boot deactivated user scene missing in operator flow"

printf '%s\n' "${BOOT_RETURN_OUTPUT}" | grep -Fq 'USER STATE        : AVAILABLE' \
  && e2e_ok "boot deactivated user returns to available in operator flow" \
  || e2e_error "boot deactivated user return state missing in operator flow"

rm -f "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

}
