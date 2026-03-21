#!/usr/bin/env bash

e2e_ok() {
  echo "[OK] $*"
}

e2e_warn() {
  echo "[WARN] $*"
}

e2e_error() {
  echo "[ERROR] $*"
}
