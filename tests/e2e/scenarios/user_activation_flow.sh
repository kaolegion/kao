#!/usr/bin/env bash
scenario_user_activation_flow() {

USER_ENV_FILE="/home/kao/config/user.env"
USER_STATE_FILE="/home/kao/config/user.state"
USER_SNAPSHOT_FILE="/home/kao/config/user.active.snapshot.env"

USER_ENV_BACKUP="/tmp/kao-user.env.activation.backup.$$"
USER_STATE_BACKUP="/tmp/kao-user.state.activation.backup.$$"
USER_SNAPSHOT_BACKUP="/tmp/kao-user.snapshot.activation.backup.$$"

USER_ENV_EXISTED=0
USER_STATE_EXISTED=0
USER_SNAPSHOT_EXISTED=0

if [ -f "${USER_ENV_FILE}" ]; then
  cp "${USER_ENV_FILE}" "${USER_ENV_BACKUP}"
  USER_ENV_EXISTED=1
fi

if [ -f "${USER_STATE_FILE}" ]; then
  cp "${USER_STATE_FILE}" "${USER_STATE_BACKUP}"
  USER_STATE_EXISTED=1
fi

if [ -f "${USER_SNAPSHOT_FILE}" ]; then
  cp "${USER_SNAPSHOT_FILE}" "${USER_SNAPSHOT_BACKUP}"
  USER_SNAPSHOT_EXISTED=1
fi

cleanup_user_activation_flow() {
  if [ "${USER_ENV_EXISTED}" -eq 1 ]; then
    cp "${USER_ENV_BACKUP}" "${USER_ENV_FILE}" >/dev/null 2>&1 || true
  else
    rm -f "${USER_ENV_FILE}"
  fi

  if [ "${USER_STATE_EXISTED}" -eq 1 ]; then
    cp "${USER_STATE_BACKUP}" "${USER_STATE_FILE}" >/dev/null 2>&1 || true
  else
    rm -f "${USER_STATE_FILE}"
  fi

  if [ "${USER_SNAPSHOT_EXISTED}" -eq 1 ]; then
    cp "${USER_SNAPSHOT_BACKUP}" "${USER_SNAPSHOT_FILE}" >/dev/null 2>&1 || true
  else
    rm -f "${USER_SNAPSHOT_FILE}"
  fi

  rm -f "${USER_ENV_BACKUP}" "${USER_STATE_BACKUP}" "${USER_SNAPSHOT_BACKUP}"
}
trap cleanup_user_activation_flow EXIT

rm -f "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

USER_ACTIVATE_MISSING_OUTPUT="$(/home/kao/bin/kao user activate 2>&1 || true)"
printf '%s\n' "${USER_ACTIVATE_MISSING_OUTPUT}" | grep -Fq 'policy_state     : DENY' \
  && e2e_ok "user activate denied without source" \
  || e2e_error "user activate deny missing without source"

printf '%s\n' "${USER_ACTIVATE_MISSING_OUTPUT}" | grep -Fq 'activation_action : missing-runtime-source' \
  && e2e_ok "user activate missing source action visible" \
  || e2e_error "user activate missing source action missing"

printf '%s\n' "${USER_ACTIVATE_MISSING_OUTPUT}" | grep -Fq 'result_state     : INACTIVE' \
  && e2e_ok "user activate inactive result visible without source" \
  || e2e_error "user activate inactive result missing without source"

cat > "${USER_ENV_FILE}" <<'EOF_USER_VALID'
KAO_USER_NAME="runtime activation user"
KAO_USER_ROLE="operator user"
KAO_USER_ID="user-runtime-activation"
KAO_USER_TITLE="activation profile"
KAO_USER_HANDLE="activationuser"
KAO_USER_ORG="kaobox"
EOF_USER_VALID

rm -f "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

USER_CURRENT_AVAILABLE_OUTPUT="$(/home/kao/bin/kao user current)"
printf '%s\n' "${USER_CURRENT_AVAILABLE_OUTPUT}" | grep -Fq 'result_state     : AVAILABLE' \
  && e2e_ok "user current available result visible" \
  || e2e_error "user current available result missing"

printf '%s\n' "${USER_CURRENT_AVAILABLE_OUTPUT}" | grep -Fq 'state_mode       : available' \
  && e2e_ok "user current available mode visible" \
  || e2e_error "user current available mode missing"

printf '%s\n' "${USER_CURRENT_AVAILABLE_OUTPUT}" | grep -Fq 'activation_hint  : run kao user activate' \
  && e2e_ok "user current available activation hint visible" \
  || e2e_error "user current available activation hint missing"

USER_ACTIVATE_OUTPUT="$(/home/kao/bin/kao user activate)"
printf '%s\n' "${USER_ACTIVATE_OUTPUT}" | grep -Fq 'KAO USER ACTIVATE' \
  && e2e_ok "user activate header visible" \
  || e2e_error "user activate header missing"

printf '%s\n' "${USER_ACTIVATE_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user activate success policy visible" \
  || e2e_error "user activate success policy missing"

printf '%s\n' "${USER_ACTIVATE_OUTPUT}" | grep -Fq 'activation_action : activated-runtime-source' \
  && e2e_ok "user activate action visible" \
  || e2e_error "user activate action missing"

printf '%s\n' "${USER_ACTIVATE_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "user activate active result visible" \
  || e2e_error "user activate active result missing"

[ -f "${USER_SNAPSHOT_FILE}" ] \
  && e2e_ok "activation snapshot file created" \
  || e2e_error "activation snapshot file missing"

BOOT_ACTIVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot reflects user scene after activate command" \
  || e2e_error "boot user scene missing after activate command"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot reflects active user after activate command" \
  || e2e_error "boot active user reflection missing after activate command"

printf '%s\n' "${BOOT_ACTIVE_OUTPUT}" | grep -Fq 'ACTIVE            : owner user' \
  && e2e_ok "boot active entities owner user visible after activate command" \
  || e2e_error "boot active entities owner user missing after activate command"

USER_DEACTIVATE_OUTPUT="$(/home/kao/bin/kao user deactivate)"
printf '%s\n' "${USER_DEACTIVATE_OUTPUT}" | grep -Fq 'KAO USER DEACTIVATE' \
  && e2e_ok "user deactivate header visible" \
  || e2e_error "user deactivate header missing"

printf '%s\n' "${USER_DEACTIVATE_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user deactivate success policy visible" \
  || e2e_error "user deactivate success policy missing"

printf '%s\n' "${USER_DEACTIVATE_OUTPUT}" | grep -Fq 'deactivation_action : deactivated-runtime-source' \
  && e2e_ok "user deactivate action visible" \
  || e2e_error "user deactivate action missing"

printf '%s\n' "${USER_DEACTIVATE_OUTPUT}" | grep -Fq 'result_state     : AVAILABLE' \
  && e2e_ok "user deactivate available result visible" \
  || e2e_error "user deactivate available result missing"

BOOT_DEACTIVATED_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_DEACTIVATED_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot keeps user scene after deactivate command" \
  || e2e_error "boot user scene missing after deactivate command"

printf '%s\n' "${BOOT_DEACTIVATED_OUTPUT}" | grep -Fq 'USER STATE        : AVAILABLE' \
  && e2e_ok "boot reflects available user after deactivate command" \
  || e2e_error "boot available user reflection missing after deactivate command"

printf '%s\n' "${BOOT_DEACTIVATED_OUTPUT}" | grep -Fq 'ACTIVE            : owner' \
  && e2e_ok "boot active entities return to owner after deactivate command" \
  || e2e_error "boot active entities owner missing after deactivate command"

printf '???\n' > "${USER_STATE_FILE}"
rm -f "${USER_SNAPSHOT_FILE}"

USER_CURRENT_BROKEN_OUTPUT="$(/home/kao/bin/kao user current)"
printf '%s\n' "${USER_CURRENT_BROKEN_OUTPUT}" | grep -Fq 'result_state     : BROKEN' \
  && e2e_ok "user current broken result visible" \
  || e2e_error "user current broken result missing"

printf '%s\n' "${USER_CURRENT_BROKEN_OUTPUT}" | grep -Fq 'broken_reason    : invalid state marker' \
  && e2e_ok "user current broken reason visible" \
  || e2e_error "user current broken reason missing"

USER_ACTIVATE_BROKEN_OUTPUT="$(/home/kao/bin/kao user activate 2>&1 || true)"
printf '%s\n' "${USER_ACTIVATE_BROKEN_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user activate success on broken state visible" \
  || e2e_error "user activate success on broken state missing"

printf '%s\n' "${USER_ACTIVATE_BROKEN_OUTPUT}" | grep -Fq 'activation_action : activated-runtime-source' \
  && e2e_ok "user activate broken state action visible" \
  || e2e_error "user activate broken state action missing"

printf '%s\n' "${USER_ACTIVATE_BROKEN_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "user activate broken state becomes active" \
  || e2e_error "user activate broken state active result missing"

BOOT_BROKEN_ACTIVATED_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_BROKEN_ACTIVATED_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot reflects active state after broken activate" \
  || e2e_error "boot active state missing after broken activate"

USER_RECOVER_OUTPUT="$(/home/kao/bin/kao user recover)"
printf '%s\n' "${USER_RECOVER_OUTPUT}" | grep -Fq 'KAO USER RECOVER' \
  && e2e_ok "user recover header visible" \
  || e2e_error "user recover header missing"

printf '%s\n' "${USER_RECOVER_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user recover success policy visible" \
  || e2e_error "user recover success policy missing"

printf '%s\n' "${USER_RECOVER_OUTPUT}" | grep -Fq 'repair_action    : normalized-active-marker' \
  && e2e_ok "user recover normalize marker action visible" \
  || e2e_error "user recover normalize marker action missing"

printf '%s\n' "${USER_RECOVER_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "user recover active result visible" \
  || e2e_error "user recover active result missing"

BOOT_RECOVERED_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_RECOVERED_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot reflects active state after recover" \
  || e2e_error "boot active state missing after recover"

printf '%s\n' "${BOOT_RECOVERED_OUTPUT}" | grep -Fq 'USER SYNC MODE    : CURRENT' \
  && e2e_ok "boot current sync mode visible after recover" \
  || e2e_error "boot current sync mode missing after recover"

cat > "${USER_ENV_FILE}" <<'EOF_USER_INVALID'
KAO_USER_NAME="broken
EOF_USER_INVALID
rm -f "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

USER_ACTIVATE_INVALID_OUTPUT="$(/home/kao/bin/kao user activate 2>&1 || true)"
printf '%s\n' "${USER_ACTIVATE_INVALID_OUTPUT}" | grep -Fq 'ERROR: invalid user env syntax: /home/kao/config/user.env' \
  && e2e_ok "user activate invalid source syntax error visible" \
  || e2e_error "user activate invalid source syntax error missing"

printf '%s\n' "${USER_ACTIVATE_INVALID_OUTPUT}" | grep -Fq 'policy_state     : DENY' \
  && e2e_ok "user activate denied with invalid source" \
  || e2e_error "user activate deny missing with invalid source"

printf '%s\n' "${USER_ACTIVATE_INVALID_OUTPUT}" | grep -Fq 'activation_action : invalid-runtime-source' \
  && e2e_ok "user activate invalid source action visible" \
  || e2e_error "user activate invalid source action missing"

printf '%s\n' "${USER_ACTIVATE_INVALID_OUTPUT}" | grep -Fq 'result_state     : INVALID' \
  && e2e_ok "user activate invalid result visible with invalid source" \
  || e2e_error "user activate invalid result missing with invalid source"

BOOT_INVALID_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'USER STATE        : INVALID' \
  && e2e_ok "boot reflects invalid user source" \
  || e2e_error "boot invalid user reflection missing"

printf '%s\n' "${BOOT_INVALID_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner' \
  && e2e_ok "boot invalid source returns owner scene" \
  || e2e_error "boot invalid source owner scene missing"

USER_RECOVER_INVALID_ENV_OUTPUT="$(/home/kao/bin/kao user recover)"
printf '%s\n' "${USER_RECOVER_INVALID_ENV_OUTPUT}" | grep -Fq 'policy_state     : PARTIAL' \
  && e2e_ok "user recover partial policy visible with invalid env" \
  || e2e_error "user recover partial policy missing with invalid env"

printf '%s\n' "${USER_RECOVER_INVALID_ENV_OUTPUT}" | grep -Fq 'repair_action    : removed-broken-state-marker-invalid-env-remains' \
  && e2e_ok "user recover partial repair action visible with invalid env" \
  || e2e_error "user recover partial repair action missing with invalid env"

printf '%s\n' "${USER_RECOVER_INVALID_ENV_OUTPUT}" | grep -Fq 'result_state     : INVALID' \
  && e2e_ok "user recover invalid result visible with invalid env" \
  || e2e_error "user recover invalid result missing with invalid env"

}
