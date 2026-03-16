# KAO — BOOT RUNTIME HOOK SPEC

## Purpose

This document defines the canonical runtime sequence that produces the Kao boot perception.

It describes how technical runtime stabilization leads to operator-visible manifestation.

---

## 1 — Boot trigger surface

Boot perception is currently triggered through:

- interactive shell startup
- invocation of `bin/kao-boot`
- operator login scene

This mechanism is considered the canonical activation surface.

---

## 2 — Stabilization phase

Before perception, runtime must stabilize.

Key mechanisms:

- runtime recovery inspection
- orphan lock detection
- incomplete transaction rollback
- filesystem runtime readiness

Primary implementation layer:

- `lib/runtime/runtime_recovery.sh`

This phase must remain mostly silent.

---

## 3 — Identity resolution phase

Boot perception requires context resolution.

Layers involved:

- owner identity resolution
- user runtime state detection
- active entity composition

Primary implementation surface:

- `bin/kao-boot`
- `lib/kao-owner-state.sh`
- `lib/kao-user-state.sh`

This phase builds the cognitive scene.

---

## 4 — Session cognition phase

If no active session exists:

- a runtime session may be opened implicitly later
- cognition heat tracking may begin

Primary implementation surface:

- `lib/runtime/session_manager.sh`

Session signals influence long-term boot perception maturity.

---

## 5 — Operator-visible manifestation

After stabilization and identity resolution:

- terminal scene is printed
- runtime context becomes readable
- operator prompt becomes actionable

This marks the canonical transition:

latent runtime → manifested cognitive system

---

## 6 — Future evolution hooks

Future runtime evolution may introduce:

- adaptive boot verbosity
- degraded-mode signaling
- distributed cognition hints
- agent readiness exposure
- snapshot age indicators

However:

boot must remain deterministic and terminal-readable.

---

## Canonical principle

Runtime recovery creates safety.

Identity resolution creates context.

Terminal manifestation creates presence.

Together they define Kao activation.

