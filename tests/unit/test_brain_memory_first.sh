#!/usr/bin/env bash
set -e

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p \
  "${TMP_DIR}/bin" \
  "${TMP_DIR}/lib/gateway" \
  "${TMP_DIR}/lib/router" \
  "${TMP_DIR}/lib/agents" \
  "${TMP_DIR}/lib/cognition"

cp /home/kao/bin/brain "${TMP_DIR}/bin/brain"
chmod +x "${TMP_DIR}/bin/brain"

cat <<'LIB_GATEWAY' > "${TMP_DIR}/lib/gateway/router.sh"
gateway_provider_select() {
  echo "ollama"
}

gateway_infer() {
  echo "GATEWAY_CALL:$*"
}
LIB_GATEWAY

cat <<'LIB_ROUTER' > "${TMP_DIR}/lib/router/router_core_contract.sh"
router_core_contract_build() {
  ROUTER_CORE_DECISION="gateway-llm"
}
LIB_ROUTER

cat <<'LIB_MISSION' > "${TMP_DIR}/lib/agents/mission_kernel.sh"
kao_agent_task_attach() { :; }
kao_mission_gate_handle() { return 1; }
LIB_MISSION

cat <<'LIB_SELF' > "${TMP_DIR}/lib/cognition/kao_self_loop.sh"
kao_self_can_answer() {
  echo "$*" | grep -qiE 'qui es[- ]?tu|tu es la|quel est ton état actuel'
}

kao_self_answer() {
  echo "SELF:$*"
}

kao_self_llm_context_build() {
  echo "CTX:"
}

kao_organs_flow_run() {
  if kao_self_can_answer "$@"; then
    echo "decision=self-answer"
  else
    echo "decision=delegate"
  fi
}
LIB_SELF

out="$(cd "${TMP_DIR}" && ./bin/brain infer "tu es la ?")"
printf '%s\n' "${out}" | grep -q '^SELF:tu es la ?$'
if printf '%s\n' "${out}" | grep -q 'GATEWAY_CALL:'; then
  echo "FAIL gateway should not be called for self-answer"
  exit 1
fi

out="$(cd "${TMP_DIR}" && ./bin/brain infer "résume ce document complexe")"
printf '%s\n' "${out}" | grep -q "Je reste l’instance souveraine de réponse."
printf '%s\n' "${out}" | grep -q "Etat courant : route locale via Ollama."
if printf '%s\n' "${out}" | grep -q 'GATEWAY_CALL:'; then
  echo "FAIL raw gateway output should not leak in final operator surface"
  exit 1
fi

echo "brain memory-first unit test OK"
