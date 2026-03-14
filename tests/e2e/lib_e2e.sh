#!/usr/bin/env bash

E2E_SCORE=100
E2E_ERRORS=0
E2E_WARN=0
E2E_LOG_DIR="/home/kao/state/e2e"
E2E_SESSION="$(date +%Y%m%d-%H%M%S)"
E2E_LOG="$E2E_LOG_DIR/session-$E2E_SESSION.log"

e2e_init() {
  mkdir -p "$E2E_LOG_DIR"
  touch "$E2E_LOG"
  echo "[E2E] session start $E2E_SESSION" | tee -a "$E2E_LOG"
}

e2e_ok() {
  echo "[OK] $1" | tee -a "$E2E_LOG"
}

e2e_warn() {
  E2E_WARN=$((E2E_WARN+1))
  E2E_SCORE=$((E2E_SCORE-5))
  echo "[WARN] $1" | tee -a "$E2E_LOG"
}

e2e_error() {
  E2E_ERRORS=$((E2E_ERRORS+1))
  E2E_SCORE=$((E2E_SCORE-10))
  echo "[ERROR] $1" | tee -a "$E2E_LOG"
}

e2e_section() {
  echo "" | tee -a "$E2E_LOG"
  echo "=== $1 ===" | tee -a "$E2E_LOG"
}

assert_file_exists() {
  local path="$1"
  local message="$2"

  if [ -f "$path" ]; then
    e2e_ok "$message"
  else
    e2e_error "$message"
    echo "missing file: $path" | tee -a "$E2E_LOG"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="$3"

  if printf '%s' "$haystack" | grep -Fq "$needle"; then
    e2e_ok "$message"
  else
    e2e_error "$message"
    echo "missing content: $needle" | tee -a "$E2E_LOG"
  fi
}

assert_equals() {
  local actual="$1"
  local expected="$2"
  local message="$3"

  if [ "$actual" = "$expected" ]; then
    e2e_ok "$message"
  else
    e2e_error "$message"
    echo "expected=$expected actual=$actual" | tee -a "$E2E_LOG"
  fi
}

e2e_finalize() {
  echo "-----" | tee -a "$E2E_LOG"
  echo "score=$E2E_SCORE" | tee -a "$E2E_LOG"
  echo "warn=$E2E_WARN" | tee -a "$E2E_LOG"
  echo "errors=$E2E_ERRORS" | tee -a "$E2E_LOG"
}
