# KAO — BOOT MODE SWITCH ARCHITECTURE

## Purpose

This document defines how Kao decides which boot perception mode to use.

Boot perception is not static.
It adapts to runtime safety, system maturity, and operator context.

---

## 1 — Available boot modes

Kao currently defines three canonical boot perception modes:

- FULL SCENE
- CALM MODE
- DIAGNOSTIC MODE

These modes must remain deterministic.

---

## 2 — Default decision hierarchy

At activation, Kao evaluates in order:

1. runtime integrity
2. memory continuity
3. system maturity signals
4. operator preference
5. explicit override flags

The first critical signal determines the boot mode.

---

## 3 — Diagnostic mode priority

If any of the following is detected:

- runtime consistency failure
- recovery event
- transaction anomaly
- snapshot incoherence
- degraded gateway

Kao must force:

DIAGNOSTIC MODE

Safety always overrides perception comfort.

---

## 4 — Calm mode conditions

Calm mode may activate when:

- runtime consistency is strong
- memory continuity exists
- no recovery event detected
- operator is considered familiar
- no debug flag active

Calm mode represents a mature stable state.

---

## 5 — Full scene fallback

Full scene is used when:

- first boot is detected
- memory state is genesis
- system maturity is low
- explicit verbosity is requested
- perception training is desired

Full scene is the pedagogical manifestation.

---

## 6 — Explicit operator overrides

Future runtime flags may include:

- `kao --boot-full`
- `kao --boot-calm`
- `kao --boot-diagnostic`

Environment variables may also influence:

- KAO_BOOT_MODE
- KAO_DEBUG
- KAO_SAFE_START

---

## 7 — Long-term evolution

Boot mode selection may later integrate:

- system age
- cognitive heat metrics
- failure history
- distributed node role
- operator behaviour patterns

But safety signals must always remain first.

---

## Canonical principle

Kao does not choose appearance randomly.

Kao manifests according to system truth.

