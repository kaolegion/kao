#!/usr/bin/env bash

execution_extract_directory_target() {

    prompt="$*"

    # cas simple : ouvre dossier X
    target="$(echo "${prompt}" \
        | sed -E 's/.*ouvre dossier[[:space:]]+//I')"

    target="$(echo "${target}" | tr -d '"')"

    echo "${target}"
}
