#!/usr/bin/env bash

kao_ksl_color_code() {
  local domain="$1"

  case "$domain" in
    SYS) echo "34" ;;
    NET) echo "36" ;;
    RSN) echo "33" ;;
    MEM) echo "35" ;;
    ACT) echo "32" ;;
    ALT) echo "31" ;;
    *)   echo "37" ;;
  esac
}

kao_ksl_render_ascii() {
  local signal="$1"
  printf "KSL::%s\n" "$signal"
}

kao_ksl_render_ansi() {
  local signal="$1"
  local body="${signal#KSL::}"
  local domain
  local color

  domain="$(printf "%s" "$body" | cut -d'/' -f2)"
  color="$(kao_ksl_color_code "$domain")"

  printf "\033[%sm%s\033[0m\n" "$color" "$signal"
}
