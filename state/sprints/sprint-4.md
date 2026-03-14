# SPRINT 4 — Runtime command surface canonization

## Mission
Introduce a canonical runtime command surface for Kao.

## Goal
Allow an operator to:

- read runtime state
- capture a snapshot
- compare runtime against a snapshot
- activate and deactivate runtime explicitly
- repair a drift to an owner baseline

## File 1 scope
Create the canonical runtime library.

## File 2 scope
Wire runtime commands into the main `kao` entrypoint.

## File 3 scope
Add explicit runtime transitions:

- kao runtime activate user
- kao runtime deactivate

## File 4 scope
Add E2E coverage for the runtime command surface.

## Validation target
- runtime surface callable from `kao`
- runtime state written in `state/runtime/`
- runtime log trace written in `state/logs/runtime.log`
- e2e scenario validates activate / snapshot / diff / deactivate

## Notes
Sprint 4 now covers runtime read, transition, snapshot, diff, repair, and E2E validation.

---

## DEV 0.4 documentary convergence note

Gateway documentation and release readability were locked after the runtime surface was stabilized.

Documented real state now includes:

- canonical `brain infer "<query>"` entrypoint
- gateway routing layer and provider roles
- cloud/local routing policy
- externalized secrets policy
- gateway log observability
- fallback behavior
- validation path through E2E

Current gateway state documented as real:

- `mistral` operational as cloud provider
- `ollama` present as local stub prepared for future extension
- secrets expected outside `/home/kao`
- gateway trace written in `state/logs/gateway.log`
- E2E gateway scenario integrated in the global suite

## Release lock result

The project documentation now explains clearly:

- how to launch `brain infer`
- how provider routing works
- where secrets live
- how to inspect logs
- what is production-ready
- what remains stubbed
- how to validate the whole surface

## Safety note

No secret was introduced in repository documentation.

The documentation remains aligned with the inspected code surface.

---

## DEV 0.5 gateway operator surface note

A canonical operator inspection surface now exists for the gateway.

Implemented real state now includes:

- canonical `kao gateway` command
- canonical `kao gateway status` command
- readable gateway diagnostic without reading shell libs directly
- visible selected / forced / detected provider information
- visible secrets file path and state
- visible log file path and state
- visible fallback policy
- visible operator diagnostic hint
- E2E lock for canonical gateway inspection behavior

## DEV 0.5 validation result

The gateway surface now supports two complementary operator paths:

- inference via `brain infer "<query>"`
- inspection via `kao gateway`

Validation now confirms:

- canonical gateway banner visibility
- selected provider visibility
- secrets path visibility
- log path visibility
- operator diagnostic visibility
- canonical help visibility
- preserved forced local route visibility
- preserved ollama stub visibility
- preserved provider auto-detection

## DEV 0.5 operator result

A human operator can now understand immediately:

- which provider is selected
- whether a provider is forced
- whether the forced value is supported
- which provider is detected
- where secrets are expected
- whether secrets are present
- where logs are written
- whether logs are already present
- which fallback policy applies
- what first diagnostic hint should guide the next action

---

## DEV 0.6 gateway health + logs diagnostics note

The gateway cockpit surface is now stronger and more directly usable by an operator.

Implemented real state now includes:

- canonical `kao gateway health` command
- canonical `kao gateway logs` command
- visible provider kind
- visible provider health
- visible provider note
- visible mistral availability and health
- visible ollama availability and health
- visible fallback status
- visible log line count
- visible last log event
- visible short gateway log preview
- reduced repeated secrets loading during one router process
- E2E lock for health and logs inspection surfaces

## DEV 0.6 validation result

Validation now confirms:

- canonical gateway status remains readable
- canonical gateway health banner visibility
- canonical gateway logs banner visibility
- selected kind visibility
- selected health visibility
- mistral health visibility
- ollama health visibility
- fallback status visibility
- log line count visibility
- last log event visibility
- log preview visibility
- canonical help updated to `status|health|logs`
- preserved forced local route visibility
- preserved ollama stub visibility
- preserved provider auto-detection

## DEV 0.6 operator result

A human operator can now diagnose quickly:

- which provider is selected
- whether it is cloud or local
- whether it is really ready or only stub-ready
- whether mistral is blocked by secrets or ready
- whether fallback is armed
- whether a gateway log already exists
- how much trace already exists
- what the latest gateway event was
- which last lines should be read first

---

# SPRINT DEV 0.7 — Gateway Log Hygiene + Real Local Provider Readiness

## Mission

Faire évoluer la gateway vers un niveau plus production-ready :

- clarifier le rôle du log runtime
- isoler les commandes cockpit du log d’exécution
- introduire une readiness locale progressive
- préparer l’inférence locale réelle
- conserver la stabilité E2E complète

## Résultats obtenus

### Log hygiene

La gateway distingue désormais :

- événements runtime réels → journalisés
- inspections cockpit → non journalisées

Cela permet :

- une trace opératoire plus lisible
- une réduction du bruit diagnostic
- une meilleure capacité d’analyse post-incident

Les traces importantes conservées :

- sélection provider lors d’inférence réelle
- succès d’inférence
- fallback effectif
- erreurs d’exécution

### Local provider readiness

Le provider local expose maintenant :

- unavailable
- local-stub-ready
- local-real-ready

Cela prépare Kao à :

- inference offline
- autonomie cognitive locale
- routage adaptatif cloud/local

Un stub opératoire reste disponible pour :

- stabiliser le workflow actuel
- permettre les tests E2E
- préparer la transition vers backend réel

### Gateway maturity

La gateway atteint maintenant :

- cockpit opérateur lisible
- routing déterministe
- fallback visible
- observabilité runtime stable
- base d’évolution vers cognition hybride

## Impact architecture

- renforcement du rôle du gateway comme couche cognitive
- préparation de l’orchestration agentique
- préparation de l’exécution locale réelle

## Impact documentation

Alignement complet :

- README
- PROJECT
- ARCHITECTURE
- USER_MANUAL

## État global

- E2E full vert
- surface CLI stable
- vocabulaire runtime consolidé
- base prête pour DEV 0.8

---

# SPRINT DEV 0.9 — Controlled Real Ollama Execution + Model Readiness Verification

## Mission

Durcir la readiness locale réelle pour éviter les faux positifs entre :

- runtime présent
- backend joignable
- modèle local disponible
- policy autorisée
- appel réel effectivement exécutable

## Résultats obtenus

### Ollama readiness durcie

Le provider local expose maintenant explicitement :

- un modèle local cible
- un état du modèle local
- un état runtime local
- un état d’exécution réelle locale

Readiness locale désormais distinguée :

- `unavailable`
- `local-stub-ready`
- `local-real-backend-ready`
- `local-real-ready`

État du modèle local :

- `unknown`
- `missing`
- `ready`

État runtime local :

- `stub-runtime`
- `real-backend-ready`
- `real-model-ready`
- `unavailable`

État d’exécution réelle :

- `callable`
- `blocked-policy`
- `blocked-no-model`
- `stub-only`
- `unavailable`

### Cockpit enrichi

`kao gateway status` et `kao gateway health` exposent maintenant :

- `ollama model`
- `ollama model state`
- `ollama runtime`
- `ollama real calls`
- `ollama real state`

Cela rend la lecture opérateur plus juste et plus exploitable.

### Runtime logs enrichis

Les logs runtime distinguent maintenant :

- tentative réelle locale
- modèle ciblé
- état du modèle
- succès réel
- succès stub
- fallback réel
- fallback stub

Cela améliore la lisibilité du comportement réel sans polluer le cockpit.

### CLI gateway réparée

Le dispatcher `gateway_cli` a été restauré dans le router
pour réaligner `bin/kao` avec la surface canonique :

- `kao gateway`
- `kao gateway status`
- `kao gateway health`
- `kao gateway logs`
- `kao gateway help`

### Validation

Validation obtenue sur :

- provider Ollama durci
- router enrichi
- cockpit status/health/logs lisible
- forced local route préservée
- log hygiene préservée
- E2E gateway scenario vert

## Impact

- readiness locale réelle plus stricte
- lecture explicite du modèle local
- exécution réelle locale mieux gouvernée
- base plus solide pour future cognition offline
- base plus solide pour futur routeur multi-providers

## État global

- E2E full vert
- surface CLI stable
- documentation alignée
- base prête pour extension online/offline plus intelligente

---

# SPRINT DEV 1.1 — Hybrid Router Intelligence Layer

## Mission

Faire évoluer `ray` d’une façade lisible
vers une façade décisionnelle lisible.

Introduire une première couche compacte
d’intelligence du routeur hybride
sans remplacer la gateway existante
et sans casser les surfaces déjà validées.

## Résultats obtenus

### Intelligence layer déterministe

Le routeur expose maintenant explicitement :

- `cloud score`
- `local score`
- `route score`
- `route reason`

Cette couche reste :

- simple
- lisible
- déterministe
- testable
- documentable

### Scoring posé

Le scoring opérateur introduit est compact :

- cloud prêt → score fort
- local `local-real-ready` → score élevé
- local `local-real-backend-ready` → score intermédiaire
- local `local-stub-ready` → score utile
- aucun provider prêt → score nul

Le score de route retenue est exposé séparément
pour permettre une lecture rapide de la décision effective.

### Reason opérateur

Les reasons exposées sont désormais :

- `cloud-priority-ready`
- `local-only-available`
- `forced-provider-mistral`
- `forced-provider-ollama`
- `unsupported-forced-provider`
- `no-provider-ready`

Cela permet à l’opérateur de comprendre
pourquoi une route est retenue
sans devoir lire directement la logique shell.

### Surface Ray enrichie

`ray status` expose maintenant :

- route sélectionnée
- provider sélectionné
- état de readiness
- `route reason`
- `route score`
- `cloud score`
- `local score`

Ray devient donc :

- une façade lisible
- une surface décisionnelle
- une première lecture cognitive du routeur hybride

### Validation

Validation obtenue sur :

- helpers ajoutés dans `lib/gateway/router.sh`
- exposition stable dans `bin/ray`
- lock E2E de la nouvelle surface `ray`
- convergence README / ARCHITECTURE / USER_MANUAL

## Impact

- meilleure lisibilité humaine du routage hybride
- première couche d’intelligence opérateur posée
- base prête pour priorisation plus fine future
- base prête pour routeur vivant multi-critères

## État global

- surface CLI stable
- E2E préservés
- documentation convergée
- base prête pour extension du router hybride

---

# SPRINT DEV 1.2 — Router Decision Policy Refinement

## Mission

Clarifier la lecture cognitive du routeur hybride.

Introduire une distinction explicite entre :

- capacité runtime du système
- décision de routage effectivement retenue

Sans modifier la logique fondamentale
de sélection des providers.

## Évolution introduite

Le routeur expose maintenant :

- `decision state`
- `operator mode`
- `hybrid state`

Ces trois lectures permettent :

- une compréhension humaine immédiate
- une détection des incohérences de forcing
- une base stable pour intelligence future du router

## États décisionnels introduits

- `route-selected`
- `no-route-selected`
- `blocked-unsupported-forcing`

Le dernier état apparaît lorsqu’un provider forcé :

- est invalide
- ou non supporté par la configuration runtime

Dans ce cas :

- la décision est bloquée
- la capacité runtime peut rester élevée
- le mode opérateur devient `degraded`

## Lecture cognitive du routeur

La doctrine devient :

- `hybrid state` → capacité runtime globale
- `decision state` → validité de la décision
- `mode` → lecture opérateur effective

Cela permet :

- une lecture claire des situations incohérentes
- une meilleure gouvernance du forcing
- une base pour futur router adaptatif multi-critères

## Impact

- amélioration forte de la lisibilité humaine
- stabilisation de la surface ray
- meilleure préparation au router vivant multi-LLM
- base cognitive plus robuste pour offline intelligence

## État global

- surface CLI stable
- E2E verts
- docs convergées
- base prête pour extensions futures


---

## DEV 1.3 — Hybrid Router Provider Intent Readability

### Mission

Refine operator readability when a provider forcing is expressed.

### Key evolution

- introduction of `forced raw value` helper in gateway
- distinction between:
  - raw operator input
  - normalized provider
  - forcing validity state
  - effective routing decision
- ray surface extended accordingly

### Operator impact

An unsupported forcing now exposes:

- forced raw value = invalid operator input
- forced provider = none
- forced state = unsupported
- decision state = blocked-unsupported-forcing
- mode = degraded
- hybrid state can remain hybrid-ready

This clarifies the difference between:

- runtime capability
- operator intent
- effective routing decision

### Validation

- router syntax OK
- ray syntax OK
- ray_surface e2e OK
- documentation converged
- repo clean expected after commit

---

# SPRINT DEV 1.4 — Hybrid Router Live Model Registry

## Mission

Introduire une première couche interne de registry des modèles
afin de préparer un routage multi-LLM plus intelligent.

## Objectifs

- déclarer un registry canonique provider / modèle
- exposer une lecture runtime simple et déterministe
- introduire une notion de score registry indépendante du routage
- préparer une logique future de ranking dynamique
- préserver la stabilité complète du gateway et des E2E existants

## Implémentation

Le router possède maintenant :

- un registry interne lisible en shell pur
- une entrée cloud canonique (mistral)
- une entrée locale canonique (ollama)
- un score base par entrée
- un état déclaré registry
- un état runtime registry
- un score runtime dérivé

Ray expose désormais :

- une lecture compacte du registry sélectionné via `ray status`
- une vue complète du registry via `ray registry`

## Doctrine

- le registry prépare la cognition future
- le registry n’influence pas encore la décision réelle
- le routage reste gouverné par la policy gateway
- la lecture humaine du paysage LLM devient possible

## Résultat opérateur

Un opérateur peut maintenant :

- comprendre quel modèle est réellement considéré
- lire un embryon de classement des capacités
- anticiper l’évolution du routage
- visualiser la maturité cloud vs local

## Impact architecture

- préparation d’un router vivant multi-modèles
- base pour ranking dynamique
- base pour sélection adaptative future
- fondation pour router agentique

## Validation

- E2E existants préservés
- surface ray stable
- gateway stable
- registry lisible
- documentation convergente


---

# SPRINT DEV 1.5 — Registry Runtime Intelligence & Ranked Provider Evolution

## Mission

Faire évoluer le registry Kao d’un simple inventaire lisible
vers une lecture de maturité runtime plus intelligente,
sans modifier la décision réelle du routeur.

## Résultats obtenus

### Registry enrichi

Le registry expose désormais pour chaque entrée :

- provider
- model
- family
- base score
- declared state
- runtime state
- runtime score
- operator rank score
- maturity level

### Bridge router stabilisé

Le pont `router -> registry` a été stabilisé pour éviter
les collisions de symboles entre wrappers publics du routeur
et fonctions internes du registry.

Le routeur expose maintenant proprement :

- registry count
- registry selected provider/model/family
- registry selected base score
- registry selected declared state
- registry selected runtime state
- registry selected runtime score
- registry selected operator rank score
- registry selected maturity level

### Surface ray enrichie

`ray status` expose désormais :

- registry score
- registry rank
- registry maturity

`ray registry` expose maintenant une vue comparative enrichie,
triée par rang opérateur lisible.

### Doctrine validée

Cette évolution :

- n’altère pas la policy cloud-first
- ne modifie pas la décision réelle du routeur
- n’introduit aucun appel API externe
- prépare la future logique de ranking vivant

## Validation obtenue

Validation locale confirme :

- syntaxe registry OK
- syntaxe router OK
- syntaxe ray OK
- syntaxe ray_surface OK
- `ray status` expose score, rank et maturity
- `ray registry` expose la vue comparative enrichie
- E2E aligné sur les nouveaux champs

## Effet architecture

Kao dispose maintenant :

- d’un registry runtime plus intelligent
- d’une première lecture de maturité comparative
- d’une base stable pour une future couche de ranking dynamique
- d’une fondation propre pour un futur routeur vivant sans casser le présent


---

## DEV 1.7 — Live Model Intelligence Layer

### Intent

Introduce a first strategic cognitive reading layer
over the live model registry without altering routing.

### Operator surface

New command:

- `ray scout`

### Exposed reading

The scout surface exposes for the selected registry entry:

- provider
- model
- family
- maturity
- operator rank
- mapped strategic status

Strategic status mapping:

- elite → dominant
- high → competitive
- medium → viable
- low → incubating
- unknown → experimental

### Architectural impact

- router now derives a strategic status signal
- ray exposes a new cognitive landscape surface
- registry observability remains read-only
- routing policy remains unchanged
- hybrid router decision layer stays deterministic

### Verification

- targeted E2E: OK
- global E2E: OK
- runtime snapshot clean
- repo state clean

### Cognitive milestone

This sprint introduces the first notion of:

- model landscape reading
- strategic posture awareness
- operator-visible comparative cognition

It prepares future:

- live ranking evolution
- adaptive routing intelligence
- gamified agent perception layers


---

# SPRINT DEV 1.8 — Live Model Landscape Multi-Entry Surface

## Mission

Faire évoluer la surface opérateur `ray scout` :

- d’une lecture registry sélectionnée
- vers une lecture comparative multi-entrée du paysage modèle vivant.

## Résultats obtenus

### Surface opérateur enrichie

`ray scout` expose maintenant :

- provider
- model
- family
- maturity
- operator rank
- strategic status

pour **toutes les entrées registry classées**.

La lecture est :

- ordonnée par rang opérateur
- comparative
- déterministe
- strictement read-only

### Cohérence architecturale

Cette évolution :

- n’altère pas la logique de routage
- n’introduit pas encore de ranking décisionnel réel
- prépare une future orchestration intelligente du provider.

Le router conserve :

- priorité cloud
- fallback lisible
- scoring opérateur informatif uniquement.

### Impact E2E

Les tests confirment :

- visibilité du banner MODEL LANDSCAPE
- présence des entrées registry attendues
- ordre correct par rang
- lisibilité du statut stratégique
- stabilité complète des surfaces `ray`.

### Convergence documentaire

Alignement réalisé sur :

- README
- ARCHITECTURE
- USER_MANUAL

La notion de :

> paysage modèle sélectionné

évolue officiellement vers :

> paysage modèle comparatif multi-entrée.

## État global après DEV 1.8

- router déterministe stable
- registry vivant lisible
- surface opérateur stratégique enrichie
- base prête pour ranking dynamique futur
- cognition hybride progressivement observable



---

## DEV 1.9 intent router note

A first cognitive intent layer now exists inside the Ray operator surface.

Implemented real state now includes:

- canonical `/home/kao/lib/cognition/intent_router.sh` library
- canonical `ray ask "<prompt>"` command
- deterministic prompt classification without LLM decision cost
- visible intent class
- visible cognitive route family
- visible readable action label
- provider exposure only when an LLM family is implied
- dedicated E2E scenario for the intent reading surface

## DEV 1.9 validation result

Validation now confirms:

- intent router shell syntax is valid
- `ray` shell syntax remains valid
- file-oriented prompt is classified as `file-op`
- meeting summary prompt is classified as `cognitive-heavy`
- local agent route is visible for file operations
- heavy LLM route is visible for cognitive prompts
- provider visibility remains coherent with LLM-intent prompts
- `ray ask` help surface is documented in command usage
- dedicated `ray_intent` scenario is present

## DEV 1.9 operator result

A human operator can now read before execution:

- what kind of task was understood
- whether the task is interpreted as local or LLM-oriented
- which readable action category is associated
- whether a provider is relevant for the current intent
- how Kao begins to separate intent reading from inference execution

---

## DEV 2.0 intent-aware execution bridge note

Ray now exposes a first explicit bridge between
operator intent and retained execution strategy.

Implemented real state now includes:

- canonical `ray bridge "<prompt>"` command
- enriched `ray ask "<prompt>"` reading
- visible execution mode
- visible execution strategy
- visible execution surface
- visible execution decision
- first bridge between intent classification and retained execution family
- gateway execution retained for cognitive prompts
- deterministic local-action-pending state for file/system prompts
- canonical execution bridge library in `lib/cognition/execution_bridge.sh`
- E2E lock for ask / bridge / local pending state

## DEV 2.0 validation result

Validation now confirms:

- canonical execution bridge library syntax
- canonical `ray` syntax remains valid
- `ray ask` exposes intent + execution bridge reading
- `ray bridge` exposes compact execution bridge state
- cognitive-heavy prompts retain gateway execution posture
- local file prompts retain shell bridge posture
- local execution remains intentionally non-destructive at this stage
- E2E scenario locks the operator-visible behavior

## DEV 2.0 operator result

A human operator can now understand:

- how Kao classifies the prompt
- which route family is associated with the prompt
- which action label is associated with the prompt
- which execution strategy is retained
- which execution surface is currently selected
- whether execution is bridgeable
- whether the provider remains relevant for the retained task
- whether a local task is recognized but intentionally pending
- how future direct local execution can be introduced without breaking the current runtime model

---

## SPRINT DEV 2.1 — Execution Paths + Local Action Sequences

## Mission

Move from execution bridge reading to first controlled execution paths.

## Goal

Allow Kao to begin executing a first small set of canonical local paths safely,
instead of only exposing local-action-pending.

## Implemented real state

The execution bridge now supports a first bounded local execution layer.

Implemented real state now includes:

- canonical local path identification derived from prompt
- canonical local path labels
- canonical local path states
- canonical local path sequence exposure before action
- bounded safe local execution through internal deterministic sequences
- preserved gateway path for cognitive prompts
- preserved explicit pending state for non-mapped local actions
- preserved non-destructive doctrine
- preserved workspace-bounded directory resolution

Current canonical local safe paths include:

- `path-open-directory`
- `path-list-current-directory`

Current local execution behavior is:

- `ouvre dossier <target>` → resolve target under workspace and list entries
- `liste fichiers` / `ls` → resolve current workspace and list entries
- non-recognized local prompt → `local-action-pending`
- cognitive prompt → gateway-backed inference path

## Validation result

Validation now confirms:

- execution bridge shell syntax is valid
- `ray` shell syntax remains valid
- `ray_intent` E2E scenario remains valid
- operator bridge surface exposes:
  - path id
  - path label
  - path state
  - path sequence
- `ray run "ouvre dossier lib"` executes the canonical safe directory-open path
- `ray run "liste fichiers"` executes the canonical safe current-workspace listing path
- `ray run "rm tmp"` remains explicitly pending and non-destructive
- gateway-backed cognitive execution remains preserved

## Operator result

A human operator can now:

- read the retained execution path before action
- see whether a request is executable immediately or still pending
- execute a first bounded subset of safe local read actions
- keep dangerous or non-mapped local intents outside unrestricted shell execution
- preserve a visible bridge between intent classification and effective action

## Next evolution path

This stage prepares:

- a dedicated local path library
- an action registry
- broader safe system inspection paths
- richer workspace-aware path resolution
- stricter operator policy layers before any destructive capability

---

## DEV 2.2 local path registry + safe system inspection note

A canonical local path registry and a safe
system inspection surface now exist for Ray.

Implemented real state now includes:

- canonical `lib/system/local_paths_registry.sh` library
- canonical `lib/system/system_inspector.sh` library
- canonical `ray system inspect` command
- stable local operator inspection banner
- canonical registry-driven path reading
- readable local path state rendering
- explicit read-only inspection doctrine
- E2E registration for `ray_system_inspect`

Current canonical local inspection entries include:

- root path
- bin directory
- library root
- cognition libs
- system libs
- state directory
- logs directory
- runtime state
- e2e scenarios
- agent registry

Current local inspection states include:

- `OK`
- `MISSING`
- `TYPE-MISMATCH`
- `UNREADABLE`

## DEV 2.2 validation result

Validation now confirms:

- `local_paths_registry.sh` shell syntax is valid
- `system_inspector.sh` shell syntax is valid
- `ray` shell syntax remains valid
- `ray --help` exposes `ray system inspect`
- `ray system inspect` renders a stable local inspection surface
- canonical local system paths are readable through Ray
- missing future agent registry stays visible as `MISSING`
- dedicated `ray_system_inspect` scenario is registered
- full E2E suite remains green at score 100

## DEV 2.2 operator result

A human operator can now understand quickly:

- whether the core Kao root exists
- whether canonical bin and lib surfaces exist
- whether cognition and system libraries are present
- whether runtime and log directories are present
- whether E2E surfaces are present
- whether a future agent registry is already mounted
- whether the inspected local topology is coherent enough before deeper action

## DEV 2.2 doctrine result

The local inspection layer now stays:

- registry-driven
- deterministic
- read-only
- non-destructive
- secret-safe
- ready for future local doctor and capability expansion

---

## DEV 2.3 runtime snapshot governance note

A dedicated runtime hygiene rule is now locked for the repository.

Implemented real state now includes:

- explicit Git ignore rule for `state/runtime/runtime.snapshot`
- explicit architecture distinction between versioned source and ephemeral runtime state
- explicit operator manual doctrine for runtime mutation during validation
- sprint convergence documenting the governance decision

## DEV 2.3 validation result

Validation now confirms:

- `state/runtime/runtime.snapshot` is governed as runtime state, not source
- runtime snapshot mutation no longer needs a final manual restore to keep the repository clean
- repository hygiene doctrine is now documented in architecture and user-facing operator guidance
- sprint documentation is aligned with the current runtime governance rule

## DEV 2.3 operator result

A human operator can now understand immediately:

- why runtime snapshot mutations may happen during validation
- why those mutations are not source changes
- how Git hygiene distinguishes source from runtime
- why end-of-sprint repository cleanliness is easier to preserve going forward

---

## DEV 2.4 ownership governance inspection note

Ray system inspection now exposes ownership-oriented metadata
for each canonical local path entry.

Implemented real state now includes:

- visible owner for each inspected path
- visible group for each inspected path
- visible permission mode for each inspected path
- visible resolved real path for each inspected path
- explicit fallback metadata for missing paths
- preserved readable state surface for existing inspection results
- E2E lock for ownership metadata visibility

## DEV 2.4 validation result

Validation now confirms:

- `ray system inspect` keeps its canonical banner
- canonical path labels remain visible
- canonical path states remain readable
- root path owner is visible
- root path mode is visible
- root path resolved path is visible
- missing path fallback owner is visible as `n/a:n/a`
- missing path fallback mode is visible as `n/a`
- targeted harness execution is green
- full E2E runner remains green
- runtime snapshot hygiene is restored after validation

## DEV 2.4 operator result

A human operator can now understand immediately:

- whether a canonical path exists
- whether it is readable
- who owns it
- which group governs it
- which permission mode is applied
- which real path is being inspected
- whether a missing path is absent cleanly without fake metadata
- where root-managed and operator-managed areas diverge

---

## DEV 2.5 ownership drift diagnostic surface note

A canonical ownership drift diagnostic surface now exists for local system inspection.

Implemented real state now includes:

- canonical expected metadata baseline for inspected local paths
- expected owner per canonical path
- expected group per canonical path
- expected mode per canonical path
- drift computation against the expected metadata baseline
- compact drift signal exposure in `ray system inspect`
- preserved missing path fallback with `n/a` metadata
- E2E lock for expected metadata and drift visibility

The canonical baseline is now defined in:

- `lib/system/local_paths_registry.sh`

The drift computation is now implemented in:

- `lib/system/system_inspector.sh`

## DEV 2.5 validation result

Validation now confirms:

- expected metadata list syntax is valid
- system inspector syntax remains valid
- `ray system inspect` now exposes expected metadata
- `ray system inspect` now exposes drift state
- root path drift can be reported as `OK`
- real drift can be reported on owned or permission-shifted paths
- missing path fallback remains readable with expected metadata preserved
- targeted E2E harness validation is green for the drift surface

## DEV 2.5 operator result

A human operator can now understand immediately:

- which canonical local path is compliant
- which path has an ownership drift
- which path has a group drift
- which path has a mode drift
- which path combines multiple drifts
- what metadata was expected for each inspected path
- whether a missing path still belongs to the governed baseline
- where future controlled repair should target first

## DEV 2.6 ownership governance action scaffold note

A first ownership governance action scaffold now exists for Ray local system inspection.

Implemented real state now includes:

- canonical `ray system repair` command
- canonical `ray system repair --dry-run` command
- repair preview based on the existing local metadata registry
- repair filtering restricted to paths already in `OK` state
- explicit `NOOP`, `DRY-RUN` and `SKIP` operator outcomes
- metadata action preview for owner, group and mode
- argument guard on unsupported repair options
- E2E lock extended for repair dry-run visibility

The repair scaffold is currently conservative by design:

- missing paths are not created
- non-readable or type-mismatched paths are not altered
- dry-run remains the documented validation entrypoint for this sprint
- the current layer prepares a future controlled real repair phase

The repair computation is now implemented in:

- `/home/kao/lib/system/system_inspector.sh`
- `/home/kao/bin/ray`
- `/home/kao/tests/e2e/scenarios/ray_system_inspect.sh`

## DEV 2.6 validation result

Validation now confirms:

- system inspector syntax remains valid
- ray syntax remains valid
- `ray --help` exposes `ray system repair`
- `ray system repair --dry-run` renders a stable operator banner
- aligned paths can be reported as `NOOP`
- metadata drift paths can be reported as `DRY-RUN`
- missing paths can be reported as `SKIP`
- unsupported repair options fail explicitly
- targeted E2E scenario content now covers repair dry-run visibility
- direct standalone execution of the scenario file remains non-conclusive because the file declares the scenario function and relies on the global E2E harness for execution

## DEV 2.6 operator result

A human operator can now understand immediately:

- which canonical path is already aligned
- which canonical path would receive an owner fix
- which canonical path would receive a group fix
- which canonical path would receive a mode fix
- which path combines multiple metadata repair actions
- which missing path remains intentionally excluded from repair
- how a future real repair command should behave before enabling it

---

## DEV 2.7 controlled real ownership repair note

The ownership governance layer now progresses from preview-only repair to controlled real repair.

Implemented real state now includes:

- canonical `ray system repair` command performing real metadata repair
- preserved `ray system repair --dry-run` preview behavior
- repair limited to canonical registry-driven local paths
- repair limited to paths already in `OK` state
- repair limited to `owner`, `group`, and `mode`
- visible `NOOP`, `DRY-RUN`, `REPAIRED`, and `SKIP` operator states
- visible `post-drift` confirmation after repair computation
- preserved exclusion of `MISSING`, `TYPE-MISMATCH`, and `UNREADABLE` paths
- targeted E2E lock for dry-run preview, real repair, and post-repair alignment

The repair layer remains conservative by design:

- it never creates missing paths
- it never changes paths outside the canonical registry
- it never repairs non-readable or structurally invalid targets
- it keeps excluded targets visible instead of hiding them

## DEV 2.7 validation result

Validation now confirms:

- `ray system repair --dry-run` still previews exact metadata actions without mutating paths
- `ray system repair` applies real ownership and mode corrections on eligible targets
- repaired paths converge to `post-drift OK`
- `ray system inspect` confirms alignment after real repair
- missing paths remain intentionally skipped
- unsupported repair options still fail explicitly
- dedicated E2E scenario now covers preview, repair, and post-repair verification
- targeted E2E score remains `100`

## DEV 2.7 operator result

A human operator can now understand immediately:

- which path is already aligned
- which path would be repaired in preview mode
- which path has been repaired for real
- which path remains excluded and why
- whether the post-repair state is now compliant with the local registry baseline

## DEV 2.7 touched files

- `lib/system/system_inspector.sh`
- `tests/e2e/scenarios/ray_system_inspect.sh`
- `docs/ARCHITECTURE.md`
- `docs/USER_MANUAL.md`
- `state/sprints/sprint-4.md`

---

## DEV 2.8B runtime governance layer note

The ray and gateway surfaces now expose a first explicit Kao runtime governance layer.

Implemented real state now includes:

- visible `network state`
- visible `local llm state`
- visible `cloud llm state`
- visible `execution mode`
- visible `selection policy`
- gateway fallback policy renamed to `best-available-by-state`
- preserved current provider selection behavior
- preserved current registry and scout surfaces
- E2E lock extended for the new visible governance markers

This sprint also clarified the product doctrine:

- `mistral` is not considered inherently prioritary
- a provider may be selected because it is the best currently available candidate
- Kao should evaluate the best available option at interaction time according to current system state
- local and cloud cognition remain distinct runtime dimensions
- offline local cognition is a valid sovereign operating state

Canonical runtime expressions discussed and documented:

- `(Device + kaoOS = on) + (LLM + @ = off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local off & cloud on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local & cloud + @ on) + moi`

## DEV 2.8B validation result

Validation now confirms:

- `router.sh` syntax remains valid
- `ray` syntax remains valid
- `ray_surface.sh` syntax remains valid
- `ray status` exposes the new runtime governance fields
- `ray status` now shows `best-available-by-state`
- `ray scout` remains stable
- the repository remains controlled and convergent during the sprint workflow

## DEV 2.8B operator result

A human operator can now read directly:

- whether the machine is online or offline
- whether a local llm path is visible in runtime state
- whether a cloud llm path is visible in runtime state
- which execution mode Kao currently reports
- which visible policy currently governs provider selection

## DEV 2.8B process note

An initial DEV 2.8 attempt failed because the patch anchors did not match the real file contents.

The sprint was then corrected through a precise re-inspection workflow and completed as DEV 2.8B using real insertion anchors taken from the inspected files themselves.

---

## DEV 2.8 session runtime cognition note

A runtime session cognition layer now exists for the `ray` operator surface.

Implemented real state now includes:

- canonical `ray session` surface
- explicit `ray session open`
- explicit `ray session close`
- visible `ray session history`
- `state/runtime/session.current`
- `state/runtime/session.history`
- breathing header before `ray run`
- gateway and secondary agents accumulation inside the active session
- dedicated E2E scenario for session lifecycle

## DEV 2.8 validation result

Validation now confirms:

- session library shell syntax is valid
- `ray` shell syntax remains valid
- session open creates an active runtime session
- session status exposes machine, internet, llm, gateway, and agents
- intent inspection enriches the active agent list
- session close archives a readable closed session line
- session history remains operator-readable
- dedicated `ray_session` scenario is present

## DEV 2.8 operator result

A human operator can now read:

- when a runtime session started
- how long it has been active
- whether Kao is currently online or offline
- whether cognition is currently local or cloud-oriented
- which gateway is principal at the current moment
- which secondary agent surfaces have been called during the session
- what the last closed runtime sessions looked like

## DEV 2.8 runtime hygiene convergence note

The session runtime artifacts were aligned with the existing Git hygiene doctrine.

Converged runtime-local artifacts now explicitly ignored by Git:

- `state/runtime/session.current`
- `state/runtime/session.history`

This keeps:

- session cognition visible for the operator
- runtime history available locally
- repository status clean after validation and normal usage

---

## DEV 2.9 session lifecycle integrity note

The runtime session cognition layer has been extended to improve historical fidelity.

Implemented real state now includes:

- canonical session identifier
- last visible event timestamp on active session
- compact runtime history index
- dedicated snapshot archive per closed session
- persistent lineage between runtime history and archived session state
- improved operator temporal readability

Runtime session artifacts now include:

- `state/runtime/session.current`
- `state/runtime/session.history`
- `state/sessions/<session-id>.snapshot`

Design doctrine refinement:

- runtime history remains compact and readable
- each closed session preserves a full immutable snapshot
- session lineage becomes traceable across operator cycles
- runtime temporal continuity becomes observable
- Kao breathing state becomes historically inspectable

Runtime hygiene extension:

- `state/sessions/` is treated as ephemeral local runtime state
- archived session snapshots are intentionally excluded from Git tracking
- repository cleanliness remains preserved after normal usage

Operator outcome:

A human operator can now:

- identify each runtime session uniquely
- inspect full closed session state later
- read compact history while preserving detailed archives
- observe continuity of cognitive presence across work cycles
- reason about temporal behavior of Kao as a living system

