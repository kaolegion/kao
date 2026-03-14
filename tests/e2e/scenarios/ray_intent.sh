#!/usr/bin/env bash
scenario_ray_intent() {
  local output_file output_cognitive output_bridge
  local output_run_local_safe output_run_local_list output_run_local_pending

  output_file="$(${TMP_BIN}/ray ask "ouvre dossier clients")"
  printf '%s\n' "${output_file}" | grep -F "RAY ASK" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "INTENT  : file-op" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "ROUTE   : local-agent" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "ACTION  : filesystem operator" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "MODE    : auto" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "STRATEGY: local-exec" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "SURFACE : shell" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "DECISION: routed-execution" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "PROVIDER: none" >/dev/null

  output_cognitive="$(${TMP_BIN}/ray ask "résume cette réunion")"
  printf '%s\n' "${output_cognitive}" | grep -F "RAY ASK" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "INTENT  : cognitive-heavy" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "ROUTE   : llm-heavy" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "ACTION  : deep cognitive inference" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "MODE    : auto" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "STRATEGY: gateway-heavy" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "SURFACE : gateway" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "DECISION: routed-execution" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "PROVIDER: mistral" >/dev/null

  output_bridge="$(${TMP_BIN}/ray bridge "ouvre dossier lib")"
  printf '%s\n' "${output_bridge}" | grep -F "EXECUTION BRIDGE" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "intent class   : file-op" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "route family   : local-agent" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "action         : filesystem operator" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "execution mode : auto" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "strategy       : local-exec" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "surface        : shell" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "provider       : none" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "decision       : routed-execution" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "path id        : path-open-directory" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "path label     : open-directory-safe-read" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "path state     : path-ready" >/dev/null

  output_run_local_safe="$(${TMP_BIN}/ray run "ouvre dossier lib")"
  printf '%s\n' "${output_run_local_safe}" | grep -F "RAY RUN" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "EXECUTION BRIDGE" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "path id        : path-open-directory" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "path label     : open-directory-safe-read" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "path state     : path-ready" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "EXECUTION RESULT" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "state          : executed" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "path id        : path-open-directory" >/dev/null
  printf '%s\n' "${output_run_local_safe}" | grep -F "resolved path  : ${TMP_ROOT}/lib" >/dev/null

  output_run_local_list="$(${TMP_BIN}/ray run "liste fichiers")"
  printf '%s\n' "${output_run_local_list}" | grep -F "RAY RUN" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "EXECUTION BRIDGE" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "path id        : path-list-current-directory" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "path label     : list-current-directory-safe-read" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "path state     : path-ready" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "EXECUTION RESULT" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "state          : executed" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "path id        : path-list-current-directory" >/dev/null
  printf '%s\n' "${output_run_local_list}" | grep -F "resolved path  : ${TMP_ROOT}" >/dev/null

  output_run_local_pending="$(${TMP_BIN}/ray run "rm tmp")"
  printf '%s\n' "${output_run_local_pending}" | grep -F "RAY RUN" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "EXECUTION BRIDGE" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "path id        : none" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "path label     : none" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "path state     : local-action-pending" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "EXECUTION RESULT" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "state          : local-action-pending" >/dev/null
  printf '%s\n' "${output_run_local_pending}" | grep -F "path id        : none" >/dev/null

  printf 'OK ray_intent\n'
}
