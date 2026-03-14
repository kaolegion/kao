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

kao_local_paths_expected_metadata_list() {
  kao_local_paths_load

  cat <<EOF_PATHS
root path|dir|${KAO_ROOT}|kao|kao|750
bin directory|dir|${KAO_BIN_DIR}|kao|kao|750
library root|dir|${KAO_LIB_DIR}|kao|kao|750
cognition libs|dir|${KAO_LIB_COGNITION_DIR}|kao|kao|750
system libs|dir|${KAO_LIB_SYSTEM_DIR}|kao|kao|750
state directory|dir|${KAO_STATE_DIR}|kao|kao|750
logs directory|dir|${KAO_STATE_LOGS_DIR}|kao|kao|750
runtime state|dir|${KAO_STATE_RUNTIME_DIR}|kao|kao|750
e2e scenarios|dir|${KAO_TESTS_E2E_DIR}|kao|kao|750
agent registry|dir|${KAO_AGENT_REGISTRY_DIR}|kao|kao|750
EOF_PATHS
}
