#!/usr/bin/env bash

KROOT="${KROOT:-/home/kao}"
RUNTIME_DIR="${KROOT}/state/runtime"
RUNTIME_JOURNAL_FILE="${RUNTIME_DIR}/runtime.journal"
RUNTIME_SNAPSHOT_FILE="${RUNTIME_DIR}/runtime.snapshot"
RUNTIME_TIMELINE_FILE="${RUNTIME_DIR}/session.timeline"
RUNTIME_HEALTH_SNAPSHOT_FRESH_MAX_AGE="${RUNTIME_HEALTH_SNAPSHOT_FRESH_MAX_AGE:-21600}"

source "${KROOT}/lib/runtime/runtime_lock.sh"

kao_runtime_health_now_epoch() {
  date -u +%s
}

kao_runtime_health_require_paths() {
  mkdir -p "${RUNTIME_DIR}"
}

kao_runtime_health_file_mtime() {
  local file="${1:-}"
  [ -f "${file}" ] || return 1
  stat -c %Y "${file}"
}

kao_runtime_health_snapshot_status() {
  local now mtime age

  if [ ! -f "${RUNTIME_SNAPSHOT_FILE}" ]; then
    printf 'MISSING|snapshot file absent\n'
    return 0
  fi

  mtime="$(kao_runtime_health_file_mtime "${RUNTIME_SNAPSHOT_FILE}" 2>/dev/null || true)"
  if [ -z "${mtime}" ]; then
    printf 'UNKNOWN|snapshot mtime unreadable\n'
    return 0
  fi

  now="$(kao_runtime_health_now_epoch)"
  age="$((now - mtime))"

  if [ "${age}" -le "${RUNTIME_HEALTH_SNAPSHOT_FRESH_MAX_AGE}" ]; then
    printf 'FRESH|age_seconds=%s\n' "${age}"
  else
    printf 'STALE|age_seconds=%s\n' "${age}"
  fi
}

kao_runtime_health_runtime_writable_status() {
  local probe

  probe="${RUNTIME_DIR}/.health-write.$$"
  if : > "${probe}" 2>/dev/null; then
    rm -f "${probe}"
    printf 'OK|runtime directory writable\n'
  else
    printf 'FAIL|runtime directory not writable\n'
  fi
}

kao_runtime_health_lock_status() {
  local missing=0

  if ! kao_runtime_lock_is_held; then
    printf 'FREE|no active runtime lock\n'
    return 0
  fi

  if kao_runtime_lock_is_orphan; then
    printf 'ORPHAN|runtime lock orphan detected\n'
    return 0
  fi

  [ -f "${RUNTIME_LOCK_DIR}/pid" ] || missing=$((missing + 1))
  [ -f "${RUNTIME_LOCK_DIR}/state" ] || missing=$((missing + 1))
  [ -f "${RUNTIME_LOCK_DIR}/owner_kind" ] || missing=$((missing + 1))
  [ -f "${RUNTIME_LOCK_DIR}/owner_label" ] || missing=$((missing + 1))
  [ -f "${RUNTIME_LOCK_DIR}/command" ] || missing=$((missing + 1))

  if [ "${missing}" -gt 0 ]; then
    printf 'BROKEN|runtime lock metadata incomplete missing=%s\n' "${missing}"
    return 0
  fi

  printf 'ACTIVE|runtime lock held with valid metadata\n'
}

kao_runtime_health_journal_status() {
  local malformed=0 line_count=0 line

  if [ ! -f "${RUNTIME_JOURNAL_FILE}" ]; then
    printf 'CLEAN|journal absent\n'
    return 0
  fi

  if [ ! -s "${RUNTIME_JOURNAL_FILE}" ]; then
    printf 'CLEAN|journal empty\n'
    return 0
  fi

  while IFS= read -r line; do
    [ -n "${line}" ] || continue
    line_count=$((line_count + 1))

    case "${line}" in
      ????-??-??T??:??:??Z'|'*)
        ;;
      *)
        malformed=$((malformed + 1))
        ;;
    esac
  done < "${RUNTIME_JOURNAL_FILE}"

  if [ "${malformed}" -gt 0 ]; then
    printf 'DRIFT|malformed_lines=%s total_lines=%s\n' "${malformed}" "${line_count}"
  else
    printf 'CLEAN|validated_lines=%s\n' "${line_count}"
  fi
}

kao_runtime_health_timeline_status() {
  if [ ! -f "${RUNTIME_TIMELINE_FILE}" ]; then
    printf 'MISSING|timeline file absent\n'
    return 0
  fi

  if [ ! -s "${RUNTIME_TIMELINE_FILE}" ]; then
    printf 'IDLE|timeline file empty\n'
    return 0
  fi

  printf 'ACTIVE|timeline present and non-empty\n'
}

kao_runtime_health_compute() {
  local snapshot_raw writable_raw lock_raw journal_raw timeline_raw
  local snapshot_state snapshot_detail
  local writable_state writable_detail
  local lock_state lock_detail
  local journal_state journal_detail
  local timeline_state timeline_detail
  local level="STRONG"

  kao_runtime_health_require_paths

  snapshot_raw="$(kao_runtime_health_snapshot_status)"
  writable_raw="$(kao_runtime_health_runtime_writable_status)"
  lock_raw="$(kao_runtime_health_lock_status)"
  journal_raw="$(kao_runtime_health_journal_status)"
  timeline_raw="$(kao_runtime_health_timeline_status)"

  snapshot_state="${snapshot_raw%%|*}"
  snapshot_detail="${snapshot_raw#*|}"

  writable_state="${writable_raw%%|*}"
  writable_detail="${writable_raw#*|}"

  lock_state="${lock_raw%%|*}"
  lock_detail="${lock_raw#*|}"

  journal_state="${journal_raw%%|*}"
  journal_detail="${journal_raw#*|}"

  timeline_state="${timeline_raw%%|*}"
  timeline_detail="${timeline_raw#*|}"

  case "${writable_state}" in
    FAIL) level="CRITICAL" ;;
  esac

  case "${lock_state}" in
    ORPHAN|BROKEN) level="CRITICAL" ;;
  esac

  if [ "${level}" != "CRITICAL" ]; then
    case "${snapshot_state}" in
      STALE|MISSING|UNKNOWN) level="DEGRADED" ;;
    esac

    case "${journal_state}" in
      DRIFT) level="DEGRADED" ;;
    esac

    case "${timeline_state}" in
      MISSING|IDLE) level="DEGRADED" ;;
    esac
  fi

  KAO_RUNTIME_HEALTH_LEVEL="${level}"
  KAO_RUNTIME_HEALTH_SNAPSHOT_STATE="${snapshot_state}"
  KAO_RUNTIME_HEALTH_SNAPSHOT_DETAIL="${snapshot_detail}"
  KAO_RUNTIME_HEALTH_WRITABLE_STATE="${writable_state}"
  KAO_RUNTIME_HEALTH_WRITABLE_DETAIL="${writable_detail}"
  KAO_RUNTIME_HEALTH_LOCK_STATE="${lock_state}"
  KAO_RUNTIME_HEALTH_LOCK_DETAIL="${lock_detail}"
  KAO_RUNTIME_HEALTH_JOURNAL_STATE="${journal_state}"
  KAO_RUNTIME_HEALTH_JOURNAL_DETAIL="${journal_detail}"
  KAO_RUNTIME_HEALTH_TIMELINE_STATE="${timeline_state}"
  KAO_RUNTIME_HEALTH_TIMELINE_DETAIL="${timeline_detail}"
}

kao_runtime_health_status() {
  kao_runtime_health_compute

  printf 'RUNTIME HEALTH\n'
  printf 'level            : %s\n' "${KAO_RUNTIME_HEALTH_LEVEL}"
  printf 'snapshot         : %s | %s\n' "${KAO_RUNTIME_HEALTH_SNAPSHOT_STATE}" "${KAO_RUNTIME_HEALTH_SNAPSHOT_DETAIL}"
  printf 'runtime writable : %s | %s\n' "${KAO_RUNTIME_HEALTH_WRITABLE_STATE}" "${KAO_RUNTIME_HEALTH_WRITABLE_DETAIL}"
  printf 'tx lock          : %s | %s\n' "${KAO_RUNTIME_HEALTH_LOCK_STATE}" "${KAO_RUNTIME_HEALTH_LOCK_DETAIL}"
  printf 'journal          : %s | %s\n' "${KAO_RUNTIME_HEALTH_JOURNAL_STATE}" "${KAO_RUNTIME_HEALTH_JOURNAL_DETAIL}"
  printf 'timeline         : %s | %s\n' "${KAO_RUNTIME_HEALTH_TIMELINE_STATE}" "${KAO_RUNTIME_HEALTH_TIMELINE_DETAIL}"
}

kao_runtime_health_env() {
  kao_runtime_health_compute

  printf 'HEALTH_LEVEL=%s\n' "${KAO_RUNTIME_HEALTH_LEVEL}"
  printf 'SNAPSHOT_STATE=%s\n' "${KAO_RUNTIME_HEALTH_SNAPSHOT_STATE}"
  printf 'SNAPSHOT_DETAIL=%s\n' "${KAO_RUNTIME_HEALTH_SNAPSHOT_DETAIL}"
  printf 'RUNTIME_WRITABLE_STATE=%s\n' "${KAO_RUNTIME_HEALTH_WRITABLE_STATE}"
  printf 'RUNTIME_WRITABLE_DETAIL=%s\n' "${KAO_RUNTIME_HEALTH_WRITABLE_DETAIL}"
  printf 'TX_LOCK_STATE=%s\n' "${KAO_RUNTIME_HEALTH_LOCK_STATE}"
  printf 'TX_LOCK_DETAIL=%s\n' "${KAO_RUNTIME_HEALTH_LOCK_DETAIL}"
  printf 'JOURNAL_STATE=%s\n' "${KAO_RUNTIME_HEALTH_JOURNAL_STATE}"
  printf 'JOURNAL_DETAIL=%s\n' "${KAO_RUNTIME_HEALTH_JOURNAL_DETAIL}"
  printf 'TIMELINE_STATE=%s\n' "${KAO_RUNTIME_HEALTH_TIMELINE_STATE}"
  printf 'TIMELINE_DETAIL=%s\n' "${KAO_RUNTIME_HEALTH_TIMELINE_DETAIL}"
}

kao_runtime_health_cli() {
  case "${1:-status}" in
    ""|status)
      kao_runtime_health_status
      ;;
    env)
      kao_runtime_health_env
      ;;
    *)
      printf 'ERROR: unknown health subcommand: %s\n' "${1:-}" >&2
      printf 'USAGE: runtime_health [status|env]\n' >&2
      return 1
      ;;
  esac
}
