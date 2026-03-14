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

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*:.*path[[:space:]]+/home/kao" \
  && e2e_ok "root path path visible" \
  || e2e_error "root path path missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*owner[[:space:]]+n/a:n/a" \
  && e2e_ok "missing path ownership fallback visible" \
  || e2e_error "missing path ownership fallback missing"

printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*:.*mode[[:space:]]+n/a" \
  && e2e_ok "missing path mode fallback visible" \
  || e2e_error "missing path mode fallback missing"

printf 'OK ray_system_inspect\n'
}
