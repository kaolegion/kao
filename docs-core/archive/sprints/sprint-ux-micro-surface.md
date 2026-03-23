# SPRINT — UX MICRO-SURFACE

## Objectif
Créer une surface terminal fondateur vivante permettant :
- perception immédiate du runtime
- diagnostic rapide
- supervision globale
- réduction de la charge mentale opérateur

## Capacités livrées
- HUD cognitif dans le prompt
- commande `kao pulse`
- commande `kao cockpit`
- intégration CLI principale
- stabilisation help
- nettoyage runtime et discipline repo

## Gains produits
- naissance de la console cognitive Kao
- perception système continue
- base cockpit futur
- première UX opérateur viable

## Limites identifiées
- cockpit trop verbeux
- état session encore flou
- message router legacy
- absence heat cognitive
- absence observation surface UI

## Prochaines évolutions
- cockpit synthétique V2
- session canonique
- router UX modernization
- affichage cognitive heat
- observation DOM / desktop
- layout terminal fondateur avancé

## memory-first response gate v1
- `bin/brain` now preserves a sovereign memory-first branch before provider arbitration
- `lib/cognition/kao_self_loop.sh` now answers natural operator prompts such as `tu es la ?` and `quel est ton état actuel ?`
- simple sovereign prompts now return local self answers without calling gateway
- cognitive/heavier prompts still fall back to gateway arbitration
- mission gate and router core regressions remain green
- added unit coverage at `tests/unit/test_brain_memory_first.sh`

## validated runtime proofs
- `bin/kao ask "tu es la ?"` -> `SELF_ANSWER`
- `bin/kao ask "quel est ton état actuel ?"` -> `SELF_ANSWER`
- `bin/kao ask "analyse cette architecture"` -> `LLM_ARBITRATION`

## next sprint candidate
- answer pipeline closure v1
