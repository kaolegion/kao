#!/usr/bin/env bash
set -Eeuo pipefail

KROOT="${HOME}"

mkdir -p \
  "${KROOT}"/{bin,bootstrap,config,cockpit,brain,workspace,log,state,runtime,profiles,run,prod} \
  "${KROOT}"/state/sprints \
  "${KROOT}"/workspace/{costumes,conciergerie,event,software,bar,perso}

[ -f "${HOME}/.bashrc" ] || touch "${HOME}/.bashrc"

if ! grep -q 'KAO PATH' "${HOME}/.bashrc" 2>/dev/null; then
  cat >> "${HOME}/.bashrc" <<'BASHRC'

# KAO PATH
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi
BASHRC
fi

printf 'KROOT=%s\n' "${KROOT}"
printf '[OK] canonical root ready\n'
