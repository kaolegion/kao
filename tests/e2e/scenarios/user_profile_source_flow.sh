#!/usr/bin/env bash
scenario_user_profile_source_flow() {

USER_ENV_FILE="/home/kao/config/user.env"
USER_STATE_FILE="/home/kao/config/user.state"
USER_SNAPSHOT_FILE="/home/kao/config/user.active.snapshot.env"

USER_ENV_BACKUP="/tmp/kao-user.env.profile-source.backup.$$"
USER_STATE_BACKUP="/tmp/kao-user.state.profile-source.backup.$$"
USER_SNAPSHOT_BACKUP="/tmp/kao-user.snapshot.profile-source.backup.$$"

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

cleanup_user_profile_source_flow() {
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
trap cleanup_user_profile_source_flow EXIT

rm -f "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

USER_INSPECT_MISSING_OUTPUT="$(/home/kao/bin/kao user inspect)"
printf '%s\n' "${USER_INSPECT_MISSING_OUTPUT}" | grep -Fq 'source_state     : MISSING' \
  && e2e_ok "user inspect missing source state visible" \
  || e2e_error "user inspect missing source state missing"

printf '%s\n' "${USER_INSPECT_MISSING_OUTPUT}" | grep -Fq 'source_label     : missing runtime user' \
  && e2e_ok "user inspect missing source label visible" \
  || e2e_error "user inspect missing source label missing"

printf '%s\n' "${USER_INSPECT_MISSING_OUTPUT}" | grep -Fq 'source_value     : /home/kao/config/user.env' \
  && e2e_ok "user inspect missing source value visible" \
  || e2e_error "user inspect missing source value missing"

USER_CREATE_OUTPUT="$(/home/kao/bin/kao user create "Profile Flow User" "operator user" "" "profile title" "profilehandle" "kaobox")"
printf '%s\n' "${USER_CREATE_OUTPUT}" | grep -Fq 'KAO USER CREATE' \
  && e2e_ok "user create header visible" \
  || e2e_error "user create header missing"

printf '%s\n' "${USER_CREATE_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user create success policy visible" \
  || e2e_error "user create success policy missing"

printf '%s\n' "${USER_CREATE_OUTPUT}" | grep -Fq 'create_action    : created-runtime-source' \
  && e2e_ok "user create action visible" \
  || e2e_error "user create action missing"

printf '%s\n' "${USER_CREATE_OUTPUT}" | grep -Fq 'result_state     : AVAILABLE' \
  && e2e_ok "user create available result state visible" \
  || e2e_error "user create available result state missing"

[ -f "${USER_ENV_FILE}" ] \
  && e2e_ok "user create generated env file" \
  || e2e_error "user create missing env file"

USER_INSPECT_VALID_OUTPUT="$(/home/kao/bin/kao user inspect)"
printf '%s\n' "${USER_INSPECT_VALID_OUTPUT}" | grep -Fq 'source_state     : VALID' \
  && e2e_ok "user inspect valid source state visible" \
  || e2e_error "user inspect valid source state missing"

printf '%s\n' "${USER_INSPECT_VALID_OUTPUT}" | grep -Fq 'resolved_name    : Profile Flow User' \
  && e2e_ok "user inspect resolved name visible" \
  || e2e_error "user inspect resolved name missing"

printf '%s\n' "${USER_INSPECT_VALID_OUTPUT}" | grep -Fq 'resolved_id      : user-profile-flow-user' \
  && e2e_ok "user inspect resolved generated id visible" \
  || e2e_error "user inspect resolved generated id missing"

BOOT_AFTER_CREATE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_AFTER_CREATE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner / user' \
  && e2e_ok "boot reflects user scene after create" \
  || e2e_error "boot user scene missing after create"

printf '%s\n' "${BOOT_AFTER_CREATE_OUTPUT}" | grep -Fq 'USER STATE        : AVAILABLE' \
  && e2e_ok "boot reflects available state after create" \
  || e2e_error "boot available state missing after create"

printf '%s\n' "${BOOT_AFTER_CREATE_OUTPUT}" | grep -Fq 'USER NAME         : Profile Flow User' \
  && e2e_ok "boot reflects created user identity after create" \
  || e2e_error "boot created user identity missing after create"

printf '%s\n' "${BOOT_AFTER_CREATE_OUTPUT}" | grep -Fq 'USER ACT HINT     : run kao user activate' \
  && e2e_ok "boot activation hint visible after create" \
  || e2e_error "boot activation hint missing after create"

printf 'active\n' > "${USER_STATE_FILE}"

USER_REMOVE_OUTPUT="$(/home/kao/bin/kao user remove)"
printf '%s\n' "${USER_REMOVE_OUTPUT}" | grep -Fq 'KAO USER REMOVE' \
  && e2e_ok "user remove header visible" \
  || e2e_error "user remove header missing"

printf '%s\n' "${USER_REMOVE_OUTPUT}" | grep -Fq 'policy_state     : SUCCESS' \
  && e2e_ok "user remove success policy visible" \
  || e2e_error "user remove success policy missing"

printf '%s\n' "${USER_REMOVE_OUTPUT}" | grep -Fq 'remove_action    : removed-runtime-source-state-and-snapshot' \
  && e2e_ok "user remove action visible" \
  || e2e_error "user remove action missing"

printf '%s\n' "${USER_REMOVE_OUTPUT}" | grep -Fq 'result_state     : INACTIVE' \
  && e2e_ok "user remove inactive result state visible" \
  || e2e_error "user remove inactive result state missing"

[ ! -f "${USER_ENV_FILE}" ] \
  && e2e_ok "user remove deleted env file" \
  || e2e_error "user remove env file still present"

[ ! -f "${USER_STATE_FILE}" ] \
  && e2e_ok "user remove deleted state file" \
  || e2e_error "user remove state file still present"

[ ! -f "${USER_SNAPSHOT_FILE}" ] \
  && e2e_ok "user remove deleted snapshot file" \
  || e2e_error "user remove snapshot file still present"

USER_CURRENT_AFTER_REMOVE_OUTPUT="$(/home/kao/bin/kao user current)"
printf '%s\n' "${USER_CURRENT_AFTER_REMOVE_OUTPUT}" | grep -Fq 'result_state     : INACTIVE' \
  && e2e_ok "user current inactive after remove visible" \
  || e2e_error "user current inactive after remove missing"

BOOT_AFTER_REMOVE_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_AFTER_REMOVE_OUTPUT}" | grep -Fq 'USER STATE        : INACTIVE' \
  && e2e_ok "boot reflects inactive state after remove" \
  || e2e_error "boot inactive state missing after remove"

printf '%s\n' "${BOOT_AFTER_REMOVE_OUTPUT}" | grep -Fq 'SYSTEM SCENE      : machine / system / owner' \
  && e2e_ok "boot scene returns to owner after remove" \
  || e2e_error "boot owner scene missing after remove"

}
