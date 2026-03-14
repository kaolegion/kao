#!/usr/bin/env bash
scenario_ray_intent() {
  local output_file output_cognitive

  output_file="$(${TMP_BIN}/ray ask "ouvre dossier clients")"
  printf '%s\n' "${output_file}" | grep -F "RAY ASK" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "INTENT  : file-op" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "ROUTE   : local-agent" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "ACTION  : filesystem operator" >/dev/null
  printf '%s\n' "${output_file}" | grep -F "PROVIDER: none" >/dev/null

  output_cognitive="$(${TMP_BIN}/ray ask "résume cette réunion")"
  printf '%s\n' "${output_cognitive}" | grep -F "RAY ASK" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "INTENT  : cognitive-heavy" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "ROUTE   : llm-heavy" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "ACTION  : deep cognitive inference" >/dev/null
  printf '%s\n' "${output_cognitive}" | grep -F "PROVIDER: mistral" >/dev/null

  printf 'OK ray_intent\n'
}
