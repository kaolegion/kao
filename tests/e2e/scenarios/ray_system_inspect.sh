#!/usr/bin/env bash
set -euo pipefail

scenario_ray_system_inspect() {
  # shellcheck disable=SC1091
  . /home/kao/tests/e2e/lib_e2e.sh

  e2e_init

  [ -x /home/kao/bin/ray ] && e2e_ok "ray entrypoint executable for system inspect" || e2e_error "ray entrypoint missing for system inspect"
  [ -f /home/kao/lib/system/local_paths_registry.sh ] && e2e_ok "local paths registry present" || e2e_error "local paths registry missing"
  [ -f /home/kao/lib/system/system_inspector.sh ] && e2e_ok "system inspector present" || e2e_error "system inspector missing"

  ORIGINAL_BIN_MODE="$(stat -c '%a' /home/kao/bin)"
  ORIGINAL_LIB_OWNER="$(stat -c '%U' /home/kao/lib)"
  ORIGINAL_LIB_GROUP="$(stat -c '%G' /home/kao/lib)"
  ORIGINAL_LIB_MODE="$(stat -c '%a' /home/kao/lib)"

  restore_baseline() {
    chmod "${ORIGINAL_BIN_MODE}" /home/kao/bin
    chown "${ORIGINAL_LIB_OWNER}" /home/kao/lib
    chgrp "${ORIGINAL_LIB_GROUP}" /home/kao/lib
    chmod "${ORIGINAL_LIB_MODE}" /home/kao/lib
  }

  trap restore_baseline EXIT

  chmod 755 /home/kao/bin
  chown root /home/kao/lib
  chgrp root /home/kao/lib
  chmod 755 /home/kao/lib

  ray_system_inspect_output="$(
    /home/kao/bin/ray system inspect 2>&1
  )"

  printf '%s\n' "${ray_system_inspect_output}" | grep -q "LOCAL SYSTEM INSPECTION" \
    && e2e_ok "ray system inspect banner visible" \
    || e2e_error "ray system inspect banner missing"

  printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "root path[[:space:]]*: OK \| owner kao:kao \| mode 750 \| expected kao:kao 750 \| drift OK \| path /home/kao" \
    && e2e_ok "root path aligned state visible" \
    || e2e_error "root path aligned state missing"

  printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "bin directory[[:space:]]*: OK \| owner kao:kao \| mode 755 \| expected kao:kao 750 \| drift DRIFT:mode \| path /home/kao/bin" \
    && e2e_ok "bin directory drift visible" \
    || e2e_error "bin directory drift missing"

  printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "library root[[:space:]]*: OK \| owner root:root \| mode 755 \| expected kao:kao 750 \| drift DRIFT:(owner,group,mode|owner,mode,group|group,owner,mode|group,mode,owner|mode,owner,group|mode,group,owner) \| path /home/kao/lib" \
    && e2e_ok "library root full drift visible" \
    || e2e_error "library root full drift missing"

  printf '%s\n' "${ray_system_inspect_output}" | grep -Eq "agent registry[[:space:]]*: MISSING \| owner n/a:n/a \| mode n/a \| expected kao:kao 750 \| drift n/a \| path /home/kao/lib/agents" \
    && e2e_ok "missing path is visible as non-repairable inventory" \
    || e2e_error "missing path visibility missing"

  ray_system_repair_dry_run_output="$(
    /home/kao/bin/ray system repair --dry-run 2>&1
  )"

  printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -q "LOCAL SYSTEM REPAIR" \
    && e2e_ok "ray system repair dry-run banner visible" \
    || e2e_error "ray system repair dry-run banner missing"

  printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "root path[[:space:]]*: NOOP \| state OK \| drift OK \| path /home/kao" \
    && e2e_ok "repair dry-run noop visible on aligned path" \
    || e2e_error "repair dry-run noop missing on aligned path"

  printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "bin directory[[:space:]]*: DRY-RUN \| state OK \| drift DRIFT:mode \| APPLY\|owner=no\|group=no\|mode=would-fix \| expected kao:kao 750 \| current kao:kao 755 \| post-drift DRIFT:mode \| path /home/kao/bin" \
    && e2e_ok "repair dry-run mode-only action visible" \
    || e2e_error "repair dry-run mode-only action missing"

  printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "library root[[:space:]]*: DRY-RUN \| state OK \| drift DRIFT:(owner,group,mode|owner,mode,group|group,owner,mode|group,mode,owner|mode,owner,group|mode,group,owner) \| APPLY\|owner=would-fix\|group=would-fix\|mode=would-fix \| expected kao:kao 750 \| current root:root 755 \| post-drift DRIFT:(owner,group,mode|owner,mode,group|group,owner,mode|group,mode,owner|mode,owner,group|mode,group,owner) \| path /home/kao/lib" \
    && e2e_ok "repair dry-run full metadata action visible" \
    || e2e_error "repair dry-run full metadata action missing"

  printf '%s\n' "${ray_system_repair_dry_run_output}" | grep -Eq "agent registry[[:space:]]*: SKIP \| state MISSING \| drift n/a \| reason non-repairable-state \| path /home/kao/lib/agents" \
    && e2e_ok "repair dry-run missing path skip visible" \
    || e2e_error "repair dry-run missing path skip missing"

  ray_system_repair_output="$(
    /home/kao/bin/ray system repair 2>&1
  )"

  printf '%s\n' "${ray_system_repair_output}" | grep -q "LOCAL SYSTEM REPAIR" \
    && e2e_ok "ray system repair banner visible" \
    || e2e_error "ray system repair banner missing"

  printf '%s\n' "${ray_system_repair_output}" | grep -Eq "bin directory[[:space:]]*: REPAIRED \| state OK \| drift DRIFT:mode \| APPLY\|owner=no\|group=no\|mode=fixed \| expected kao:kao 750 \| current kao:kao 750 \| post-drift OK \| path /home/kao/bin" \
    && e2e_ok "real repair fixes mode-only drift" \
    || e2e_error "real repair mode-only result missing"

  printf '%s\n' "${ray_system_repair_output}" | grep -Eq "library root[[:space:]]*: REPAIRED \| state OK \| drift DRIFT:(owner,group,mode|owner,mode,group|group,owner,mode|group,mode,owner|mode,owner,group|mode,group,owner) \| APPLY\|owner=fixed\|group=fixed\|mode=fixed \| expected kao:kao 750 \| current kao:kao 750 \| post-drift OK \| path /home/kao/lib" \
    && e2e_ok "real repair fixes full metadata drift" \
    || e2e_error "real repair full metadata result missing"

  printf '%s\n' "${ray_system_repair_output}" | grep -Eq "agent registry[[:space:]]*: SKIP \| state MISSING \| drift n/a \| reason non-repairable-state \| path /home/kao/lib/agents" \
    && e2e_ok "real repair still skips missing path" \
    || e2e_error "real repair missing path skip missing"

  ray_system_post_repair_inspect_output="$(
    /home/kao/bin/ray system inspect 2>&1
  )"

  printf '%s\n' "${ray_system_post_repair_inspect_output}" | grep -Eq "bin directory[[:space:]]*: OK \| owner kao:kao \| mode 750 \| expected kao:kao 750 \| drift OK \| path /home/kao/bin" \
    && e2e_ok "post-repair inspect confirms bin directory alignment" \
    || e2e_error "post-repair bin directory alignment missing"

  printf '%s\n' "${ray_system_post_repair_inspect_output}" | grep -Eq "library root[[:space:]]*: OK \| owner kao:kao \| mode 750 \| expected kao:kao 750 \| drift OK \| path /home/kao/lib" \
    && e2e_ok "post-repair inspect confirms library root alignment" \
    || e2e_error "post-repair library root alignment missing"

  ray_system_repair_bad_option_output="$(
    /home/kao/bin/ray system repair --bad-option 2>&1 || true
  )"

  printf '%s\n' "${ray_system_repair_bad_option_output}" | grep -q "RAY_ERROR unknown system repair option: --bad-option" \
    && e2e_ok "repair option guard visible" \
    || e2e_error "repair option guard missing"

  printf 'OK ray_system_inspect\n'
  e2e_finalize
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  scenario_ray_system_inspect
fi
