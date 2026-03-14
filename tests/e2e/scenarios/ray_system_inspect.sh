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

printf 'OK ray_system_inspect\n'
}
