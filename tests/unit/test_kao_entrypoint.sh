#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KAO_BIN="${ROOT_DIR}/bin/kao"

pass_count=0
fail_count=0

pass() {
    printf '[PASS] %s\n' "$1"
    pass_count=$((pass_count + 1))
}

fail() {
    printf '[FAIL] %s\n' "$1" >&2
    fail_count=$((fail_count + 1))
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local label="$3"

    if printf '%s' "${haystack}" | grep -Fq "${needle}"; then
        pass "${label}"
    else
        printf '--- output ---\n%s\n-------------\n' "${haystack}" >&2
        fail "${label}"
    fi
}

assert_exit_code() {
    local actual="$1"
    local expected="$2"
    local label="$3"

    if [ "${actual}" -eq "${expected}" ]; then
        pass "${label}"
    else
        printf 'expected=%s actual=%s\n' "${expected}" "${actual}" >&2
        fail "${label}"
    fi
}

test_bash_syntax() {
    bash -n "${KAO_BIN}"
    pass "bin/kao bash syntax valid"
}

test_empty_command() {
    local output
    output="$("${KAO_BIN}" 2>&1)"
    assert_contains "${output}" "KAO CLI" "empty command shows usage header"
    assert_contains "${output}" "kao status" "empty command shows usage example"
}

test_status_command() {
    local output
    output="$(timeout 8 "${KAO_BIN}" status 2>&1)"
    assert_contains "${output}" "ROLE    :" "kao status returns role line"
    assert_contains "${output}" "SCOPE   :" "kao status returns scope line"
}

test_unknown_command() {
    local output rc
    set +e
    output="$("${KAO_BIN}" does-not-exist 2>&1)"
    rc=$?
    set -e
    assert_exit_code "${rc}" 64 "unknown command returns exit 64"
    assert_contains "${output}" "unknown command 'does-not-exist'" "unknown command emits clear error"
}

test_recursion_failsafe() {
    local output rc
    set +e
    output="$(KAO_ENTRY_DEPTH=1 "${KAO_BIN}" status 2>&1)"
    rc=$?
    set -e
    assert_exit_code "${rc}" 70 "failsafe recursion returns exit 70"
    assert_contains "${output}" "recursion blocked" "failsafe recursion emits explicit message"
}

main() {
    test_bash_syntax
    test_empty_command
    test_status_command
    test_unknown_command
    test_recursion_failsafe

    printf '\n'
    printf 'unit_pass=%s\n' "${pass_count}"
    printf 'unit_fail=%s\n' "${fail_count}"

    if [ "${fail_count}" -ne 0 ]; then
        exit 1
    fi
}

main "$@"
