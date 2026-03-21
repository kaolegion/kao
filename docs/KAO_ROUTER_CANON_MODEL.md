# KAO — Router Canon Model

## Purpose

This document defines the current canonical reading of Kao router architecture.

It does not claim that all layers are already fully unified.

It defines:

- what currently acts as router-related layers
- which layer is canonical
- which layers are transitional
- which layers are candidates for future canonisation

---

## 1 — Current router reality

The current router reality is distributed across multiple layers.

The operator-facing cognitive flow is currently read as:

1. `bin/kao`
2. `bin/brain`
3. `lib/cognition/kao_self_loop.sh`
4. `lib/cognition/intent_router.sh`
5. `lib/gateway/router.sh`
6. `lib/gateway/model_registry.sh`
7. `lib/router/router_dispatch.sh`

This means Kao does not yet have a single unified router-core file.

The router is currently a structured distributed pipeline.

---

## 2 — Canonical layer classification

### Cognitive core candidate

`lib/cognition/kao_self_loop.sh`

Current role:

- sovereign self-answer layer
- local identity response layer
- kernel-first LLM context builder

This layer is currently the strongest candidate for future cognitive-core canonisation.

It must become more stable and less dependent on raw state files.

---

### Gateway control plane

`lib/gateway/router.sh`

Current role:

- provider selection
- provider health surface
- forced-provider logic
- registry bridge
- gateway execution mode surface

This file is not a pure router-core.

It is currently a gateway control plane.

Its responsibilities are wider than routing alone.

---

### Static strategic registry

`lib/gateway/model_registry.sh`

Current role:

- embedded provider catalog
- declared scoring table
- runtime-adjusted provider ranking
- operator-facing registry surface

This file is currently a static registry candidate.

It is not yet a dynamic registry engine.

---

### Transitional dispatch layer

`lib/router/router_dispatch.sh`

Current role:

- gateway intelligence trigger
- behavior trigger
- timeline pulse
- authority pulse

This layer is transitional.

It still ends with legacy execution behavior.

It must not yet be considered the final router execution contract.

---

## 3 — Current source-of-truth rule

Current source-of-truth reading is:

- runtime canon candidate: `lib/runtime/kao-runtime.sh`
- cognitive core candidate: `lib/cognition/kao_self_loop.sh`
- gateway control plane: `lib/gateway/router.sh`
- static registry candidate: `lib/gateway/model_registry.sh`
- transitional dispatch: `lib/router/router_dispatch.sh`

This distinction is currently the canonical interpretation of router architecture.

---

## 4 — Immediate architectural rule

Future work must avoid:

- renaming these layers blindly
- collapsing them without convergence
- introducing new router entrypoints before canonisation

Future work should prioritize:

- stable router-core contract definition
- clearer self-state interface
- separation between selection, policy and execution
- dynamic registry evolution only after observability becomes stable

---

## 5 — Future target

The future target is a cleaner model:

- cognitive core
- router-core
- gateway control plane
- registry engine
- dispatch contract

But the current system has not yet fully reached that state.

This document preserves the truth of the current architecture without pretending premature unification.

---

## 3bis — Router-core contract stage (V0)

A minimal explicit router-core contract stage now exists:

- `lib/router/router_core_contract.sh`

Current role:

- translate cognitive resolution into a stable routing contract
- declare routing intent (self / local-agent / gateway-llm)
- expose next execution transition (stop / dispatch / gateway)
- provide operator-readable routing reason surface

This stage does not yet unify the whole router architecture.

It is an explicit transitional step toward a future unified router-core.

