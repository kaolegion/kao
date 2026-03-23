# KAO COGNITION MODEL

## Purpose

This document defines the current V0/V1 cognitive interpretation layer of Kao.

Kao is not only a command surface.
Kao is a runtime that perceives, classifies, and now summarizes its own session lifecycle.

## Current session cognition

The current session cognition model exposes:

- `age_seconds`
- `heat_level`
- `memory`
- `intensity`

These fields are rendered through:

- `kao session status`

## Session lifecycle cognition

Kao currently supports the following cognitive loop:

`OPEN -> LIVE COGNITION -> CLOSE -> MEMORY WRITE -> RECALL -> SUMMARY`

This means that Kao can:

- open a session
- observe heat and intensity while the session lives
- freeze the final state on close
- persist a memory artifact
- recall the last recorded memory
- summarize the last recorded memory in operator-readable form

## Session memory artifact

A session close generates:

- `state/sessions/<session_id>/session.memory`

The current artifact stores:

- `SESSION_ID`
- `CLOSED_AT`
- `AGE_SECONDS`
- `FINAL_HEAT`
- `FINAL_MEMORY_CLASS`
- `FINAL_INTENSITY`

## Session summary layer

Kao now exposes a first summary interpretation layer through:

- `kao session summary`
- `kao session recall --summary`

The current summary renders:

- session duration
- final heat state
- final memory class
- final intensity
- short final interpretation

This establishes the first human-readable cognitive synthesis surface for session memory.

## Thermal graph cognition layer

Kao now has a first validated local thermal graph cognition layer on the KaoBox side.

Current validated properties:

- note heat can be extracted from projected cognitive notes
- heat contributes to ranking through a weak logarithmic signal
- thermal graph propagation can influence nearby graph candidates
- propagation is observable in think trace fields
- ranking remains stable while thermal influence stays perceptible

Current doctrine:

- thermal propagation is local
- propagation remains weak and non-destructive
- graph-context traversal used by `think` is currently depth-bounded and outgoing-only
- this constraint is explicit and should be governed before any future extension

This layer establishes a first cognitive bridge between:

- local memory heat
- graph distance
- explainable ranking behavior

## Next evolution

The next logical step is a richer interpretation layer:

- session phase interpretation
- timeline event count
- active / cooling / idle reading
- future router influence
- graph traversal governance under Kao
- future parametric graph cognition modes

---

