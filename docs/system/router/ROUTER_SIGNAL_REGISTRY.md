# KAO — Router Signal Registry

This document defines the canonical signal registry used by the Kao Router.

It establishes a stable shared vocabulary for routing perception,
decision logic, traceability and future implementation.

---

## Purpose

The Router signal registry exists to ensure that routing signals remain:

- stable
- readable
- unambiguous
- reusable across layers

A signal must mean the same thing in:

- documentation
- runtime logic
- trace output
- future cockpit surfaces

---

## Signal image

    WORLD
      ↓
    SIGNALS
      ↓
    ROUTER
      ↓
    DECISION
      ↓
    TRACE
      ↓
    MEMORY

---

## Canonical signal families

The Router currently organizes signals into the following families:

- operator
- task
- authority
- runtime
- capability
- continuity
- safety
- outcome

Each family must remain semantically coherent.

---

## Operator signals

### operator_intent

Meaning:

The explicit objective expressed by the operator.

Examples:

- inspect
- ask
- execute
- repair
- summarize
- recover

### operator_override

Meaning:

An explicit operator preference that may constrain routing behavior.

Examples:

- force-local
- force-cloud
- force-safe
- diagnostic-only
- none

---

## Task signals

### task_nature

Meaning:

The class of work requested.

Canonical values may include:

- local_read
- local_write
- system_inspect
- system_repair
- cognitive_query
- agent_orchestration
- external_lookup

### task_scope

Meaning:

The radius of expected impact.

Canonical values may include:

- narrow
- medium
- broad
- critical

## Authority signals

### authority_clarity

Meaning:

Whether the acting authority is clearly identified.

Canonical values:

- clear
- ambiguous
- broken

### authority_level

Meaning:

The operational level of the current actor in relation to the system.

Canonical values may include:

- operator
- owner
- system
- agent

---

## Runtime signals

### network_state

Canonical values:

- offline
- limited
- online

### runtime_integrity

Canonical values:

- strong
- degraded
- broken

### runtime_phase

Meaning:

The current operational phase around the routing event.

Canonical values may include:

- idle
- active
- degraded
- recovery

---

## Capability signals

### local_capability_state

Canonical values:

- unavailable
- partial
- ready

### cloud_capability_state

Canonical values:

- unavailable
- degraded
- ready

### agent_availability

Meaning:

Whether suitable agents are present and callable.

Canonical values may include:

- none
- limited
- ready
- saturated

---

## Continuity signals

### memory_continuity

Canonical values:

- continuity
- genesis
- unknown
- fragmented

### session_heat

Meaning:

Relative cognitive heat of the current session.

Canonical values may later include:

- cold
- warm
- hot
- critical

### routing_stability

Meaning:

How stable the current routing posture is across recent decisions.

Canonical values may include:

- stable
- shifting
- unstable

---

## Safety signals

### safety_posture

Meaning:

The current required safety stance.

Canonical values:

- nominal
- cautious
- constrained
- emergency

### write_risk

Meaning:

The expected mutation risk of the requested action.

Canonical values may include:

- none
- low
- medium
- high

### escalation_need

Meaning:

Whether leaving the current execution mode is justified.

Canonical values:

- no
- optional
- required

---

## Outcome signals

### selected_mode

Canonical values may include:

- os-core
- local-cognitive
- local-first-network-enabled
- cloud-cognitive
- hybrid-competitive
- degraded-safe

### dominant_reason

Meaning:

The primary justification for the selected route.

Examples may include:

- safety
- sovereignty
- local-availability
- cloud-necessity
- continuity
- recovery

### continuity_impact

Canonical values may include:

- preserved
- shifted
- fractured

---

## Registry doctrine

A signal should be:

- singular in meaning
- stable in wording
- reusable across implementations

Signals should not mix:

- state and interpretation
- cause and result
- operator desire and router decision

---

## Long-term evolution

This registry may later extend toward:

- trust-weighted agent signals
- cost-aware provider signals
- federation signals for multi-node Kao
- predictive recovery signals

But the canonical rule remains:

If a signal exists, it must remain intelligible to both operator and system.

