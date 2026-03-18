# KAO — Router Runtime Model

This document defines the runtime decision model of the Kao Router.

It specifies how the router evaluates system state,
selects execution paths and preserves runtime stability.

---

## Purpose

The Router runtime model exists to ensure that execution decisions remain:

- deterministic
- state-aware
- inspectable
- safe
- cognitively coherent

---

## Router runtime inputs

The Router evaluates the current situation through the following signal families:

- operator intent
- task nature
- network state
- local capability state
- cloud capability state
- runtime integrity
- memory continuity
- safety constraints

---

## Canonical state signals

### operator_intent

Represents the current explicit operator objective.

Possible examples:

- inspect
- ask
- execute
- repair
- summarize
- recover

### task_nature

Represents the class of work requested.

Current target categories:

- local_read
- local_write
- system_inspect
- system_repair
- cognitive_query
- agent_orchestration
- external_lookup

### network_state

- offline
- limited
- online

### local_capability_state

- unavailable
- partial
- ready

### cloud_capability_state

- unavailable
- degraded
- ready

### runtime_integrity

- strong
- degraded
- broken

### memory_continuity

- continuity
- genesis
- unknown
- fragmented

---

## Router decision layers

The Router evaluates decisions in the following order:

1. safety
2. runtime integrity
3. operator intent
4. task nature
5. local capability
6. cloud capability
7. continuity preservation
8. execution optimization

Higher layers always dominate lower layers.

---

## Canonical execution modes

### os-core

Use only base system capabilities.

Conditions may include:

- no model available
- no network
- local tools sufficient
- safety-first inspection context

### local-cognitive

Use local cognition resources only.

Conditions may include:

- local model ready
- network absent or unnecessary
- sovereignty preferred

### local-first-network-enabled

Prefer local execution while network remains available for extension.

Conditions may include:

- local capability ready
- network online
- task can stay local unless escalation is justified

### cloud-cognitive

Use cloud cognition directly.

Conditions may include:

- local cognition unavailable
- cloud ready
- task requires external intelligence
- safety allows escalation

### hybrid-competitive

Evaluate local and cloud candidates in parallel or by ranked policy.

Conditions may include:

- both local and cloud available
- task value justifies arbitration
- comparison policy enabled

### degraded-safe

Restrict execution to inspection, stabilization and safe local actions.

Conditions may include:

- runtime_integrity degraded
- cloud unavailable
- uncertain capability state
- recovery needed

---

## Safety doctrine

Safety always overrides optimization.

If any of the following is detected:

- runtime_integrity = broken
- repair context active
- ambiguous authority state
- unsafe write context
- capability uncertainty in critical path

The Router must prefer:

- degraded-safe
- read-first execution
- explicit operator confirmation surfaces when implemented

---

## Fallback doctrine

If the preferred mode cannot execute safely:

1. downgrade to the next safer viable mode
2. preserve operator readability
3. preserve traceability
4. avoid silent failure

Fallback order target:

- hybrid-competitive
- local-first-network-enabled
- local-cognitive
- cloud-cognitive
- os-core
- degraded-safe

Actual fallback may vary if safety requires a stricter mode.

---

## Cognitive continuity rules

Router decisions must preserve continuity when possible.

The Router should avoid:

- unnecessary provider switching
- invisible escalation
- context loss across mode changes
- untraceable execution jumps

The Router should prefer:

- stable execution paths
- explicit mode identity
- memory-compatible transitions

---

## Traceability requirements

Each routing decision should eventually expose:

- selected mode
- dominant reason
- rejected alternatives
- safety constraints
- continuity impact

Opaque decisions are non-canonical.

---

## Long-term evolution

The Router runtime model may evolve toward:

- task scoring
- heat-aware arbitration
- session-phase-aware routing
- agent trust weighting
- multi-node routing policy

But the core rule remains:

The Router serves Kao sovereignty before capability expansion.

