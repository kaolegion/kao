# ORGANE DECISION MATRIX

## Purpose

This document formalizes how Kao makes decisions
based on perceived signals, verified context, and evaluated risk.

It defines when the system:

- observes
- validates
- acts
- blocks
- adapts

It is the governance layer of cognitive behavior.

---

## Core decision chain

Signal appears  
→ Bloom perceives  
→ Rekon verifies real conditions  
→ Sentinel evaluates safety if needed  
→ Kao decides  
→ Syfer executes if action is approved  

---

## Decision levels

### Level 0 — Passive observation

Context:
- no anomaly
- stable runtime
- expected variation

Behavior:
- no escalation
- no mutation

Outcome:
- Kao integrates state silently

Example:
- normal log variation
- expected file creation

---

### Level 1 — Awareness escalation

Context:
- unusual pattern
- repeated small anomaly
- degraded performance

Behavior:
- Rekon deeper inspection
- system awareness increased

Outcome:
- Kao monitors evolution

Example:
- CPU spike
- repeated warning logs

---

### Level 2 — Safety validation

Context:
- trust boundary crossing
- permission-sensitive operation
- unknown runtime behavior

Behavior:
- Sentinel evaluates system safety

Outcome:
- Kao may allow continuation or request more inspection

Example:
- USB mount
- new external connection
- unknown daemon

---

### Level 3 — Controlled action

Context:
- validated need for change
- safe mutation opportunity
- operator confirmed decision

Behavior:
- Syfer executes targeted action

Outcome:
- Kao integrates mutation result

Example:
- restart service
- apply configuration
- recover degraded component

---

### Level 4 — Defensive block

Context:
- integrity threat
- unsafe mutation request
- confirmed intrusion signal

Behavior:
- Sentinel blocks action
- Kao preserves system boundaries

Outcome:
- system continuity protected

Example:
- suspicious permission escalation
- malicious script attempt

---

## Decision philosophy

The system does not act impulsively.

It follows:

- perception
- understanding
- validation
- decision
- execution

---

## Notes

This matrix ensures:

- coherent governance
- predictable reactions
- safe evolution of the system
- readable operator mental model

