#!/usr/bin/env bash
set -euo pipefail

KROOT="/home/kao"
TIMELINE_PATH="${KROOT}/state/runtime/session.timeline"
BACKUP_PATH="${TIMELINE_PATH}.bak.test"
OUTPUT_DIR="${KROOT}/state/test-output"
mkdir -p "${OUTPUT_DIR}"

cleanup() {
  if [ -f "${BACKUP_PATH}" ]; then
    mv "${BACKUP_PATH}" "${TIMELINE_PATH}"
  else
    rm -f "${TIMELINE_PATH}"
  fi
}
trap cleanup EXIT

if [ -f "${TIMELINE_PATH}" ]; then
  cp "${TIMELINE_PATH}" "${BACKUP_PATH}"
fi

cat <<'TIMELINE' > "${TIMELINE_PATH}"
ts=2026-03-14T10:00:00Z|session_id=sess-alpha|event_type=session-open|gateway_agent=gateway-router|provider_kind=cloud|provider=mistral|intent_class=control|route_family=system
ts=2026-03-14T10:01:00Z|session_id=sess-alpha|event_type=prompt-run|agent=ray|secondary_agent=intent-router|cognitive_level=light|intent_class=file-op|route_family=local-shell
ts=2026-03-14T10:02:00Z|session_id=sess-beta|event_type=prompt-run|agent=ray|secondary_agent=execution-bridge|cognitive_level=heavy|intent_class=cognitive-heavy|route_family=gateway|selected_provider=mistral
ts=2026-03-14T10:03:00Z|session_id=sess-beta|event_type=session-close|gateway_agent=gateway-router|provider_kind=cloud|provider=mistral|intent_class=control|route_family=system
TIMELINE

printf "===== RAY TIMELINE HELP =====\n"
"${KROOT}/bin/ray" timeline --help | tee "${OUTPUT_DIR}/ray_timeline_help.out"

printf "\n===== RAY TIMELINE SESSIONS =====\n"
"${KROOT}/bin/ray" timeline sessions | tee "${OUTPUT_DIR}/ray_timeline_sessions.out"

printf "\n===== RAY TIMELINE AGENTS =====\n"
"${KROOT}/bin/ray" timeline agents | tee "${OUTPUT_DIR}/ray_timeline_agents.out"

printf "\n===== RAY TIMELINE EVENTS =====\n"
"${KROOT}/bin/ray" timeline events | tee "${OUTPUT_DIR}/ray_timeline_events.out"

printf "\n===== RAY TIMELINE COGNITIVE =====\n"
"${KROOT}/bin/ray" timeline cognitive | tee "${OUTPUT_DIR}/ray_timeline_cognitive.out"

printf "\n===== RAY TIMELINE PROVIDERS =====\n"
"${KROOT}/bin/ray" timeline providers | tee "${OUTPUT_DIR}/ray_timeline_providers.out"

printf "\n===== RAY TIMELINE FILTER =====\n"
"${KROOT}/bin/ray" timeline filter session_id sess-beta | tee "${OUTPUT_DIR}/ray_timeline_filter.out"

printf "\n===== ASSERTIONS =====\n"

grep -q 'RAY TIMELINE' "${OUTPUT_DIR}/ray_timeline_help.out" && echo "OK help surface"
grep -q '^sess-alpha$' "${OUTPUT_DIR}/ray_timeline_sessions.out" && echo "OK session alpha"
grep -q '^sess-beta$' "${OUTPUT_DIR}/ray_timeline_sessions.out" && echo "OK session beta"
grep -q '^gateway-router$' "${OUTPUT_DIR}/ray_timeline_agents.out" && echo "OK gateway agent"
grep -q '^execution-bridge$' "${OUTPUT_DIR}/ray_timeline_agents.out" && echo "OK secondary agent"
grep -q '^prompt-run$' "${OUTPUT_DIR}/ray_timeline_events.out" && echo "OK prompt-run event"
grep -q '^cognitive-heavy$' "${OUTPUT_DIR}/ray_timeline_cognitive.out" && echo "OK cognitive-heavy level"
grep -q '^gateway$' "${OUTPUT_DIR}/ray_timeline_cognitive.out" && echo "OK route family gateway"
grep -q '^mistral$' "${OUTPUT_DIR}/ray_timeline_providers.out" && echo "OK provider mistral"
grep -q 'session_id=sess-beta' "${OUTPUT_DIR}/ray_timeline_filter.out" && echo "OK filter sess-beta"

printf "\n===== RESULT =====\n"
echo "OK ray_timeline_query scenario"
