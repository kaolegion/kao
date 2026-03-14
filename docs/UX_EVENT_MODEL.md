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

---

## Intensity layer

Current intensity meanings:

- `passive` → low-friction operational trace
- `active` → meaningful visible operator activity
- `critical` → repair / safety / strong intervention
- `narrative` → structural timeline moment

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

## Current UX mapping intent

This semantic model prepares future:

- timeline cards
- live TUI event panels
- session replay nodes
- HUD layers
- cognitive heat / activity filters

The current rule is:

- do not replace the shell timeline
- enrich it until visual layers can consume it directly

---

## Implementation sources

Current implementation files:

- `lib/runtime/session_manager.sh`
- `lib/runtime/event_normalizer.sh`
- `config/event_taxonomy.env`

Validation surfaces:

- `ray session timeline`
- `tests/e2e/scenarios/ray_timeline.sh`
- `tests/e2e/scenarios/ray_session_timeline_v2.sh`

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

