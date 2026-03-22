# ORGANE SIGNAL REGISTRY

## Purpose

This document defines the main categories of real system signals
that may enter Kao cognitive organ flow.

It provides a readable bridge between:

- kernel / runtime events
- operator-visible interpretation
- organ activation logic

---

## Core principle

A signal is a real event surface.

It may come from:
- hardware
- filesystem
- process lifecycle
- network
- runtime state
- user activity

A signal becomes cognitively meaningful
when it is perceived, interpreted, and integrated.

---

## Signal classes

### 1. Hardware signals

Examples:
- USB device inserted
- storage mounted
- device disconnected
- battery state change
- thermal alert

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel if integrity or trust boundary is affected

---

### 2. Filesystem signals

Examples:
- file created
- file deleted
- config changed
- permission changed
- suspicious mount content

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel for sensitive paths
- Syfer for validated repair or mutation

---

### 3. Process signals

Examples:
- process start
- process stop
- repeated crash
- unknown daemon
- service restart

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel if process threatens system integrity
- Syfer if restart or containment is validated

---

### 4. Network signals

Examples:
- network online
- network offline
- DNS change
- route instability
- suspicious external reachability

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel if trust boundary is affected
- Syfer if runtime mode adaptation is required

---

### 5. Runtime signals

Examples:
- provider fallback
- state divergence
- high cognitive heat
- session cooling
- journal anomaly

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel only when safety or integrity is involved
- Syfer only if a validated action is needed

---

### 6. User signals

Examples:
- operator command
- explicit mutation request
- repeated failed command
- request for inspection
- request for recovery

Primary organ:
- Bloom

Secondary organ:
- Rekon

Escalation:
- Sentinel before sensitive execution
- Syfer after validated decision

---

## Signal flow interpretation

Signal appears
→ Bloom perceives
→ Rekon verifies real conditions
→ Sentinel validates safety if needed
→ Syfer executes if action is approved
→ Kao integrates meaning and continuity

---

## Notes

This registry exists to ensure that:

- narrative remains grounded in real signals
- organs remain connected to runtime reality
- future implementation keeps a stable cognitive vocabulary

