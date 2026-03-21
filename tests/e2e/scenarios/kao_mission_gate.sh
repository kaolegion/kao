#!/usr/bin/env bash
source /home/kao/tests/e2e/e2e_framework.sh

scenario_kao_mission_gate() {
  local output

  [ -x /home/kao/bin/kao ] && e2e_ok "kao entrypoint executable for mission gate" || e2e_error "kao entrypoint missing for mission gate"
  [ -x /home/kao/bin/brain ] && e2e_ok "brain entrypoint executable for mission gate" || e2e_error "brain entrypoint missing for mission gate"

  output="$(
    /home/kao/bin/kao ask "prépare un cv" 2>&1
  )"

  printf '%s\n' "${output}" | grep -q "KAO MISSION GATE" \
    && e2e_ok "mission gate banner visible" \
    || e2e_error "mission gate banner missing"

  printf '%s\n' "${output}" | grep -q "recon      : Rekon" \
    && e2e_ok "mission gate Rekon visible" \
    || e2e_error "mission gate Rekon missing"

  printf '%s\n' "${output}" | grep -q "guard      : Sentinel" \
    && e2e_ok "mission gate Sentinel visible" \
    || e2e_error "mission gate Sentinel missing"

  printf '%s\n' "${output}" | grep -q "kernel     : Kao" \
    && e2e_ok "mission gate Kao kernel visible" \
    || e2e_error "mission gate Kao kernel missing"

  printf '%s\n' "${output}" | grep -q "intent     :" \
    && e2e_ok "mission gate intent visible" \
    || e2e_error "mission gate intent missing"

  printf '%s\n' "${output}" | grep -q "mission    :" \
    && e2e_ok "mission gate mission visible" \
    || e2e_error "mission gate mission missing"

  printf '%s\n' "${output}" | grep -q "steps      :" \
    && e2e_ok "mission gate steps visible" \
    || e2e_error "mission gate steps missing"

  printf '%s\n' "${output}" | grep -q "status     : awaiting-operator-validation" \
    && e2e_ok "mission gate status visible" \
    || e2e_error "mission gate status missing"
}
