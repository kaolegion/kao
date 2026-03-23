kao_capsule_dir() {
  printf '%s/state/brain/learning_capsules' "${KROOT:-/home/kao}"
}

kao_capsule_answer_useful() {
  local a="$*"

  echo "${a}" | grep -qi "ollama-stub" && return 1
  echo "${a}" | grep -qi "not configured" && return 1
  echo "${a}" | grep -qi "model state" && return 1

  [ "${#a}" -lt 40 ] && return 1

  return 0
}

kao_capsule_lookup() {
  local raw="$*"
  local query dir file stored normalized_stored

  query="$(kao_self_normalize "${raw}")"
  dir="$(kao_capsule_dir)"

  [ -d "${dir}" ] || return 1

  for file in "${dir}"/*.capsule; do
    [ -f "${file}" ] || continue

    stored="$(grep '^query=' "${file}" | head -n1 | cut -d= -f2-)"
    normalized_stored="$(kao_self_normalize "${stored}")"

    if [ "${normalized_stored}" = "${query}" ]; then
      sed -n '/^answer=/,$p' "${file}" | sed '1s/^answer=//'
      return 0
    fi
  done

  return 1
}

kao_capsule_write() {
  local query="$1"
  local provider="$2"
  local answer="$3"
  local dir id file ts

  kao_capsule_answer_useful "${answer}" || return 0

  dir="$(kao_capsule_dir)"
  mkdir -p "${dir}"

  id="$(date +%s)"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  file="${dir}/${id}.capsule"

  cat > "${file}" <<CAPS
id=${id}
query=${query}
topic=runtime
source_type=provider
source_provider=${provider}
confidence=medium
status=learned
ts=${ts}
answer=${answer}
CAPS
}
