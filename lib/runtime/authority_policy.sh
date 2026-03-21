#!/usr/bin/env bash

# ==========================================================
# KAO AUTHORITY POLICY — CANON LOCAL FIRST
# source unique de vérité exécutable
# ==========================================================

kao_authority_mode="${KAO_AUTHORITY_MODE:-LOCAL_FIRST}"

kao_policy_local_allowed() {
    return 0
}

kao_policy_cloud_allowed() {
    # cloud autorisé seulement si explicitement permis
    if [ "${KAO_ALLOW_CLOUD:-0}" = "1" ]; then
        return 0
    fi
    return 1
}

kao_policy_prefer_local() {
    # règle centrale : toujours préférer local
    return 0
}

kao_policy_sync_hot_path() {
    # opérateur → réponse immédiate locale
    return 0
}

