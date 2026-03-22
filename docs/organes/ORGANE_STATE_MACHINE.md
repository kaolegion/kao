# ORGANE STATE MACHINE

## Purpose

This document defines the main cognitive states
through which Kao may transition while perceiving,
understanding, validating, and acting.

It provides a readable state model for the narrative organ system.

---

## Core principle

Kao does not move randomly between actions.

The system passes through recognizable states
that reflect increasing levels of attention and engagement.

---

## Canonical states

### 1. IDLE

Meaning:
- no significant event
- stable system posture
- low active demand

Active organs:
- Bloom remains watchful
- Kao preserves continuity

Typical interpretation:
the system is calm and available.

---

### 2. OBSERVING

Meaning:
- a signal has appeared
- the system has noticed a variation
- no deep analysis yet

Active organs:
- Bloom perceives
- Kao raises awareness

Typical interpretation:
something has changed and may require attention.

---

### 3. INVESTIGATING

Meaning:
- the signal requires factual verification
- the real system state must be inspected

Active organs:
- Bloom remains aware
- Rekon inspects

Typical interpretation:
the system is checking reality before concluding.

---

### 4. VALIDATING

Meaning:
- the event may affect trust, integrity, or boundaries
- safety must be assessed before continuation

Active organs:
- Sentinel evaluates safety
- Kao prepares decision

Typical interpretation:
the system is deciding whether the path is safe.

---

### 5. ACTING

Meaning:
- a validated action is necessary
- the system is applying a change

Active organs:
- Syfer executes
- Kao supervises the transition

Typical interpretation:
the system is transforming the real environment.

---

### 6. STABILIZING

Meaning:
- action has ended
- the system is integrating the result
- continuity must be restored

Active organs:
- Bloom resumes calm vigilance
- Kao integrates new state

Typical interpretation:
the system is returning to a stable and coherent posture.

---

## Canonical transition flow

IDLE
→ OBSERVING
→ INVESTIGATING
→ VALIDATING
→ ACTING
→ STABILIZING
→ IDLE

---

## Alternative transitions

### Observation-only path

IDLE
→ OBSERVING
→ INVESTIGATING
→ STABILIZING
→ IDLE

Used when no safety validation and no action are required.

---

### Safety-only path

IDLE
→ OBSERVING
→ INVESTIGATING
→ VALIDATING
→ STABILIZING
→ IDLE

Used when an event is evaluated but no action is approved.

---

### Defensive refusal path

IDLE
→ OBSERVING
→ INVESTIGATING
→ VALIDATING
→ STABILIZING
→ IDLE

Used when Sentinel blocks continuation and Kao preserves integrity.

---

## State philosophy

Each state must remain:

- readable by the operator
- explainable technically
- compatible with real implementation
- consistent with organ roles

---

## Notes

This state machine exists to:

- structure cognitive behavior
- support future runtime implementation
- prevent ambiguous execution flow
- preserve the narrative-real bridge

