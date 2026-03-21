#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BRAIN_BIN="${ROOT_DIR}/bin/brain"

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

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local label="$3"

    if printf '%s' "${haystack}" | grep -Fq "${needle}"; then
        printf '--- output ---\n%s\n-------------\n' "${haystack}" >&2
        fail "${label}"
    else
        pass "${label}"
    fi
}

test_bypass_identity_prompt() {
    local output
    output="$("${BRAIN_BIN}" infer "tu es qui" 2>&1)"
    assert_contains "${output}" "Je suis Kao" "identity prompt still answered by sovereign self loop"
    assert_not_contains "${output}" "KAO MISSION GATE" "identity prompt bypasses mission gate"
}

test_open_document_prompt() {
    local output
    output="$("${BRAIN_BIN}" infer "prépare un cv" 2>&1)"
    assert_contains "${output}" "KAO MISSION GATE" "document prompt opens mission gate"
    assert_contains "${output}" "recon      : Rekon" "mission gate shows Rekon"
    assert_contains "${output}" "guard      : Sentinel" "mission gate shows Sentinel"
    assert_contains "${output}" "status     : awaiting-operator-validation" "mission gate shows awaiting validation"
}

test_ambiguous_prompt_bypasses() {
    local output
    output="$("${BRAIN_BIN}" infer "aide-moi avec mon projet" 2>&1)"
    assert_not_contains "${output}" "KAO MISSION GATE" "ambiguous prompt bypasses mission gate"
}

main() {
    test_bypass_identity_prompt
    test_open_document_prompt
    test_ambiguous_prompt_bypasses

    printf '\n'
    printf 'unit_pass=%s\n' "${pass_count}"
    printf 'unit_fail=%s\n' "${fail_count}"

    if [ "${fail_count}" -ne 0 ]; then
        exit 1
    fi
}

main "$@"
