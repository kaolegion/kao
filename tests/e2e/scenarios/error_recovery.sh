#!/usr/bin/env bash
scenario_error_recovery() {

TMP="/tmp/kao-e2e.$$"

if [ -f "$TMP" ]; then rm "$TMP"; fi

[ -f "$TMP" ] && e2e_error "tmp should not exist" || e2e_ok "missing resource detected"

echo "recover" > "$TMP"

[ -f "$TMP" ] && e2e_ok "recovery ok" || e2e_error "recovery failed"

rm "$TMP"

}
