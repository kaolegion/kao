#!/usr/bin/env bash
scenario_ray_surface() {

[ -x /home/kao/bin/ray ] && e2e_ok "ray entrypoint executable" || e2e_error "ray entrypoint missing"
[ -x /home/kao/bin/brain ] && e2e_ok "brain entrypoint executable for ray surface" || e2e_error "brain entrypoint missing for ray surface"
[ -f /home/kao/lib/gateway/router.sh ] && e2e_ok "gateway router present for ray surface" || e2e_error "gateway router missing for ray surface"

ray_status_output="$(
  /home/kao/bin/ray status 2>&1
)"

printf '%s\n' "${ray_status_output}" | grep -q "RAY STATUS" \
  && e2e_ok "ray status banner visible" \
  || e2e_error "ray status banner missing"

printf '%s\n' "${ray_status_output}" | grep -q "selected route    :" \
  && e2e_ok "ray selected route visible" \
  || e2e_error "ray selected route missing"

printf '%s\n' "${ray_status_output}" | grep -q "selected provider :" \
  && e2e_ok "ray selected provider visible" \
  || e2e_error "ray selected provider missing"

printf '%s\n' "${ray_status_output}" | grep -q "selected kind     :" \
  && e2e_ok "ray selected kind visible" \
  || e2e_error "ray selected kind missing"

printf '%s\n' "${ray_status_output}" | grep -q "selected health   :" \
  && e2e_ok "ray selected health visible" \
  || e2e_error "ray selected health missing"

printf '%s\n' "${ray_status_output}" | grep -q "mode              :" \
  && e2e_ok "ray operator mode visible" \
  || e2e_error "ray operator mode missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "mode              : (online|offline|degraded|hybrid-ready)" \
  && e2e_ok "ray operator mode readable" \
  || e2e_error "ray operator mode value missing"

printf '%s\n' "${ray_status_output}" | grep -q "hybrid state      :" \
  && e2e_ok "ray hybrid state visible" \
  || e2e_error "ray hybrid state missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "hybrid state      : (hybrid-ready|cloud-only|local-only|unavailable)" \
  && e2e_ok "ray hybrid state readable" \
  || e2e_error "ray hybrid state value missing"

printf '%s\n' "${ray_status_output}" | grep -q "cloud readiness   :" \
  && e2e_ok "ray cloud readiness visible" \
  || e2e_error "ray cloud readiness missing"

printf '%s\n' "${ray_status_output}" | grep -q "local readiness   :" \
  && e2e_ok "ray local readiness visible" \
  || e2e_error "ray local readiness missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "local readiness   : (local-stub-ready|local-real-backend-ready|local-real-ready|unavailable)" \
  && e2e_ok "ray local readiness readable" \
  || e2e_error "ray local readiness value missing"

printf '%s\n' "${ray_status_output}" | grep -q "detected provider :" \
  && e2e_ok "ray detected provider visible" \
  || e2e_error "ray detected provider missing"

printf '%s\n' "${ray_status_output}" | grep -q "ollama model      :" \
  && e2e_ok "ray ollama model visible" \
  || e2e_error "ray ollama model missing"

printf '%s\n' "${ray_status_output}" | grep -q "ollama model state:" \
  && e2e_ok "ray ollama model state visible" \
  || e2e_error "ray ollama model state missing"

printf '%s\n' "${ray_status_output}" | grep -q "ollama runtime    :" \
  && e2e_ok "ray ollama runtime visible" \
  || e2e_error "ray ollama runtime missing"

printf '%s\n' "${ray_status_output}" | grep -q "ollama real calls :" \
  && e2e_ok "ray ollama real calls visible" \
  || e2e_error "ray ollama real calls missing"

printf '%s\n' "${ray_status_output}" | grep -q "ollama real state :" \
  && e2e_ok "ray ollama real state visible" \
  || e2e_error "ray ollama real state missing"

ray_default_output="$(
  /home/kao/bin/ray 2>&1
)"

printf '%s\n' "${ray_default_output}" | grep -q "RAY STATUS" \
  && e2e_ok "ray default command visible" \
  || e2e_error "ray default command missing"

ray_help_output="$(
  /home/kao/bin/ray help 2>&1
)"

printf '%s\n' "${ray_help_output}" | grep -q 'USAGE: ray \[status|run "<prompt>"\]' \
  && e2e_ok "ray help visible" \
  || e2e_error "ray help missing"

ray_run_output="$(
  /home/kao/bin/ray run "ray e2e run test" 2>&1
)"

printf '%s\n' "${ray_run_output}" | grep -Eq "gateway -> (mistral cloud|ollama local)" \
  && e2e_ok "ray run route visible" \
  || e2e_error "ray run route missing"

ray_shortcut_output="$(
  /home/kao/bin/ray "ray e2e shortcut test" 2>&1
)"

printf '%s\n' "${ray_shortcut_output}" | grep -Eq "gateway -> (mistral cloud|ollama local)" \
  && e2e_ok "ray shortcut route visible" \
  || e2e_error "ray shortcut route missing"

forced_local_output="$(
  KAO_GATEWAY_PROVIDER=ollama /home/kao/bin/ray run "ray forced local test" 2>&1
)"

printf '%s\n' "${forced_local_output}" | grep -q "gateway -> ollama local" \
  && e2e_ok "ray forced local route visible" \
  || e2e_error "ray forced local route missing"

}
