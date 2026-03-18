# KAO — Router State Machine

This document defines the canonical state machine of the Kao Router.

It describes the stable operational states, their meaning, and the allowed transitions.

---

## Purpose

The Router state machine exists to ensure that routing behavior remains:

- deterministic
- observable
- safe
- stable across mode changes

A router must not only choose well.
It must also move coherently between states.

---

## State image

    [IDLE]
      |
      v
    [PERCEIVE]
      |
      v
    [EVALUATE]
      |
      +-------------------+
      |                   |
      v                   v
 [CONSTRAIN]         [DEGRADE]
      |                   |
      v                   v
    [SELECT] --------> [HOLD]
      |
      v
    [EXECUTE]
      |
      v
    [TRACE]
      |
      v
    [RETURN]

---

## Canonical states

### IDLE

The Router is present but not currently arbitrating an active decision.

Meaning:

- no active task arbitration
- stable waiting posture
- ready for perception input

### PERCEIVE

The Router receives and structures the current situation.

Meaning:

- operator intent is read
- task shape is identified
- active signals are collected

### EVALUATE

The Router compares the situation against doctrine and runtime policy.

Meaning:

- safety is checked
- authority clarity is checked
- capability states are examined
- continuity impact is estimated

### CONSTRAIN

The Router applies necessary limits before selecting a mode.

Meaning:

- unsafe scope is reduced
- degraded situations are narrowed
- escalation boundaries are enforced

### DEGRADE

The Router detects that normal execution cannot proceed safely.

Meaning:

- unstable runtime
- ambiguous authority
- broken integrity
- contradictory capability signals

### HOLD

The Router intentionally pauses expansion and preserves stability.

Meaning:

- inspection first
- repair first
- no unsafe progression
- readable restraint posture

### SELECT

The Router chooses the execution mode.

Possible outcomes include:

- os-core
- local-cognitive
- local-first-network-enabled
- cloud-cognitive
- hybrid-competitive
- degraded-safe

### EXECUTE

The selected path is activated.

Meaning:

- execution begins
- mode identity must remain readable
- silent jumps are forbidden

### TRACE

The Router records the routing event.

Meaning:

- mode selected
- reason
- constraints
- continuity impact
- rejected alternatives when relevant

### RETURN

The Router exits the active arbitration loop.

Meaning:

- control returns to stable posture
- memory continuity is preserved
- next decision may begin from a clean readable state

---

## Canonical transitions

Allowed primary transitions:

- IDLE -> PERCEIVE
- PERCEIVE -> EVALUATE
- EVALUATE -> CONSTRAIN
- EVALUATE -> DEGRADE
- CONSTRAIN -> SELECT
- DEGRADE -> HOLD
- HOLD -> RETURN
- SELECT -> EXECUTE
- EXECUTE -> TRACE
- TRACE -> RETURN
- RETURN -> IDLE

Transitions must remain explicit.

---

## Forbidden behavior

The Router should never:

- jump directly from PERCEIVE to EXECUTE
- execute without evaluation
- escalate without traceability
- leave degraded situations without readable hold logic
- switch modes invisibly during execution

---

## Tactical reading

This state machine expresses a frontier doctrine:

- perceive before movement
- constrain before power
- hold before failure
- trace before forgetting

---

## Long-term evolution

The state machine may later include:

- PARALLEL_COMPARE
- TRUST_WEIGHT
- SESSION_HEAT_CHECK
- MULTI_NODE_SYNC
- RECOVERY_AUTONOMY

But the canonical operational chain remains:

IDLE -> PERCEIVE -> EVALUATE -> CONSTRAIN/DEGRADE -> SELECT/HOLD -> EXECUTE -> TRACE -> RETURN

