#!/usr/bin/env bash
set -e

source /home/kao/lib/router/router_cognitive_state.sh

echo "[E2E] scenario local available"
out="$(kao_router_score_provider local 1 0 local)"
printf '%s\n' "${out}"
printf '%s\n' "${out}" | grep -q "^65|"

echo "[E2E] scenario local unavailable cloud allowed"
out="$(kao_router_score_provider cloud 0 1 cloud)"
printf '%s\n' "${out}"
printf '%s\n' "${out}" | grep -q "^35|"

echo "[E2E] scenario cloud forbidden"
out="$(kao_router_score_provider cloud 0 0 cloud)"
printf '%s\n' "${out}"
printf '%s\n' "${out}" | grep -q "^15|"

echo "E2E scoring matrix complete"
