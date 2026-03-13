#!/usr/bin/env bash
scenario_gateway_infer() {

[ -x /home/kao/bin/brain ] && e2e_ok "brain entrypoint executable" || e2e_error "brain entrypoint missing"
[ -x /home/kao/bin/kao ] && e2e_ok "kao entrypoint executable for gateway surface" || e2e_error "kao entrypoint missing for gateway surface"
[ -f /home/kao/lib/gateway/router.sh ] && e2e_ok "gateway router present" || e2e_error "gateway router missing"
[ -f /home/kao/lib/gateway/providers/mistral.sh ] && e2e_ok "mistral provider present" || e2e_error "mistral provider missing"
[ -f /home/kao/lib/gateway/providers/ollama.sh ] && e2e_ok "ollama provider present" || e2e_error "ollama provider missing"

gateway_status_output="$(
  /home/kao/bin/kao gateway status 2>&1
)"

printf '%s\n' "${gateway_status_output}" | grep -q "KAO GATEWAY STATUS" \
  && e2e_ok "canonical gateway status banner visible" \
  || e2e_error "canonical gateway status banner missing"

printf '%s\n' "${gateway_status_output}" | grep -q "selected provider :" \
  && e2e_ok "canonical gateway selected provider visible" \
  || e2e_error "canonical gateway selected provider missing"

printf '%s\n' "${gateway_status_output}" | grep -q "selected kind     :" \
  && e2e_ok "canonical gateway selected kind visible" \
  || e2e_error "canonical gateway selected kind missing"

printf '%s\n' "${gateway_status_output}" | grep -q "selected health   :" \
  && e2e_ok "canonical gateway selected health visible" \
  || e2e_error "canonical gateway selected health missing"

printf '%s\n' "${gateway_status_output}" | grep -q "mistral health    :" \
  && e2e_ok "canonical gateway mistral health visible" \
  || e2e_error "canonical gateway mistral health missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama kind       :" \
  && e2e_ok "canonical gateway ollama kind visible" \
  || e2e_error "canonical gateway ollama kind missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama health     :" \
  && e2e_ok "canonical gateway ollama health visible" \
  || e2e_error "canonical gateway ollama health missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "ollama health     : (local-stub-ready|local-real-backend-ready|local-real-ready|unavailable)" \
  && e2e_ok "canonical gateway progressive local readiness visible" \
  || e2e_error "canonical gateway progressive local readiness missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama model      :" \
  && e2e_ok "canonical gateway ollama model visible" \
  || e2e_error "canonical gateway ollama model missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama model state:" \
  && e2e_ok "canonical gateway ollama model state visible" \
  || e2e_error "canonical gateway ollama model state missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "ollama model state: (unknown|missing|ready)" \
  && e2e_ok "canonical gateway ollama model state readable" \
  || e2e_error "canonical gateway ollama model state value missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama runtime    :" \
  && e2e_ok "canonical gateway ollama runtime visible" \
  || e2e_error "canonical gateway ollama runtime missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "ollama runtime    : (stub-runtime|real-backend-ready|real-model-ready|unavailable)" \
  && e2e_ok "canonical gateway ollama runtime state readable" \
  || e2e_error "canonical gateway ollama runtime state value missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama real calls :" \
  && e2e_ok "canonical gateway ollama real calls policy visible" \
  || e2e_error "canonical gateway ollama real calls policy missing"

printf '%s\n' "${gateway_status_output}" | grep -q "ollama real state :" \
  && e2e_ok "canonical gateway ollama real state visible" \
  || e2e_error "canonical gateway ollama real state missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "ollama real calls : (enabled|disabled)" \
  && e2e_ok "canonical gateway ollama real calls policy state readable" \
  || e2e_error "canonical gateway ollama real calls policy state missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "ollama real state : (callable|blocked-policy|blocked-no-model|stub-only|unavailable)" \
  && e2e_ok "canonical gateway ollama real state readable" \
  || e2e_error "canonical gateway ollama real state value missing"

printf '%s\n' "${gateway_status_output}" | grep -q "secrets file      :" \
  && e2e_ok "canonical gateway secrets path visible" \
  || e2e_error "canonical gateway secrets path missing"

printf '%s\n' "${gateway_status_output}" | grep -q "log file          :" \
  && e2e_ok "canonical gateway log path visible" \
  || e2e_error "canonical gateway log path missing"

printf '%s\n' "${gateway_status_output}" | grep -q "log lines         :" \
  && e2e_ok "canonical gateway log lines visible" \
  || e2e_error "canonical gateway log lines missing"

printf '%s\n' "${gateway_status_output}" | grep -q "last log event    :" \
  && e2e_ok "canonical gateway last log event visible" \
  || e2e_error "canonical gateway last log event missing"

printf '%s\n' "${gateway_status_output}" | grep -q "fallback status   :" \
  && e2e_ok "canonical gateway fallback status visible" \
  || e2e_error "canonical gateway fallback status missing"

printf '%s\n' "${gateway_status_output}" | grep -Eq "fallback status   : (armed-via-ollama-stub|armed-via-ollama-backend-only|armed-via-ollama-real|fallback-unavailable)" \
  && e2e_ok "canonical gateway fallback status readable" \
  || e2e_error "canonical gateway fallback status value missing"

printf '%s\n' "${gateway_status_output}" | grep -q "diagnostic        :" \
  && e2e_ok "canonical gateway diagnostic visible" \
  || e2e_error "canonical gateway diagnostic missing"

printf '%s\n' "${gateway_status_output}" | grep -q "log preview       :" \
  && e2e_ok "canonical gateway log preview visible" \
  || e2e_error "canonical gateway log preview missing"

gateway_default_output="$(
  /home/kao/bin/kao gateway 2>&1
)"

printf '%s\n' "${gateway_default_output}" | grep -q "KAO GATEWAY STATUS" \
  && e2e_ok "canonical gateway default command visible" \
  || e2e_error "canonical gateway default command missing"

gateway_health_output="$(
  /home/kao/bin/kao gateway health 2>&1
)"

printf '%s\n' "${gateway_health_output}" | grep -q "KAO GATEWAY HEALTH" \
  && e2e_ok "canonical gateway health banner visible" \
  || e2e_error "canonical gateway health banner missing"

printf '%s\n' "${gateway_health_output}" | grep -q "selected health   :" \
  && e2e_ok "canonical gateway health selected health visible" \
  || e2e_error "canonical gateway health selected health missing"

printf '%s\n' "${gateway_health_output}" | grep -q "mistral health    :" \
  && e2e_ok "canonical gateway health mistral health visible" \
  || e2e_error "canonical gateway health mistral health missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama kind       :" \
  && e2e_ok "canonical gateway health ollama kind visible" \
  || e2e_error "canonical gateway health ollama kind missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama health     :" \
  && e2e_ok "canonical gateway health ollama health visible" \
  || e2e_error "canonical gateway health ollama health missing"

printf '%s\n' "${gateway_health_output}" | grep -Eq "ollama health     : (local-stub-ready|local-real-backend-ready|local-real-ready|unavailable)" \
  && e2e_ok "canonical gateway health progressive local readiness visible" \
  || e2e_error "canonical gateway health progressive local readiness missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama model      :" \
  && e2e_ok "canonical gateway health ollama model visible" \
  || e2e_error "canonical gateway health ollama model missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama model state:" \
  && e2e_ok "canonical gateway health ollama model state visible" \
  || e2e_error "canonical gateway health ollama model state missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama runtime    :" \
  && e2e_ok "canonical gateway health ollama runtime visible" \
  || e2e_error "canonical gateway health ollama runtime missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama real calls :" \
  && e2e_ok "canonical gateway health ollama real calls visible" \
  || e2e_error "canonical gateway health ollama real calls missing"

printf '%s\n' "${gateway_health_output}" | grep -q "ollama real state :" \
  && e2e_ok "canonical gateway health ollama real state visible" \
  || e2e_error "canonical gateway health ollama real state missing"

printf '%s\n' "${gateway_health_output}" | grep -q "fallback status   :" \
  && e2e_ok "canonical gateway health fallback status visible" \
  || e2e_error "canonical gateway health fallback status missing"

gateway_logs_before="$(
  bash -c 'if [ -f /home/kao/state/logs/gateway.log ]; then wc -l < /home/kao/state/logs/gateway.log | tr -d "[:space:]"; else printf "0\n"; fi'
)"

gateway_logs_output="$(
  /home/kao/bin/kao gateway logs 2>&1
)"

gateway_logs_after="$(
  bash -c 'if [ -f /home/kao/state/logs/gateway.log ]; then wc -l < /home/kao/state/logs/gateway.log | tr -d "[:space:]"; else printf "0\n"; fi'
)"

printf '%s\n' "${gateway_logs_output}" | grep -q "KAO GATEWAY LOGS" \
  && e2e_ok "canonical gateway logs banner visible" \
  || e2e_error "canonical gateway logs banner missing"

printf '%s\n' "${gateway_logs_output}" | grep -q "log file          :" \
  && e2e_ok "canonical gateway logs path visible" \
  || e2e_error "canonical gateway logs path missing"

printf '%s\n' "${gateway_logs_output}" | grep -q "log lines         :" \
  && e2e_ok "canonical gateway logs line count visible" \
  || e2e_error "canonical gateway logs line count missing"

printf '%s\n' "${gateway_logs_output}" | grep -q "last log event    :" \
  && e2e_ok "canonical gateway logs last event visible" \
  || e2e_error "canonical gateway logs last event missing"

printf '%s\n' "${gateway_logs_output}" | grep -q "preview           :" \
  && e2e_ok "canonical gateway logs preview visible" \
  || e2e_error "canonical gateway logs preview missing"

if [ "${gateway_logs_before}" = "${gateway_logs_after}" ]; then
  e2e_ok "gateway logs command does not pollute runtime log"
else
  e2e_error "gateway logs command polluted runtime log"
fi

gateway_help_output="$(
  /home/kao/bin/kao gateway help 2>&1
)"

printf '%s\n' "${gateway_help_output}" | grep -q "USAGE: kao gateway \[status|health|logs\]" \
  && e2e_ok "canonical gateway help visible" \
  || e2e_error "canonical gateway help missing"

forced_local_output="$(
  KAO_GATEWAY_PROVIDER=ollama /home/kao/bin/brain infer "gateway local test" 2>&1
)"

printf '%s\n' "${forced_local_output}" | grep -q "gateway -> ollama local" \
  && e2e_ok "forced local route visible" \
  || e2e_error "forced local route missing"

if printf '%s\n' "${forced_local_output}" | grep -q "\[ollama-stub\] local provider not configured yet"; then
  e2e_ok "ollama stub-only response visible"
elif printf '%s\n' "${forced_local_output}" | grep -q "\[ollama-stub\] local backend reachable but target model unavailable"; then
  e2e_ok "ollama backend-only response visible"
elif printf '%s\n' "${forced_local_output}" | grep -q "\[ollama-stub\] local backend reachable but real calls disabled"; then
  e2e_ok "ollama real backend detected with policy disabled visible"
elif printf '%s\n' "${forced_local_output}" | grep -q "OLLAMA_ERROR"; then
  e2e_error "forced local route returned ollama error"
else
  e2e_ok "forced local route returned callable local response"
fi

provider_detected="$(
  bash --noprofile --norc -c '. /home/kao/lib/gateway/router.sh; gateway_require_providers; gateway_provider_select'
)"

case "${provider_detected}" in
  mistral)
    e2e_ok "provider auto-detect selects mistral"
    ;;
  ollama)
    e2e_warn "provider auto-detect fell back to ollama"
    ;;
  none)
    e2e_warn "provider auto-detect found no provider"
    ;;
  *)
    e2e_error "provider auto-detect unexpected value"
    ;;
esac
}
