# KAO — BOOT STATE DECISION MATRIX

## Purpose

This document defines the operational decision matrix used by Kao at boot time.

It translates architectural intent into deterministic runtime logic.

Boot perception must be reproducible across environments.

---

## 1 — Primary signals

Boot mode decision is based on four primary signals:

- runtime_integrity
- memory_state
- recovery_event
- operator_override

Signals must be evaluated in deterministic order.

---

## 2 — Signal states

### runtime_integrity

- strong
- degraded
- broken

### memory_state

- continuity
- genesis
- unknown

### recovery_event

- yes
- no

### operator_override

- full
- calm
- diagnostic
- none

---

## 3 — Decision priority

Decision hierarchy:

1. operator_override
2. recovery_event
3. runtime_integrity
4. memory_state

Higher priority signals always dominate.

---

## 4 — Canonical decision matrix

### Diagnostic mode

Activated when:

- operator_override = diagnostic
- OR recovery_event = yes
- OR runtime_integrity = broken

Result:

BOOT_MODE = DIAGNOSTIC

---

### Calm mode

Activated when:

- operator_override = calm
OR
- runtime_integrity = strong
- AND memory_state = continuity
- AND recovery_event = no

Result:

BOOT_MODE = CALM

---

### Full scene mode

Activated when:

- operator_override = full
OR
- memory_state = genesis
OR
- runtime_integrity = degraded
OR
- memory_state = unknown

Result:

BOOT_MODE = FULL

---

## 5 — Fallback rule

If signals are inconsistent:

- Kao must select the safest mode
- which is DIAGNOSTIC

Safety always overrides aesthetics.

---

## 6 — Future signal extensions

Matrix may later integrate:

- system_age
- cognitive_heat
- failure_history
- distributed_role
- operator_trust_level

However, the primary four-signal model must remain valid.

---

## Canonical principle

Boot perception is not cosmetic.

Boot perception is a runtime truth projection.

