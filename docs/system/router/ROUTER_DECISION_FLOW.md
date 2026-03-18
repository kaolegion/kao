# KAO — Router Decision Flow

This document describes the real-time operational routing flow of Kao.

It represents how Kao moves from perception to execution.

---

## Frontier decision map

    ┌────────────────────────┐
    │    OPERATOR INTENT     │
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │      TASK SHAPE        │
    │  inspect / ask / run   │
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │      SAFETY CHECK      │
    └───────┬────────┬───────┘
            │        │
         unsafe      safe
            │        │
            ▼        ▼
    ┌──────────────┐  ┌────────────────────────┐
    │ HOLD POSITION│  │   CAPABILITY SCAN      │
    │ degraded-safe│  │ local / cloud / hybrid │
    └──────┬───────┘  └────────────┬───────────┘
           │                       │
           ▼                       ▼
    ┌────────────────┐   ┌─────────────────────┐
    │RUNTIME STABILIZE│   │   MODE SELECTION    │
    │ inspect / repair│   │ os / local / cloud  │
    └────────┬───────┘   └──────────┬──────────┘
             │                      │
             └──────────┬───────────┘
                        │
                        ▼
            ┌──────────────────────────────┐
            │       EXECUTION VECTOR       │
            │ deterministic / readable     │
            │ authority preserved          │
            └──────────────┬───────────────┘
                           │
                           ▼
            ┌──────────────────────────────┐
            │    TRACE + MEMORY WRITE      │
            │    session continuity        │
            └──────────────────────────────┘

---

## Tactical interpretation

Router behavior should resemble:

- reconnaissance before action
- stabilization before expansion
- clarity before speed
- sovereignty before power

---

## Canonical routing rhythm

    PERCEIVE
      ↓
    EVALUATE
      ↓
    CONSTRAIN
      ↓
    SELECT
      ↓
    EXECUTE
      ↓
    TRACE
      ↓
    REMEMBER

---

## Operational doctrine

If Kao cannot ensure:

- safety
- authority clarity
- traceability
- continuity

Then Kao must:

- slow down
- reduce scope
- inspect environment
- remain readable to the operator

---

## Long-term evolution

Future flow extensions may include:

- parallel arbitration lanes
- agent trust corridors
- session heat routing
- distributed node routing
- autonomous stabilization loops

But the canonical rule remains:

Kao must always know why it moves.
