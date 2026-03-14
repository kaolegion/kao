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

