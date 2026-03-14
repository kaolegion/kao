#!/usr/bin/env bash
scenario_ray_system_inspect() {

[ -x /home/kao/bin/ray ] && e2e_ok "ray entrypoint executable for system inspect" || e2e_error "ray entrypoint missing for system inspect"
[ -f /home/kao/lib/system/local_paths_registry.sh ] && e2e_ok "local paths registry present" || e2e_error "local paths registry missing"
[ -f /home/kao/lib/system/system_inspector.sh ] && e2e_ok "system inspector present" || e2e_error "system inspector missing"

ray_system_inspect_output="$(
  /home/kao/bin/ray system inspect 2>&1
)"

printf '%s\n' "${ray_system_inspect_output}" | grep -q "LOCAL SYSTEM INSPECTION" \
  && e2e_ok "ray system inspect banner visible" \
  || e2e_error "ray system inspect banner missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -q "root path" \
  && e2e_ok "root path line visible" \
  || e2e_error "root path line missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -q "bin directory" \
  && e2e_ok "bin directory line visible" \
  || e2e_error "bin directory line missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -q "system libs" \
  && e2e_ok "system libs line visible" \
  || e2e_error "system libs line missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -q "runtime state" \
  && e2e_ok "runtime state line visible" \
  || e2e_error "runtime state line missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:[[:space:]]*OK" \
  && e2e_ok "root path state readable" \
  || e2e_error "root path state unreadable"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "system libs[[:space:]]*:[[:space:]]*OK" \
  && e2e_ok "system libs state readable" \
  || e2e_error "system libs state unreadable"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:[[:space:]]*(OK|MISSING|TYPE-MISMATCH|UNREADABLE)" \
  && e2e_ok "agent registry state readable" \
  || e2e_error "agent registry state unreadable"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*owner[[:space:]]+[A-Za-z0-9_-]+:[A-Za-z0-9_-]+" \
  && e2e_ok "root path owner visible" \
  || e2e_error "root path owner missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*mode[[:space:]]+[0-9]{3,4}" \
  && e2e_ok "root path mode visible" \
  || e2e_error "root path mode missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*expected[[:space:]]+[A-Za-z0-9_-]+:[A-Za-z0-9_-]+[[:space:]]+[0-9]{3,4}" \
  && e2e_ok "root path expected metadata visible" \
  || e2e_error "root path expected metadata missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*drift[[:space:]]+OK" \
  && e2e_ok "root path drift state visible" \
  || e2e_error "root path drift state missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "system libs[[:space:]]*:.*drift[[:space:]]+DRIFT:(owner|group|mode|owner,group|owner,mode|group,mode|owner,group,mode)" \
  && e2e_ok "system libs drift signal visible" \
  || e2e_error "system libs drift signal missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*path[[:space:]]+/home/kao" \
  && e2e_ok "root path path visible" \
  || e2e_error "root path path missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*owner[[:space:]]+n/a:n/a" \
  && e2e_ok "missing path ownership fallback visible" \
  || e2e_error "missing path ownership fallback missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*mode[[:space:]]+n/a" \
  && e2e_ok "missing path mode fallback visible" \
  || e2e_error "missing path mode fallback missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*expected[[:space:]]+kao:kao[[:space:]]+750" \
  && e2e_ok "missing path expected metadata visible" \
  || e2e_error "missing path expected metadata missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*drift[[:space:]]+n/a" \
  && e2e_ok "missing path drift fallback visible" \
  || e2e_error "missing path drift fallback missing"

ray_system_repair_dry_run_output="$(
  /home/kao/bin/ray system repair --dry-run 2>&1
)"

printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -q "LOCAL SYSTEM REPAIR" \
  && e2e_ok "ray system repair dry-run banner visible" \
  || e2e_error "ray system repair dry-run banner missing"

printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "root path[[:space:]]*: NOOP \| state OK \| drift OK \| path /home/kao" \
  && e2e_ok "repair dry-run noop visible on aligned path" \
  || e2e_error "repair dry-run noop missing on aligned path"

printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "bin directory[[:space:]]*: DRY-RUN \| state OK \| drift DRIFT:mode \| APPLY\|owner=no\|group=no\|mode=would-fix" \
  && e2e_ok "repair dry-run mode-only action visible" \
  || e2e_error "repair dry-run mode-only action missing"

printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "system libs[[:space:]]*: DRY-RUN \| state OK \| drift DRIFT:(owner,group,mode|owner,mode,group|group,owner,mode|group,mode,owner|mode,owner,group|mode,group,owner) \| APPLY\|owner=would-fix\|group=would-fix\|mode=would-fix" \
  && e2e_ok "repair dry-run full metadata action visible" \
  || e2e_error "repair dry-run full metadata action missing"

printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "agent registry[[:space:]]*: SKIP \| state MISSING \| drift n/a \| reason non-repairable-state \| path /home/kao/lib/agents" \
  && e2e_ok "repair dry-run missing path skip visible" \
  || e2e_error "repair dry-run missing path skip missing"

ray_system_repair_bad_option_output="$(
  /home/kao/bin/ray system repair --bad-option 2>&1 || true
)"

printf '%s\n' "${ray_system_repair_bad_option_output}" | grep -q "RAY_ERROR unknown system repair option: --bad-option" \
  && e2e_ok "repair option guard visible" \
  || e2e_error "repair option guard missing"

printf 'OK ray_system_inspect\n'
}
