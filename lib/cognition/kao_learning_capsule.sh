kao_capsule_dir() {
  printf '%s/state/brain/learning_capsules' "${KROOT:-/home/kao}"
}

kao_capsule_last_hit_heat_file() {
  printf '%s/state/brain/.capsule_last_hit_heat\n' "${KROOT:-/home/kao}"
}

kao_capsule_last_hit_heat_clear() {
  rm -f "$(kao_capsule_last_hit_heat_file)"
}

kao_capsule_last_hit_heat_record() {
  local heat="$1"
  mkdir -p "${KROOT:-/home/kao}/state/brain"
  printf '%s\n' "${heat}" > "$(kao_capsule_last_hit_heat_file)"
}

kao_capsule_last_hit_heat() {
  local f
  f="$(kao_capsule_last_hit_heat_file)"
  [ -f "${f}" ] || return 1
  cat "${f}"
}

kao_capsule_answer_useful() {
  local a="$*"

  echo "${a}" | grep -qi "ollama-stub" && return 1
  echo "${a}" | grep -qi "not configured" && return 1
  echo "${a}" | grep -qi "model state" && return 1

  [ "${#a}" -lt 40 ] && return 1

  return 0
}

kao_capsule_heat_read() {
  local file="$1"
  local h

  h="$(grep '^heat=' "${file}" | head -n1 | cut -d= -f2 || true)"
  [ -n "${h}" ] || h=1
  printf '%s\n' "${h}"
}

kao_capsule_heat_increment() {
  local file="$1"
  local h

  h="$(grep '^heat=' "${file}" | head -n1 | cut -d= -f2 || true)"

  if [ -z "${h}" ]; then
    h=2
    echo "heat=${h}" >> "${file}"
  else
    h=$((h+1))
    sed -i "s/^heat=.*/heat=${h}/" "${file}"
  fi
}

kao_capsule_lookup() {
  local raw="$*"
  local query dir file stored normalized_stored heat_after answer_block

  query="$(kao_self_normalize "${raw}")"
  dir="$(kao_capsule_dir)"

  kao_capsule_last_hit_heat_clear
  [ -d "${dir}" ] || return 1

  for file in "${dir}"/*.capsule; do
    [ -f "${file}" ] || continue

    stored="$(grep '^query=' "${file}" | head -n1 | cut -d= -f2-)"
    normalized_stored="$(kao_self_normalize "${stored}")"

    if echo "${query}" | grep -qi "${normalized_stored}"; then
      kao_capsule_heat_increment "${file}"
      heat_after="$(kao_capsule_heat_read "${file}")"
      kao_capsule_last_hit_heat_record "${heat_after}"

      answer_block="$(sed -n '/^answer=/,$p' "${file}" | sed '1s/^answer=//')"
      printf '%s\n' "${answer_block}" | sed '/^heat=[0-9][0-9]*$/d'
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
heat=1
ts=${ts}
answer=${answer}
CAPS
}

kao_capsule_list() {
  local dir file
  dir="$(kao_capsule_dir)"
  [ -d "${dir}" ] || return 0
  for file in "${dir}"/*.capsule; do
    [ -f "${file}" ] || continue
    printf '%s\n' "${file}"
  done
}

