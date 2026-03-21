#!/usr/bin/env bash

source /home/kao/lib/router/router_cognitive_state.sh

echo "[E2E] scenario local available"
kao_router_score_provider local 1 0 local

echo "[E2E] scenario local unavailable cloud allowed"
kao_router_score_provider cloud 0 1 cloud

echo "[E2E] scenario cloud forbidden"
kao_router_score_provider cloud 0 0 cloud

echo "E2E scoring matrix complete"
