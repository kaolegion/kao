#!/usr/bin/env bash
scenario_user_patch_flow() {

USER_ENV_DIR="/home/kao/config"
USER_ENV_FILE="${USER_ENV_DIR}/user.env"
USER_STATE_FILE="${USER_ENV_DIR}/user.state"
USER_SNAPSHOT_FILE="${USER_ENV_DIR}/user.active.snapshot.env"
USER_LOG_FILE="/home/kao/state/logs/user.log"

USER_ENV_BACKUP="/tmp/kao-user.env.patch.e2e.backup.$$"
USER_STATE_BACKUP="/tmp/kao-user.state.patch.e2e.backup.$$"
USER_SNAPSHOT_BACKUP="/tmp/kao-user.snapshot.patch.e2e.backup.$$"
USER_LOG_BACKUP="/tmp/kao-user.log.patch.e2e.backup.$$"

USER_ENV_EXISTED=0
USER_STATE_EXISTED=0
USER_SNAPSHOT_EXISTED=0
USER_LOG_EXISTED=0

mkdir -p "${USER_ENV_DIR}" /home/kao/state/logs

if [ -f "${USER_ENV_FILE}" ]; then cp "${USER_ENV_FILE}" "${USER_ENV_BACKUP}"; USER_ENV_EXISTED=1; fi
if [ -f "${USER_STATE_FILE}" ]; then cp "${USER_STATE_FILE}" "${USER_STATE_BACKUP}"; USER_STATE_EXISTED=1; fi
if [ -f "${USER_SNAPSHOT_FILE}" ]; then cp "${USER_SNAPSHOT_FILE}" "${USER_SNAPSHOT_BACKUP}"; USER_SNAPSHOT_EXISTED=1; fi
if [ -f "${USER_LOG_FILE}" ]; then cp "${USER_LOG_FILE}" "${USER_LOG_BACKUP}"; USER_LOG_EXISTED=1; fi

cleanup_user_patch_flow() {
  if [ "${USER_ENV_EXISTED}" -eq 1 ]; then cp "${USER_ENV_BACKUP}" "${USER_ENV_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_ENV_FILE}"; fi
  if [ "${USER_STATE_EXISTED}" -eq 1 ]; then cp "${USER_STATE_BACKUP}" "${USER_STATE_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_STATE_FILE}"; fi
  if [ "${USER_SNAPSHOT_EXISTED}" -eq 1 ]; then cp "${USER_SNAPSHOT_BACKUP}" "${USER_SNAPSHOT_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_SNAPSHOT_FILE}"; fi
  if [ "${USER_LOG_EXISTED}" -eq 1 ]; then cp "${USER_LOG_BACKUP}" "${USER_LOG_FILE}" >/dev/null 2>&1 || true; else rm -f "${USER_LOG_FILE}"; fi
  rm -f "${USER_ENV_BACKUP}" "${USER_STATE_BACKUP}" "${USER_SNAPSHOT_BACKUP}" "${USER_LOG_BACKUP}"
}
trap cleanup_user_patch_flow EXIT

rm -f "${USER_ENV_FILE}" "${USER_STATE_FILE}" "${USER_SNAPSHOT_FILE}"

PATCH_MISSING_OUTPUT="$(/home/kao/bin/kao user patch TITLE "ghost patch" 2>&1 || true)"
printf '%s\n' "${PATCH_MISSING_OUTPUT}" | grep -Fq 'patch_action     : missing-runtime-source' \
  && e2e_ok "patch missing source denied" \
  || e2e_error "patch missing source denial missing"

CREATE_OUTPUT="$(/home/kao/bin/kao user create "Patch User" "operator user" "user-patch" "builder" "patchy" "kaobox")"
printf '%s\n' "${CREATE_OUTPUT}" | grep -Fq 'result_state     : AVAILABLE' \
  && e2e_ok "create available state visible" \
  || e2e_error "create available state missing"

PATCH_OUTPUT="$(/home/kao/bin/kao user patch TITLE "chief patcher")"
printf '%s\n' "${PATCH_OUTPUT}" | grep -Fq 'patch_action     : patched-runtime-source' \
  && e2e_ok "single patch success visible" \
  || e2e_error "single patch success missing"

printf '%s\n' "${PATCH_OUTPUT}" | grep -Fq 'field            : KAO_USER_TITLE' \
  && e2e_ok "single patch normalized field visible" \
  || e2e_error "single patch normalized field missing"

INSPECT_PATCHED_OUTPUT="$(/home/kao/bin/kao user inspect)"
printf '%s\n' "${INSPECT_PATCHED_OUTPUT}" | grep -Fq 'resolved_title   : chief patcher' \
  && e2e_ok "inspect patched title visible" \
  || e2e_error "inspect patched title missing"

UPDATE_OUTPUT="$(/home/kao/bin/kao user update HANDLE=patch-master ORG=kaobox-labs)"
printf '%s\n' "${UPDATE_OUTPUT}" | grep -Fq 'update_action    : updated-runtime-source' \
  && e2e_ok "multi update success visible" \
  || e2e_error "multi update success missing"

printf '%s\n' "${UPDATE_OUTPUT}" | grep -Fq 'update_count     : 2' \
  && e2e_ok "multi update count visible" \
  || e2e_error "multi update count missing"

INSPECT_UPDATED_OUTPUT="$(/home/kao/bin/kao user inspect)"
printf '%s\n' "${INSPECT_UPDATED_OUTPUT}" | grep -Fq 'resolved_handle  : patch-master' \
  && e2e_ok "inspect updated handle visible" \
  || e2e_error "inspect updated handle missing"

printf '%s\n' "${INSPECT_UPDATED_OUTPUT}" | grep -Fq 'resolved_org     : kaobox-labs' \
  && e2e_ok "inspect updated org visible" \
  || e2e_error "inspect updated org missing"

ACTIVATE_OUTPUT="$(/home/kao/bin/kao user activate)"
printf '%s\n' "${ACTIVATE_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "activate active state visible" \
  || e2e_error "activate active state missing"

[ -f "${USER_SNAPSHOT_FILE}" ] \
  && e2e_ok "activation snapshot file created" \
  || e2e_error "activation snapshot file missing"

DIFF_CURRENT_OUTPUT="$(/home/kao/bin/kao user diff)"
printf '%s\n' "${DIFF_CURRENT_OUTPUT}" | grep -Fq 'diff_count       : 0' \
  && e2e_ok "diff zero after activation visible" \
  || e2e_error "diff zero after activation missing"

printf '%s\n' "${DIFF_CURRENT_OUTPUT}" | grep -Fq 'sync_mode        : CURRENT' \
  && e2e_ok "diff current mode visible" \
  || e2e_error "diff current mode missing"

PATCH_ACTIVE_OUTPUT="$(/home/kao/bin/kao user patch TITLE "post activation patch")"
printf '%s\n' "${PATCH_ACTIVE_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "patch while active keeps active state" \
  || e2e_error "patch while active state missing"

DIFF_MODIFIED_OUTPUT="$(/home/kao/bin/kao user diff)"
printf '%s\n' "${DIFF_MODIFIED_OUTPUT}" | grep -Fq 'diff_count       : 1' \
  && e2e_ok "diff count after active patch visible" \
  || e2e_error "diff count after active patch missing"

printf '%s\n' "${DIFF_MODIFIED_OUTPUT}" | grep -Fq 'sync_mode        : MODIFIED_SINCE_ACTIVATION' \
  && e2e_ok "diff modified mode visible" \
  || e2e_error "diff modified mode missing"

printf '%s\n' "${DIFF_MODIFIED_OUTPUT}" | grep -Fq 'changed_kao_user_title_active : chief patcher' \
  && e2e_ok "diff active title visible" \
  || e2e_error "diff active title missing"

printf '%s\n' "${DIFF_MODIFIED_OUTPUT}" | grep -Fq 'changed_kao_user_title_current : post activation patch' \
  && e2e_ok "diff current title visible" \
  || e2e_error "diff current title missing"

BOOT_MODIFIED_OUTPUT="$(bash /home/kao/bin/kao-boot)"
printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER STATE        : ACTIVE' \
  && e2e_ok "boot active state after patch visible" \
  || e2e_error "boot active state after patch missing"

printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER SYNC MODE    : MODIFIED_SINCE_ACTIVATION' \
  && e2e_ok "boot modified sync mode visible" \
  || e2e_error "boot modified sync mode missing"

printf '%s\n' "${BOOT_MODIFIED_OUTPUT}" | grep -Fq 'USER DIFF COUNT   : 1' \
  && e2e_ok "boot modified diff count visible" \
  || e2e_error "boot modified diff count missing"

REWRITE_OUTPUT="$(/home/kao/bin/kao user rewrite)"
printf '%s\n' "${REWRITE_OUTPUT}" | grep -Fq 'rewrite_action   : rewritten-runtime-source' \
  && e2e_ok "rewrite action visible" \
  || e2e_error "rewrite action missing"

ACTIVATE_RESYNC_OUTPUT="$(/home/kao/bin/kao user activate)"
printf '%s\n' "${ACTIVATE_RESYNC_OUTPUT}" | grep -Fq 'result_state     : ACTIVE' \
  && e2e_ok "reactivate after rewrite visible" \
  || e2e_error "reactivate after rewrite missing"

DIFF_RESYNC_OUTPUT="$(/home/kao/bin/kao user diff)"
printf '%s\n' "${DIFF_RESYNC_OUTPUT}" | grep -Fq 'diff_count       : 0' \
  && e2e_ok "diff zero after resync visible" \
  || e2e_error "diff zero after resync missing"

printf '%s\n' "${DIFF_RESYNC_OUTPUT}" | grep -Fq 'sync_mode        : CURRENT' \
  && e2e_ok "diff current after resync visible" \
  || e2e_error "diff current after resync missing"

FORBIDDEN_PATCH_OUTPUT="$(/home/kao/bin/kao user patch EMAIL test@example.com 2>&1 || true)"
printf '%s\n' "${FORBIDDEN_PATCH_OUTPUT}" | grep -Fq 'patch_action     : forbidden-field' \
  && e2e_ok "forbidden patch denied" \
  || e2e_error "forbidden patch denial missing"

LOG_OUTPUT="$(tail -n 20 "${USER_LOG_FILE}" 2>/dev/null || true)"
printf '%s\n' "${LOG_OUTPUT}" | grep -Fq 'user.patch | action=patched-runtime-source' \
  && e2e_ok "user patch log visible" \
  || e2e_error "user patch log missing"

printf '%s\n' "${LOG_OUTPUT}" | grep -Fq 'user.update | action=updated-runtime-source' \
  && e2e_ok "user update log visible" \
  || e2e_error "user update log missing"

printf '%s\n' "${LOG_OUTPUT}" | grep -Fq 'user.rewrite | action=rewritten-runtime-source' \
  && e2e_ok "user rewrite log visible" \
  || e2e_error "user rewrite log missing"

}
