# Sprint 3.3 — Runtime user broken-state policy, recover workflow, and boot observability

## Mission
- introduire un état runtime user explicite `BROKEN`
- distinguer clairement `INACTIVE`, `AVAILABLE`, `ACTIVE`, `INVALID`, `BROKEN`
- empêcher une activation user si la scène runtime est cassée
- introduire une commande canonique `kao user recover`
- réparer de façon déterministe le marqueur runtime user
- enrichir le boot avec les indices de diagnostic user
- refléter au login les hints d’activation, de recovery et la raison de casse
- maintenir owner comme autorité active primaire
- conserver la compatibilité complète avec les scénarios E2E
- étendre les scénarios E2E au cas broken + recover

## Files touched
- `/home/kao/lib/kao-user-state.sh`
- `/home/kao/bin/kao-user`
- `/home/kao/bin/kao-boot`
- `/home/kao/tests/e2e/scenarios/boot_check.sh`
- `/home/kao/tests/e2e/scenarios/operator_flow.sh`
- `/home/kao/tests/e2e/scenarios/user_activation_flow.sh`

## Delivered
- normalisation explicite du marqueur runtime user avec séparation `missing` / `inactive` / `active` / `invalid`
- calcul d’état enrichi avec `BROKEN`
- commande `kao user status`
- commande `kao user recover`
- refus d’activation si scène runtime cassée
- politique de recover déterministe sur le fichier `user.state`
- enrichissement du boot avec :
  - `USER MODE`
  - `USER LABEL`
  - `USER RELATION`
  - `USER SOURCE`
  - `USER SOURCE FILE`
  - `USER ACT HINT`
  - `USER RECOVER`
  - `USER BROKEN WHY`
- rendu boot cohérent pour :
  - `INACTIVE`
  - `AVAILABLE`
  - `ACTIVE`
  - `INVALID`
  - `BROKEN`

## Runtime policy
- `INACTIVE`
  - aucune source user exploitable active
  - owner seul reste actif
- `AVAILABLE`
  - source user valide présente
  - user non activé
  - le cas `marker missing` avec `user.env` valide doit résoudre en `AVAILABLE`
- `ACTIVE`
  - source user valide présente
  - marqueur runtime actif
- `INVALID`
  - source env user invalide
  - activation refusée jusqu’à réparation
  - reste `INVALID` même si un marqueur runtime existe encore
- `BROKEN`
  - incohérence runtime détectée
  - recover requis avant activation

## Recover policy
- si `user.env` est valide et le marqueur est invalide :
  - remplacement par `inactive`
  - résultat `AVAILABLE`
- si `user.env` est valide et le marqueur est `missing` :
  - normalisation déterministe vers `inactive`
  - résultat `AVAILABLE`
- si `user.env` est valide et le marqueur est actif/inactif :
  - normalisation déterministe
- si `user.env` est invalide :
  - suppression du marqueur cassé
  - résultat `INVALID`
  - policy `PARTIAL`
- si `user.env` est absent :
  - suppression du marqueur orphelin
  - résultat `INACTIVE`

## Errors encountered during sprint
- plusieurs injections ont été corrompues en terminal par collision entre heredoc et `chmod`, ce qui a produit des fichiers partiellement pollués
- le cas `state_marker_normalized=missing` dérivait à tort vers `INACTIVE` au lieu de `AVAILABLE` quand `user.env` était valide
- le cas `user.env` invalide + marqueur présent dérivait à tort vers `BROKEN` au lieu de `INVALID`
- `boot_check.sh` était resté aligné sur une ancienne lecture du boot et vérifiait des sorties non convergées avec la policy finale
- la validation finale du sprint a remonté 13 erreurs E2E avant convergence H1

## Validation target
- `kao user help`
- `kao user current`
- `kao user status`
- `kao user recover`
- `kao user activate`
- `kao user deactivate`
- boot avec scène user absente / disponible / active / invalide / cassée
- E2E boot check enrichi
- E2E operator flow enrichi
- E2E user activation flow enrichi

## Expected functional result
- le runtime user devient opérable comme sous-système gouverné
- le boot expose désormais une lecture cognitive claire de la relation owner / user
- le système peut refuser, diagnostiquer, réparer puis réactiver de façon déterministe
