#!/usr/bin/env bash

# cognition locale utile minimale souveraine
# V0 volontairement infiniment petite

kao_local_can_think() {
    local q
    q="$(echo "${*:-}" | tr '[:upper:]' '[:lower:]')"

    case "${q}" in
        *tcp*slow*start*)
            return 0
            ;;
    esac

    return 1
}

kao_local_think() {
    local q
    q="$(echo "${*:-}" | tr '[:upper:]' '[:lower:]')"

    case "${q}" in
        *tcp*slow*start*)
            cat <<TXT
TCP slow start est un mécanisme de contrôle de congestion.
Lorsqu’une connexion débute, TCP augmente progressivement la quantité de données envoyées.
Il commence avec peu de paquets, puis double environ à chaque aller-retour réseau.
Cela permet d’explorer la capacité du réseau sans provoquer immédiatement de saturation.
TXT
            return 0
            ;;
    esac

    return 1
}
