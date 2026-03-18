#!/usr/bin/env bash

KAO_ROOT="/home/kao"
DOC_MAIN="$KAO_ROOT/docs/KAO_MAIN_SOURCE.md"

kao_doctrine_show() {
    if [ -f "$DOC_MAIN" ]; then
        clear
        echo "KAO DOCTRINE — MAIN SOURCE"
        echo "--------------------------------"
        sed -n '1,120p' "$DOC_MAIN"
        echo
        echo "(use editor to read full doctrine)"
    else
        echo "Doctrine not found."
    fi
}
