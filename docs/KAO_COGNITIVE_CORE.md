# KAO — Cognitive Core

## Purpose

This document defines the current canonical reading of Kao cognitive core.

It replaces placeholder content and establishes a stable reference for future cognitive work.

---

## 1 — Current reality

The current cognitive core is not yet a fully isolated single subsystem.

However, one layer clearly acts as the strongest candidate:

- `lib/cognition/kao_self_loop.sh`

This layer currently provides:

- local sovereign self-answer capability
- identity-preserving operator answers
- kernel-first prompt framing for escalated inference

---

## 2 — Current cognitive flow

When the operator asks something through Kao, the current high-level cognitive reading is:

1. `bin/kao` receives the operator command
2. `bin/brain` orchestrates cognitive resolution
3. `lib/agents/mission_kernel.sh` may open a governed mission gate
4. `lib/cognition/kao_self_loop.sh` may answer locally
5. `lib/cognition/intent_router.sh` classifies the request
6. `lib/gateway/router.sh` selects the best available provider path
7. provider execution occurs if local sovereign answer is insufficient

---

## 3 — Core doctrine

The cognitive core must remain:

- sovereign-first
- local-first when possible
- explicit
- inspectable
- operator-readable
- identity-preserving

Kao must not answer as an anonymous external tool if local kernel identity can answer truthfully.

---

## 4 — Current weakness

The current cognitive core still depends on raw router state files:

- `state/router/router.cognitive.state`
- `state/router/router.agent.selected`

This makes the current self-loop powerful but not yet fully abstracted.

Future work must introduce a stable self-state interface.

---

## 5 — Current canon

Current cognitive canon reading:

- canonical cognitive orchestration entrypoint: `bin/brain`
- cognitive core candidate: `lib/cognition/kao_self_loop.sh`
- mission governance support: `lib/agents/mission_kernel.sh`
- lexical intent support: `lib/cognition/intent_router.sh`

This means the cognitive core is currently a layered composition, not yet a single isolated engine.

---

## 6 — Future target

The future target is a more stable cognitive architecture where:

- self-state is abstracted
- sovereign answers remain local
- escalation is policy-aware
- cognitive orchestration is decomposed into named stages
- identity is preserved even during LLM escalation
