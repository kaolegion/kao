#!/usr/bin/env bash

kao_local_paths_load() {
  KAO_ROOT="/home/kao"
  KAO_BIN_DIR="${KAO_ROOT}/bin"
  KAO_LIB_DIR="${KAO_ROOT}/lib"
  KAO_LIB_COGNITION_DIR="${KAO_LIB_DIR}/cognition"
  KAO_LIB_SYSTEM_DIR="${KAO_LIB_DIR}/system"
  KAO_STATE_DIR="${KAO_ROOT}/state"
  KAO_STATE_LOGS_DIR="${KAO_STATE_DIR}/logs"
  KAO_STATE_RUNTIME_DIR="${KAO_STATE_DIR}/runtime"
  KAO_TESTS_E2E_DIR="${KAO_ROOT}/tests/e2e"
  KAO_AGENT_REGISTRY_DIR="${KAO_LIB_DIR}/agents"
}

kao_local_paths_list() {
  kao_local_paths_load

  cat <<EOF_PATHS
root path|dir|${KAO_ROOT}
bin directory|dir|${KAO_BIN_DIR}
library root|dir|${KAO_LIB_DIR}
cognition libs|dir|${KAO_LIB_COGNITION_DIR}
system libs|dir|${KAO_LIB_SYSTEM_DIR}
state directory|dir|${KAO_STATE_DIR}
logs directory|dir|${KAO_STATE_LOGS_DIR}
runtime state|dir|${KAO_STATE_RUNTIME_DIR}
e2e scenarios|dir|${KAO_TESTS_E2E_DIR}
agent registry|dir|${KAO_AGENT_REGISTRY_DIR}
EOF_PATHS
}
