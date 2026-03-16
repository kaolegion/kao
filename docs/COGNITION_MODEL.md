# KAO COGNITION MODEL

## Purpose

This document defines the current V0/V1 cognitive interpretation layer of Kao.

Kao is not only a command surface.
Kao is a runtime that perceives and classifies its own session lifecycle.

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

`OPEN -> LIVE COGNITION -> CLOSE -> MEMORY WRITE -> RECALL`

This means that Kao can:

- open a session
- observe heat and intensity while the session lives
- freeze the final state on close
- persist a memory artifact
- recall the last recorded memory

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

## Next evolution

The next logical step is a summary layer:

- human-readable session summary
- session phase interpretation
- richer timeline synthesis
- future router influence
