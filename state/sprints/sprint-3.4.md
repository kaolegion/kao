# SPRINT 3.4 — Runtime user canonical source creation / inspection / removal workflow

## Mission
- introduire une gestion canonique de la source runtime user
- permettre de créer `config/user.env` via une commande dédiée
- permettre d’inspecter de façon déterministe la source runtime user
- permettre de supprimer proprement la source runtime user et son état
- conserver la séparation entre source runtime et activation runtime
- garder `owner` comme autorité active primaire par défaut
- maintenir une lecture claire de l’état `INACTIVE / AVAILABLE / ACTIVE / INVALID / BROKEN`
- étendre la surface `kao user` sans casser les flux précédents
- ajouter un scénario E2E dédié au cycle inspect / create / remove
- maintenir la compatibilité complète avec l’observabilité boot et les scénarios E2E existants

## Goal
permettre à Kao de gérer la source canonique du runtime user
sans édition manuelle obligatoire de `config/user.env`

## Expected result
- `kao user inspect` décrit l’état de la source runtime user
- `kao user create` génère une source canonique valide dans `config/user.env`
- `kao user remove` supprime `config/user.env` et `config/user.state` proprement
- la création d’une source valide rend le user `AVAILABLE`
- la suppression de la source replace le user en `INACTIVE`
- `kao-boot` reflète correctement les transitions create / remove
- le nouveau scénario E2E valide le cycle complet inspect / create / remove

## Files changed
- `/home/kao/lib/kao-user-state.sh`
- `/home/kao/bin/kao-user`
- `/home/kao/tests/e2e/scenarios/user_profile_source_flow.sh`
- `/home/kao/tests/e2e/run_e2e.sh`
- `/home/kao/state/sprints/sprint-3.4.md`

## Implementation summary

### 1. User state library extended
`/home/kao/lib/kao-user-state.sh` now adds:
- `kao_user_state_write_runtime_env`
- `kao_user_inspect_source_kv`
- `kao_user_remove_runtime_source`

These functions provide:
- canonical runtime user source generation
- deterministic metadata inspection
- safe deletion of runtime source and runtime state

### 2. Canonical kao user surface extended
`/home/kao/bin/kao-user` now adds:
- `kao user inspect`
- `kao user create [name] [role] [id] [title] [handle] [org]`
- `kao user remove`

The command surface now separates clearly:
- source management
- runtime activation
- runtime recovery

### 3. New E2E scenario added
`/home/kao/tests/e2e/scenarios/user_profile_source_flow.sh` validates:
- missing source inspection
- canonical source creation
- generated id derivation
- boot reflection after source creation
- source removal with state cleanup
- boot return to owner-only scene

### 4. E2E runner updated
`/home/kao/tests/e2e/run_e2e.sh` now includes:
- `scenario_user_profile_source_flow`

## Validation performed
- strict syntax check on updated files
- direct function presence checks on user state library
- direct `kao user` smoke checks for inspect / create / remove
- direct scenario load check for `user_profile_source_flow`
- full E2E run with new scenario integrated

## Validation result
- full E2E score: `100`
- warnings: `0`
- errors: `0`

## Product effect
Kao can now manage the runtime user source canonically from its own command surface.
This removes the need for risky manual edits when creating or deleting a runtime user source,
while preserving explicit activation as a separate runtime governance action.

## Canonical commands delivered
- `kao user inspect`
- `kao user create`
- `kao user remove`
- `kao user activate`
- `kao user deactivate`
- `kao user recover`

## State model after sprint
- no source + no marker => `INACTIVE`
- valid source + no marker => `AVAILABLE`
- valid source + active marker => `ACTIVE`
- invalid source => `INVALID`
- valid source + invalid marker => `BROKEN`

## Notes
- source creation does not auto-activate the runtime user
- source removal also removes runtime activation state
- boot observability remains the canonical visual runtime surface
