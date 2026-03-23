kao_self_ascii_fold() {
  iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null
}

kao_self_normalize() {
  printf '%s' "$*" \
  | kao_self_ascii_fold \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[[:punct:]]//g' \
  | tr -d '[:space:]'
}

kao_self_can_answer() {
  local q
  q="$(kao_self_normalize "$*")"

  case "$q" in
    *tuesla*|*presence*)
      return 0
      ;;
    *quiestu*|*tuesqui*)
      return 0
      ;;
    *etat*|*status*)
      return 0
      ;;
  esac

  return 1
}

kao_self_answer() {
  local q
  q="$(kao_self_normalize "$*")"

  case "$q" in
    *tuesla*|*presence*)
      echo "Oui."
      return 0
      ;;
    *quiestu*|*tuesqui*)
      echo "Je suis Kao. Le noyau cognitif souverain du système."
      return 0
      ;;
    *etat*|*status*)
      echo "Stable."
      return 0
      ;;
  esac

  return 1
}

kao_organs_runtime_journal() {
  local kroot="${KROOT:-/home/kao}"
  local journal="${kroot}/state/runtime/runtime.journal"
  local line="${1:-}"

  [ -n "${line}" ] || return 0
  mkdir -p "${kroot}/state/runtime"
  printf 'ORGAN_FLOW|ts=%s|%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${line}" >> "${journal}"
}

kao_organs_flow_run() {
  local query="${1:-}"
  local bloom rekon sentinel syfer kao

  bloom="signal=present"
  if [ -z "${query}" ]; then
    bloom="signal=empty"
  fi

  if kao_self_can_answer "${query}"; then
    rekon="self_loop=match"
    sentinel="risk=low"
    syfer="mutation=not-required"
    kao="decision=self-answer"
  else
    rekon="self_loop=miss"
    sentinel="risk=delegated"
    syfer="mutation=not-armed"
    kao="decision=delegate"
  fi

  kao_organs_runtime_journal \
    "bloom=${bloom}|rekon=${rekon}|sentinel=${sentinel}|syfer=${syfer}|kao=${kao}"

  printf '%s\n' "${kao}"
}
