# SPRINT 3.5 — Runtime user update / patch workflow and canonical metadata editing

## Mission
- introduire une commande canonique de mise à jour du runtime user
- permettre l’édition sélective et déterministe des métadonnées user
- distinguer clairement :
  - création de la source
  - inspection de la source
  - activation runtime
  - mise à jour / patch de la source
- éviter toute édition manuelle fragile de `config/user.env`
- permettre un patch atomique de champs individuels
- maintenir la policy runtime existante :
  - owner primaire
  - user secondaire activable
- introduire un modèle clair :
  - user source AVAILABLE
  - user source ACTIVE
  - user source UPDATED / MODIFIED_SINCE_ACTIVATION
  - user source INVALID
- permettre une réécriture canonique normalisée
- préparer la gouvernance future :
  - multi-user runtime
  - profils user enrichis
  - metadata cognitive layer
- maintenir la compatibilité totale avec :
  - boot observability
  - scénarios E2E existants
  - workflow inspect / create / remove

## Goal
Permettre à Kao de modifier proprement la source runtime user sans casser :
- la hiérarchie machine / system / owner / user
- la lisibilité terminal
- le déterminisme du login runtime

## Expected result
- `kao user patch FIELD VALUE` patch un champ canonique autorisé
- `kao user update FIELD=VALUE ...` applique plusieurs patches déterministes
- `kao user rewrite` réécrit la source dans un format canonique propre
- `kao user diff` compare la source courante avec le snapshot d’activation
- l’activation crée un snapshot runtime actif
- le boot expose clairement :
  - `USER SYNC MODE`
  - `USER SYNC HINT`
  - `USER DIFF COUNT`
- un patch post-activation rend l’état observable comme modifié depuis l’activation
- une réactivation resynchronise la source active et remet le diff à zéro

## Implemented
- extension de `/home/kao/lib/kao-user-state.sh`
  - snapshot actif : `config/user.active.snapshot.env`
  - log runtime user : `state/logs/user.log`
  - normalisation des champs autorisés
  - patch unitaire
  - update multi-champs
  - rewrite canonique
  - diff runtime vs snapshot
  - états de sync :
    - `CURRENT`
    - `MODIFIED_SINCE_ACTIVATION`
    - `NO_ACTIVE_SNAPSHOT`
    - `INVALID_SOURCE`
- extension de `/home/kao/bin/kao-user`
  - `patch`
  - `update`
  - `rewrite`
  - `diff`
- extension de `/home/kao/bin/kao-boot`
  - observabilité du snapshot actif
  - affichage du diff count
  - affichage du sync mode / sync hint
- nouveau scénario E2E :
  - `/home/kao/tests/e2e/scenarios/user_patch_flow.sh`
- extension de `/home/kao/tests/e2e/scenarios/boot_check.sh`
  - validation de `NO_ACTIVE_SNAPSHOT`
  - validation de `CURRENT`
  - validation de `MODIFIED_SINCE_ACTIVATION`
  - validation de `INVALID_SOURCE`
- intégration du scénario dans :
  - `/home/kao/tests/e2e/run_e2e.sh`

## Runtime model after sprint
- `INACTIVE`
  - aucune source active
  - owner primaire seul
- `AVAILABLE`
  - source user valide présente
  - activation non engagée
- `ACTIVE`
  - source user activée
  - snapshot actif présent
- `BROKEN`
  - source valide mais état runtime incohérent
- `INVALID`
  - source user invalide / illisible

## Sync model after sprint
- `NO_ACTIVE_SNAPSHOT`
  - source présente mais pas encore activée
- `CURRENT`
  - source courante identique au snapshot actif
- `MODIFIED_SINCE_ACTIVATION`
  - source courante différente du snapshot actif
- `INVALID_SOURCE`
  - comparaison impossible car source invalide

## Files touched
- `/home/kao/lib/kao-user-state.sh`
- `/home/kao/bin/kao-user`
- `/home/kao/bin/kao-boot`
- `/home/kao/tests/e2e/scenarios/user_patch_flow.sh`
- `/home/kao/tests/e2e/scenarios/boot_check.sh`
- `/home/kao/tests/e2e/run_e2e.sh`
- `/home/kao/state/sprints/sprint-3.5.md`

## Validation target
- `bash -n` sur tous les fichiers touchés
- chargement direct des scénarios E2E
- rendu boot lisible et cohérent
- full run E2E complet
