#!/usr/bin/env bash

source /home/kao/lib/router/router_cognitive_state.sh

echo "[TEST] local preferred when available"
out=$(kao_router_score_provider local 1 0 local)
echo "$out" | grep -q "^65"

echo "[TEST] cloud allowed fallback"
out=$(kao_router_score_provider cloud 0 1 cloud)
echo "$out" | grep -q "^35"

echo "[TEST] deterministic result"
a=$(kao_router_score_provider local 1 1 local)
b=$(kao_router_score_provider local 1 1 local)
[ "$a" = "$b" ]

echo "router scoring unit test OK"
