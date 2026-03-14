#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
SESSION_DIR="${KROOT}/state/sessions"

kao_snapshot_now() {
  date -u +"%Y%m%d-%H%M%S"
}

kao_snapshot_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kao_snapshot_require_paths() {
  mkdir -p "${RUNTIME_DIR}" "${SESSION_DIR}"
}

kao_snapshot_id() {
  printf "runtime-%s-%s" "$(kao_snapshot_now)" "$RANDOM"
}

kao_snapshot_manifest_write() {
  local snapdir="$1"

  {
    echo "FORMAT_VERSION=1"
    echo "CREATED_AT=$(kao_snapshot_now_utc)"
    echo "HOST=$(hostname)"
    echo "SOURCE=runtime"
    echo "FILES_BEGIN"

    find "${snapdir}" -maxdepth 1 -type f -name '*.data' | sort | while read -r f; do
      sha256sum "${f}"
    done

    echo "FILES_END"
  } > "${snapdir}/manifest.env"
}

kao_snapshot_copy_if_exists() {
  local source_file="$1"
  local target_file="$2"

  if [ -f "${source_file}" ]; then
    cp "${source_file}" "${target_file}"
  fi
}

kao_snapshot_create() {
  local id snapdir

  kao_snapshot_require_paths

  id="$(kao_snapshot_id)"
  snapdir="${SESSION_DIR}/${id}"

  mkdir -p "${snapdir}"

  kao_snapshot_copy_if_exists "${RUNTIME_DIR}/runtime.snapshot" "${snapdir}/runtime.snapshot.data"
  kao_snapshot_copy_if_exists "${RUNTIME_DIR}/runtime.state" "${snapdir}/runtime.state.data"
  kao_snapshot_copy_if_exists "${RUNTIME_DIR}/session.history" "${snapdir}/session.history.data"
  kao_snapshot_copy_if_exists "${RUNTIME_DIR}/session.timeline" "${snapdir}/session.timeline.data"

  kao_snapshot_manifest_write "${snapdir}"

  printf 'SNAPSHOT CREATED : %s\n' "${id}"
}

kao_snapshot_list() {
  kao_snapshot_require_paths
  find "${SESSION_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | grep '^runtime-' || true
}

kao_snapshot_restore_file_if_exists() {
  local source_file="$1"
  local target_file="$2"

  if [ -f "${source_file}" ]; then
    cp "${source_file}" "${target_file}"
  fi
}

kao_snapshot_restore() {
  local id="$1"
  local snapdir="${SESSION_DIR}/${id}"

  kao_snapshot_require_paths

  if [ ! -d "${snapdir}" ]; then
    printf 'ERROR: snapshot not found: %s\n' "${id}" >&2
    return 1
  fi

  kao_snapshot_restore_file_if_exists "${snapdir}/runtime.snapshot.data" "${RUNTIME_DIR}/runtime.snapshot"
  kao_snapshot_restore_file_if_exists "${snapdir}/runtime.state.data" "${RUNTIME_DIR}/runtime.state"
  kao_snapshot_restore_file_if_exists "${snapdir}/session.history.data" "${RUNTIME_DIR}/session.history"
  kao_snapshot_restore_file_if_exists "${snapdir}/session.timeline.data" "${RUNTIME_DIR}/session.timeline"

  printf 'SNAPSHOT RESTORED : %s\n' "${id}"
}

kao_snapshot_gc() {
  kao_snapshot_require_paths
  find "${SESSION_DIR}" -maxdepth 1 -type d -name 'runtime-*' -mtime +30 -exec rm -rf {} \;
}
