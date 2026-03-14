#!/usr/bin/env bash

kao_ksl_color_code() {
  local domain="$1"

  case "$domain" in
    SYS) echo "34" ;;
    NET) echo "36" ;;
    RSN) echo "33" ;;
    MEM) echo "35" ;;
    ACT) echo "32" ;;
    USR) echo "37" ;;
    TMP) echo "90" ;;
    ALT) echo "31" ;;
    *)   echo "37" ;;
  esac
}

kao_ksl_role_icon() {
  local role="$1"

  case "$role" in
    presence)  printf "prs" ;;
    context)   printf "ctx" ;;
    decision)  printf "dec" ;;
    execution) printf "exe" ;;
    memory)    printf "mem" ;;
    prediction) printf "prd" ;;
    state)     printf "stt" ;;
    *)         printf "unk" ;;
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

kao_ksl_render_hud_line() {
  local ts="$1"
  local layer="$2"
  local priority="$3"
  local event="$4"
  local signal="$5"
  local symbol="$6"
  local intensity="$7"
  local state="$8"
  local pattern="$9"
  local object="${10}"
  local role="${11}"
  local scope="${12}"
  local color
  local role_icon

  color="$(kao_ksl_color_code "$layer")"
  role_icon="$(kao_ksl_role_icon "$role")"

  printf "\033[%sm%-20s | %-3s | %-2s | %-18s | %-3s | %-8s | %-10s | %-9s | %-9s | %s\033[0m\n" \
    "$color" "$ts" "$layer" "$priority" "$event" "$role_icon" "$scope" "$state" "$pattern" "$intensity" "$signal"
}
