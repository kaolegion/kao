#!/usr/bin/env bash
set -euo pipefail

pass=0
fail=0

ok(){ echo "[PASS] $1"; pass=$((pass+1)); }
ko(){ echo "[FAIL] $1"; fail=$((fail+1)); }

# mock gateway
gateway_infer(){
  echo "GATEWAY_CALLED"
}

# mock self loop
kao_self_can_answer(){
  [[ "$1" =~ qui ]]
}

kao_self_answer(){
  echo "Je suis Kao."
}

brain_hot_path_handle(){
  local q="$1"
  if kao_self_can_answer "$q"; then
    kao_self_answer "$q"
    return 0
  fi
  return 1
}

# TEST 1
out="$(brain_hot_path_handle "tu es qui ?")"
[[ "$out" =~ Kao ]] && ok "hot path identity" || ko "hot path identity"

# TEST 2
out="$(brain_hot_path_handle "physique quantique")"
[[ -z "$out" ]] && ok "no hot path fallback" || ko "no hot path fallback"

echo
echo "unit_pass=$pass"
echo "unit_fail=$fail"

[[ $fail -eq 0 ]]
