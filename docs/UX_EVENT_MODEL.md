# KAO — UX Event Model

## Purpose

This document defines the current semantic event model used by Kao runtime session timeline.

It acts as a bridge between:

- runtime shell events
- operator-readable narrative traces
- future TUI / HUD / visual timeline surfaces

---

## Canonical event line

Current canonical runtime line format:

- `SESSION_EVENT|event_version=...|event_id=...|at=...|session_id=...|type=...|machine=...|user=...|internet=...|llm=...|gateway=...|agents=...|detail=...`

Design rule:

- keep the line grep-friendly
- keep `type` stable
- enrich meaning through `detail`

---

## Current semantic layer

Current semantic signals appended to `detail` may include:

- `action=...`
- `family=...`
- `scope=...`
- `intensity=...`
- `surface=...`

Example:

- `detail=action=operator-status;family=operator_surface;scope=operator;intensity=passive;surface=operator`

---

## Event type layer

Current stable event types:

- `session-open`
- `session-touch`
- `session-close`

This layer is intentionally compact and shell-stable.

---

## Event family layer

Current visible families:

- `session_lifecycle`
- `operator_surface`

Target future families may include:

- `gateway_activity`
- `local_execution`
- `system_activity`

---

## Scope layer

Current scope meanings:

- `environment` → session presence / global runtime context
- `operator` → explicit human/operator-visible interaction
- `cognitive` → routing / reasoning / gateway interpretation
- `system` → local execution / filesystem / runtime mechanisms

KSL dashboard scope adds a second visible scope layer for signal surfaces:

- `local` → local agent or unit action
- `session` → current cognitive session field
- `global` → machine or network world state
- `future` → predictive or roadmap-facing signal

---

## Intensity layer

Current intensity meanings:

- `passive` → low-friction operational trace
- `active` → meaningful visible operator activity
- `critical` → repair / safety / strong intervention
- `narrative` → structural timeline moment

KSL signal intensity remains encoded as `i1..i4`.

---

## Surface layer

Current surface meanings:

- `system`
- `operator`
- `gateway`
- `environment`

Future UX mapping idea:

- `system` → base runtime layer
- `operator` → CLI / command / control layer
- `gateway` → cognition / routing / agent layer
- `environment` → world state / session atmosphere layer

---

## KSL dashboard semantic layer

KSL now exposes a dashboard-oriented semantic layer in addition to the canonical runtime timeline.

Each signal can now be read through:

- domain
- visible state
- intensity
- animation pattern
- object
- role
- scope

Example signal reading:

- `◆/NET/success/i2/hold/router:cloud`
- domain = `NET`
- state = `success`
- intensity = `i2`
- pattern = `hold`
- object = `router:cloud`
- role = `decision`
- scope = `session`

Primary dashboard roles:

- `presence` → session existence / user or runtime breathing
- `context` → environment or network condition
- `decision` → routing or arbitration moment
- `execution` → agent work in progress or completion
- `memory` → recall / heat / persistence signal
- `prediction` → roadmap / future / anticipation layer
- `state` → fallback generic semantic role

This prepares four readable dashboard families:

- cognitive radar
- signal stream
- agent field
- temporal navigator

---

## Current UX mapping intent

This semantic model prepares future:

- timeline cards
- live TUI event panels
- session replay nodes
- HUD layers
- cognitive heat / activity filters
- dashboard semantic overlays

The current rule is:

- do not replace the shell timeline
- enrich it until visual layers can consume it directly

---

## Implementation sources

Current implementation files:

- `lib/runtime/session_manager.sh`
- `lib/runtime/event_normalizer.sh`
- `config/event_taxonomy.env`
- `lib/ksl/ksl_engine.sh`
- `lib/ksl/ksl_mapping.env`
- `lib/ksl/ksl_render.sh`
- `lib/ksl/ksl_timeline.sh`

Validation surfaces:

- `ray session timeline`
- `tests/e2e/scenarios/ray_timeline.sh`
- `tests/e2e/scenarios/ray_session_timeline_v2.sh`
- `kao status`
- `kao hud`

## Timeline cognitive query intent

The runtime semantic model now supports operator cognitive filtering.

The query layer enables:

- session clustering
- agent presence mapping
- cognitive intensity reading
- provider distribution inspection

This prepares future UX surfaces such as:

- timeline heat maps
- cognitive workload overlays
- session replay navigation
- agent constellation views
- dashboard semantic grouping


## Agent field surface

- gateway = centre
- agents = satellites runtime
- observer = monitoring cognitif


## Temporal dashboard navigation

Le dashboard KSL peut exposer une navigation temporelle minimale pilotée par un curseur.

Principes :

- un curseur temporel sélectionne un événement actif dans la timeline
- une fenêtre locale affiche les événements autour du curseur
- l’événement focalisé est préfixé par `>>`
- la navigation prépare trois plans UX :
  - passé consultable
  - présent actif
  - futur projeté

Contrôles minimaux :

a = reculer d’un événement
d = avancer d’un événement
0 = aller au début
$ = aller à la fin

Format de statut :

cursor=9 window=5 total=10
