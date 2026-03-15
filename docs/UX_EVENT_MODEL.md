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

## Runtime transaction semantic layer

Kao now introduces a local runtime transaction semantic layer.

This layer does not replace session narrative events.

It adds a second semantic reading for runtime safety mechanisms such as:

- transaction begin
- resource staging
- WAL recording
- apply execution
- consistency verification
- rollback
- recovery confirmation

This layer is intended for:

- runtime diagnostics
- future recovery timeline cards
- system safety overlays
- crash-safe operator replay

---

## Transaction state semantics

The current runtime transaction model exposes two compact visible axes:

- `STATE`
- `BARRIER_STATE`

Current transaction state meanings:

- `open` → transaction created and logically pending between operator steps
- `committing` → apply phase entered under an active mutation lock
- `committed` → commit completed
- `rolled_back` → manual rollback completed
- `aborted` → interrupted transaction reverted by safety flow

Current barrier state meanings:

- `none` → no transactional barrier reached yet
- `staged` → resources copied and registered before apply
- `apply-running` → apply barrier entered
- `applied` → apply barrier completed
- `reverted` → recovery or rollback returned the runtime to snapshot baseline

UX reading intent:

- `STATE` tells the lifecycle phase
- `BARRIER_STATE` tells the safety position inside that phase

Together, they prepare future UX surfaces such as:

- transaction ladders
- recovery badges
- reliability heat markers
- crash replay ribbons

---

## WAL and recovery event families

The runtime semantic model can now represent system-safety events in addition to session events.

Current or near-term transaction/recovery families include:

- `runtime_transaction`
- `runtime_recovery`
- `runtime_consistency`

Representative actions may include:

- `transaction-begin`
- `transaction-stage`
- `transaction-apply`
- `transaction-commit`
- `transaction-rollback`
- `transaction-consistency-check`
- `recovery-detected`
- `recovery-rollback`
- `recovery-confirm`
- `recovery-skip-terminal`

Suggested semantic reading:

- family = `runtime_transaction` for mutation lifecycle
- family = `runtime_consistency` for integrity verification
- family = `runtime_recovery` for boot-time repair and stabilization

Suggested scope mapping:

- `system` → local runtime safety mechanism
- `environment` → broader runtime stabilization context
- `operator` → explicitly requested recovery or rollback surface

Suggested intensity mapping:

- `passive` → regular transaction begin/status

---

## Runtime lock semantic layer

REL-1 introduces a first explicit semantic layer for runtime lock ownership.

The lock is no longer read only as a binary held/free gate.

It now exposes readable ownership fields:

- `state`
- `pid`
- `owner_kind`
- `owner_label`
- `txid`
- `command`
- `created_at`

Reading intent:

- `state` → current lock lifecycle visibility
- `owner_kind` → broad mutation family holding exclusivity
- `owner_label` → human-readable lock owner role
- `txid` → transaction link when mutation is transaction-backed
- `command` → operator-visible command origin

REL-1B refines the reading model:

- a visible transaction may exist without any active lock
- this means the transaction is pending, not corrupted
- a lock should appear only during a real mutation operation
- orphan-lock recovery should therefore indicate interrupted execution, not idle pending state

This prepares future UX surfaces such as:

- lock lifecycle cards
- mutation ownership badges
- deep consistency overlays
- concurrent mutation diagnostics
- `active` → stage/apply/commit flow
- `critical` → rollback, inconsistency, orphan-lock repair, crash recovery
- `narrative` → final stabilized runtime transition worth replaying

---

## UX doctrine for reliability events

Reliability events must remain readable without overwhelming the operator.

The rule is:

- keep session timeline as the narrative source for operator activity
- expose transaction safety as system runtime semantics
- allow recovery events to be replayed when needed
- avoid polluting normal interaction with excessive low-level noise

This prepares future UX surfaces such as:

- runtime safety strips
- rollback incident cards
- recovery timeline reconstruction
- transaction consistency warnings
- differential snapshot previews

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

- gateway = centre cockpit
- agents = satellites runtime actifs
- observer = monitoring cognitif passif

## Temporal dashboard navigation

Navigation minimale :

- curseur focalise un événement
- fenêtre locale autour du focus
- marquage >> pour l’événement actif

Contrôles :

- a = précédent
- d = suivant
- 0 = début
- $ = fin

Statut :

cursor=X window=Y total=Z

## Canonical vs lab surfaces

Canonique :

- moteur temporal
- grammaire agent field
- rendu dashboard

Lab :

- seeds timeline
- démos cockpit
- simulations UX rapides

---

## Future reliability UX projection

As the reliability kernel matures, future UX layers may expose:

- concurrent mutation arbitration indicators
- differential snapshot preview surfaces
- deep consistency verification cards
- agent mutation safety signals
- distributed runtime stabilization signals

These surfaces must remain:

- non-intrusive during normal operation
- replayable during incident analysis
- cognitively compact in dashboard form

Reliability visualization is therefore treated as:

system cognition exposure  
rather than operator activity narration.


## Deep consistency semantic layer — REL-2

REL-2 introduces a higher-order runtime safety semantic layer.

New reliability semantic family:

- `runtime_consistency`

New reliability reading:

- consistency classification events
- crash detection overlays
- recovery confirmation signals
- deep safety badges

Future UX surfaces prepared:

- consistency health cards
- crash-recovery replay ribbons
- runtime safety status strips
- kernel integrity dashboard indicators

Semantic mapping:

- `STRONG` → stable runtime baseline
- `DEGRADED` → soft anomaly requiring attention
- `BROKEN` → critical mutation integrity violation

This layer complements:

- runtime_transaction lifecycle semantics
- runtime_recovery stabilization semantics


## ROUT-4 — Gateway cognitive operator surface

ROUT-4 adds an explicit operator-visible gateway decision layer.

### Canonical gateway state keys

- `KAO_GATEWAY_PROVIDER`
- `KAO_GATEWAY_COGNITIVE_LEVEL`
- `KAO_GATEWAY_CONNECTIVITY`

### Canonical runtime override key

- `KAO_RUNTIME_CONNECTIVITY_MODE`

Allowed values:

- `auto`
- `offline`
- `online`

### UX meaning

The cockpit can now represent not only that routing happened, but why the current route exists.

Operator-visible semantics:

- provider chosen by the gateway
- cognitive difficulty level inferred from the intent
- current effective connectivity state
- optional runtime-forced online/offline override

### Operator commands

The canonical operator surfaces introduced by ROUT-4 are:

- `kao gateway status`
- `kao router status`
- `kao runtime mode status`
- `kao runtime mode set <auto|offline|online>`

### Event-model implication

The gateway becomes a first-class cognitive actor in the interaction loop:

- user intent enters gateway interpretation
- gateway publishes a routing decision
- router executes using the current decision
- runtime state exposes the result to the cockpit

Canonical loop:

- `intent -> gateway_think -> router_act -> runtime_trace`

### UX projection

This prepares future cockpit surfaces such as:

- gateway timeline
- provider switch history
- online/offline transition visibility
- heat mapping of cognitive routing intensity
- future multi-agent or multi-provider competition traces


## ROUT-5 — Router Cognitive Cockpit Surface

ROUT-5 introduces a structured cognitive dashboard for routing decisions.

### Canonical cognitive keys

- `ROUTER_MODE`
- `ROUTER_NETWORK`
- `ROUTER_PROVIDER`
- `ROUTER_AGENT`
- `ROUTER_INTENT`
- `ROUTER_COGNITIVE_LEVEL`
- `ROUTER_CONFIDENCE`
- `ROUTER_LATENCY`
- `ROUTER_HEALTH`

### UX semantics

The cockpit now represents:

- not only that routing happened
- but the internal reasoning posture of the routing system.

### Event-loop projection

Future UX layers may derive:

- routing cognitive timelines
- routing heat-maps
- provider arbitration waves
- session-level routing cognition summaries

ROUT-5 therefore marks the transition from:

gateway observability → routing cognition visibility.


## ROUT-6 — Router Temporal Cognition Surface

Routing decisions now emit timeline events with switch detection flags:

- provider_switch
- level_switch
- mode_switch

This enables operator UX patterns such as:

- detecting routing turbulence
- understanding provider arbitration sequences
- reading routing intent evolution over time.

ROUT-6 establishes the first temporal cognition layer for the Kao router.

