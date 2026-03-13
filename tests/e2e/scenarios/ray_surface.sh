#!/usr/bin/env bash
scenario_ray_surface() {

[ -x /home/kao/bin/ray ] && e2e_ok "ray entrypoint executable" || e2e_error "ray entrypoint missing"
[ -x /home/kao/bin/brain ] && e2e_ok "brain entrypoint executable for ray surface" || e2e_error "brain entrypoint missing for ray surface"
[ -f /home/kao/lib/gateway/router.sh ] && e2e_ok "gateway router present for ray surface" || e2e_error "gateway router missing for ray surface"
[ -f /home/kao/lib/gateway/model_registry.sh ] && e2e_ok "gateway model registry present for ray surface" || e2e_error "gateway model registry missing for ray surface"

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

printf '%s\n' "${ray_status_output}" | grep -q "decision state    :" \
  && e2e_ok "ray decision state visible" \
  || e2e_error "ray decision state missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "decision state    : (route-selected|no-route-selected|blocked-unsupported-forcing)" \
  && e2e_ok "ray decision state readable" \
  || e2e_error "ray decision state value missing"

printf '%s\n' "${ray_status_output}" | grep -q "route reason      :" \
  && e2e_ok "ray route reason visible" \
  || e2e_error "ray route reason missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "route reason      : (cloud-priority-ready|local-only-available|forced-provider-mistral|forced-provider-ollama|unsupported-forced-provider|no-provider-ready)" \
  && e2e_ok "ray route reason readable" \
  || e2e_error "ray route reason value missing"

printf '%s\n' "${ray_status_output}" | grep -q "route score       :" \
  && e2e_ok "ray route score visible" \
  || e2e_error "ray route score missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "route score       : [0-9][0-9]*" \
  && e2e_ok "ray route score readable" \
  || e2e_error "ray route score value missing"

printf '%s\n' "${ray_status_output}" | grep -q "cloud score       :" \
  && e2e_ok "ray cloud score visible" \
  || e2e_error "ray cloud score missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "cloud score       : [0-9][0-9]*" \
  && e2e_ok "ray cloud score readable" \
  || e2e_error "ray cloud score value missing"

printf '%s\n' "${ray_status_output}" | grep -q "local score       :" \
  && e2e_ok "ray local score visible" \
  || e2e_error "ray local score missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "local score       : [0-9][0-9]*" \
  && e2e_ok "ray local score readable" \
  || e2e_error "ray local score value missing"

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

printf '%s\n' "${ray_status_output}" | grep -q "forced raw value  :" \
  && e2e_ok "ray forced raw value visible" \
  || e2e_error "ray forced raw value missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "forced raw value  : (unset|mistral|ollama|[^[:space:]].*)" \
  && e2e_ok "ray forced raw value readable" \
  || e2e_error "ray forced raw value unreadable"

printf '%s\n' "${ray_status_output}" | grep -q "detected provider :" \
  && e2e_ok "ray detected provider visible" \
  || e2e_error "ray detected provider missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry count    :" \
  && e2e_ok "ray registry count visible" \
  || e2e_error "ray registry count missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry count    : [0-9][0-9]*" \
  && e2e_ok "ray registry count readable" \
  || e2e_error "ray registry count value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry provider :" \
  && e2e_ok "ray registry provider visible" \
  || e2e_error "ray registry provider missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry provider : (mistral|ollama|none)" \
  && e2e_ok "ray registry provider readable" \
  || e2e_error "ray registry provider value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry model    :" \
  && e2e_ok "ray registry model visible" \
  || e2e_error "ray registry model missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry family   :" \
  && e2e_ok "ray registry family visible" \
  || e2e_error "ray registry family missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry family   : (cloud|local|none)" \
  && e2e_ok "ray registry family readable" \
  || e2e_error "ray registry family value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry base     :" \
  && e2e_ok "ray registry base visible" \
  || e2e_error "ray registry base missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry base     : [0-9][0-9]*" \
  && e2e_ok "ray registry base readable" \
  || e2e_error "ray registry base value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry declared :" \
  && e2e_ok "ray registry declared visible" \
  || e2e_error "ray registry declared missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry declared : (unknown|ready|degraded)" \
  && e2e_ok "ray registry declared readable" \
  || e2e_error "ray registry declared value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry runtime  :" \
  && e2e_ok "ray registry runtime visible" \
  || e2e_error "ray registry runtime missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry runtime  : (unknown|ready|degraded)" \
  && e2e_ok "ray registry runtime readable" \
  || e2e_error "ray registry runtime value missing"

printf '%s\n' "${ray_status_output}" | grep -q "registry score    :" \
  && e2e_ok "ray registry score visible" \
  || e2e_error "ray registry score missing"

printf '%s\n' "${ray_status_output}" | grep -Eq "registry score    : [0-9][0-9]*" \
  && e2e_ok "ray registry score readable" \
  || e2e_error "ray registry score value missing"

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

ray_registry_output="$(
  /home/kao/bin/ray registry 2>&1
)"

printf '%s\n' "${ray_registry_output}" | grep -q "MODEL REGISTRY" \
  && e2e_ok "ray registry banner visible" \
  || e2e_error "ray registry banner missing"

printf '%s\n' "${ray_registry_output}" | grep -q "mistral | mistral-medium-latest | family cloud | base 80" \
  && e2e_ok "ray registry mistral entry visible" \
  || e2e_error "ray registry mistral entry missing"

printf '%s\n' "${ray_registry_output}" | grep -q "ollama | llama3.2 | family local | base 40" \
  && e2e_ok "ray registry ollama entry visible" \
  || e2e_error "ray registry ollama entry missing"

ray_default_output="$(
  /home/kao/bin/ray 2>&1
)"

printf '%s\n' "${ray_default_output}" | grep -q "RAY STATUS" \
  && e2e_ok "ray default command visible" \
  || e2e_error "ray default command missing"

ray_help_output="$(
  /home/kao/bin/ray help 2>&1
)"

printf '%s\n' "${ray_help_output}" | grep -q 'USAGE: ray \[status|registry|run "<prompt>"\]' \
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

forced_local_status_output="$(
  KAO_GATEWAY_PROVIDER=ollama /home/kao/bin/ray status 2>&1
)"

printf '%s\n' "${forced_local_status_output}" | grep -q "decision state    : route-selected" \
  && e2e_ok "ray forced local decision state visible" \
  || e2e_error "ray forced local decision state missing"

printf '%s\n' "${forced_local_status_output}" | grep -q "route reason      : forced-provider-ollama" \
  && e2e_ok "ray forced local reason visible" \
  || e2e_error "ray forced local reason missing"

printf '%s\n' "${forced_local_status_output}" | grep -q "registry provider : ollama" \
  && e2e_ok "ray forced local registry provider visible" \
  || e2e_error "ray forced local registry provider missing"

printf '%s\n' "${forced_local_status_output}" | grep -q "registry family   : local" \
  && e2e_ok "ray forced local registry family visible" \
  || e2e_error "ray forced local registry family missing"

forced_mistral_status_output="$(
  KAO_GATEWAY_PROVIDER=mistral /home/kao/bin/ray status 2>&1
)"

printf '%s\n' "${forced_mistral_status_output}" | grep -q "decision state    : route-selected" \
  && e2e_ok "ray forced mistral decision state visible" \
  || e2e_error "ray forced mistral decision state missing"

printf '%s\n' "${forced_mistral_status_output}" | grep -q "route reason      : forced-provider-mistral" \
  && e2e_ok "ray forced mistral reason visible" \
  || e2e_error "ray forced mistral reason missing"

printf '%s\n' "${forced_mistral_status_output}" | grep -q "registry provider : mistral" \
  && e2e_ok "ray forced mistral registry provider visible" \
  || e2e_error "ray forced mistral registry provider missing"

printf '%s\n' "${forced_mistral_status_output}" | grep -q "registry family   : cloud" \
  && e2e_ok "ray forced mistral registry family visible" \
  || e2e_error "ray forced mistral registry family missing"

unsupported_forced_status_output="$(
  KAO_GATEWAY_PROVIDER=badvalue /home/kao/bin/ray status 2>&1
)"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "decision state    : blocked-unsupported-forcing" \
  && e2e_ok "ray unsupported forced decision state visible" \
  || e2e_error "ray unsupported forced decision state missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "selected route    : none" \
  && e2e_ok "ray unsupported forced selected route none visible" \
  || e2e_error "ray unsupported forced selected route none missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "selected provider : none" \
  && e2e_ok "ray unsupported forced selected provider none visible" \
  || e2e_error "ray unsupported forced selected provider none missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "mode              : degraded" \
  && e2e_ok "ray unsupported forced degraded mode visible" \
  || e2e_error "ray unsupported forced degraded mode missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "hybrid state      : hybrid-ready" \
  && e2e_ok "ray unsupported forced capacity still visible" \
  || e2e_error "ray unsupported forced capacity reading missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "forced raw value  : badvalue" \
  && e2e_ok "ray unsupported forced raw value visible" \
  || e2e_error "ray unsupported forced raw value missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "forced provider   : none" \
  && e2e_ok "ray unsupported forced normalized provider visible" \
  || e2e_error "ray unsupported forced normalized provider missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "forced state      : unsupported" \
  && e2e_ok "ray unsupported forced state visible" \
  || e2e_error "ray unsupported forced state missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "route reason      : unsupported-forced-provider" \
  && e2e_ok "ray unsupported forced reason visible" \
  || e2e_error "ray unsupported forced reason missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "registry provider : none" \
  && e2e_ok "ray unsupported forced registry provider none visible" \
  || e2e_error "ray unsupported forced registry provider none missing"

printf '%s\n' "${unsupported_forced_status_output}" | grep -q "registry family   : none" \
  && e2e_ok "ray unsupported forced registry family none visible" \
  || e2e_error "ray unsupported forced registry family none missing"

forced_local_output="$(
  KAO_GATEWAY_PROVIDER=ollama /home/kao/bin/ray run "ray forced local test" 2>&1
)"

printf '%s\n' "${forced_local_output}" | grep -q "gateway -> ollama local" \
  && e2e_ok "ray forced local route visible" \
  || e2e_error "ray forced local route missing"

}
