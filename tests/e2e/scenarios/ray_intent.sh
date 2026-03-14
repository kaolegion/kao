#!/usr/bin/env bash
scenario_ray_intent() {
  local output_file output_cognitive output_bridge output_run_local

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

  output_bridge="$(${TMP_BIN}/ray bridge "résume cette réunion")"
  printf '%s\n' "${output_bridge}" | grep -F "EXECUTION BRIDGE" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "intent class   : cognitive-heavy" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "route family   : llm-heavy" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "action         : deep cognitive inference" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "execution mode : auto" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "strategy       : gateway-heavy" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "surface        : gateway" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "provider       : mistral" >/dev/null
  printf '%s\n' "${output_bridge}" | grep -F "decision       : routed-execution" >/dev/null

  output_run_local="$(${TMP_BIN}/ray run "ouvre dossier clients")"
  printf '%s\n' "${output_run_local}" | grep -F "RAY RUN" >/dev/null
  printf '%s\n' "${output_run_local}" | grep -F "intent   : file-op" >/dev/null
  printf '%s\n' "${output_run_local}" | grep -F "strategy : local-exec" >/dev/null
  printf '%s\n' "${output_run_local}" | grep -F "surface  : shell" >/dev/null
  printf '%s\n' "${output_run_local}" | grep -F "state    : bridge-ready-local-action-pending" >/dev/null

  printf 'OK ray_intent\n'
}
