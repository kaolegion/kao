# KAO — User Manual

## Purpose of this manual

This manual describes operational use of Kao.

It is intended for a Linux operator who wants to:

- understand how the system works
- execute commands safely
- govern runtime
- diagnose a situation
- stabilize an incoherent state
- understand routing decisions
- understand model registry reading

This manual describes an operable cognitive system.

---

## Canonical inference command

Main inference entrypoint:

- brain infer "<query>"

Execution flow:

1. gateway loads secrets if present
2. gateway evaluates cloud readiness
3. gateway evaluates local readiness
4. gateway computes routing decision
5. gateway reads registry model context
6. gateway executes inference
7. route signal is exposed
8. runtime trace is written to logs

---

## Hybrid router operator surface (ray)

Ray provides a compact **decision-reading surface**.

Commands:

- ray
- ray status
- ray registry
- ray scout
- ray ask "<prompt>"
- ray bridge "<prompt>"
- ray run "<prompt>"
- ray system inspect

Ray exposes routing cognition,
not only provider availability.

Ray also exposes a first readable
internal model registry.

Ray also exposes a first strategic
multi-entry model landscape reading
for ranked registry entries.

Ray now also exposes a first
operator intent classification layer
through `ray ask`.

Ray now also exposes an
intent-aware execution bridge
through `ray bridge`.

Ray now also exposes a first
bounded local execution layer
through `ray run`.

Ray now also exposes a first
safe local system inspection layer
through `ray system inspect`.

---

## Understand ray ask

`ray ask "<prompt>"` now exposes:

- prompt
- intent class
- route family
- action
- execution mode
- strategy
- surface
- decision
- provider

This command is informational.

It does not directly execute the task.

It classifies the operator expression
and shows the current execution bridge reading.

---

## Understand ray bridge

`ray bridge "<prompt>"` exposes the
compact execution bridge state.

It shows:

- intent class
- route family
- action
- execution mode
- strategy
- surface
- provider
- decision
- path id
- path label
- path state
- path sequence

This command is useful to understand:

- whether Kao sees the prompt as local or gateway-oriented
- whether a bridgeable execution strategy exists
- which provider would be used for inference-oriented tasks
- which execution family is retained
- whether a safe canonical local path exists already
- whether the request remains pending or is directly executable

Current execution mode values:

- auto
- local
- cloud

Current decision values:

- routed-execution
- no-execution-bridge

Current execution surfaces:

- gateway
- shell
- system
- none

Current execution strategies:

- gateway-light
- gateway-heavy
- local-exec
- local-inspect
- unclassified

Current path states:

- path-ready
- local-action-pending
- local-inspection-pending
- gateway-ready
- unclassified

Current canonical local paths:

- path-open-directory
- path-list-current-directory

---

## Understand ray run

`ray run "<prompt>"` now runs through the
execution bridge instead of using a blind
single inference path.

Current behavior:

- gateway-oriented tasks are forwarded to `brain infer`
- recognized safe local file tasks are executed through bounded internal sequences
- non-mapped local file or system tasks stay visible and pending

So current `ray run` behaves as:

- cognitive prompt → executed through gateway
- recognized safe local prompt → executed locally through a canonical internal path
- non-recognized local operator prompt → explicit local pending state

Current safe local execution doctrine:

- no unrestricted shell execution
- no free-form command pass-through
- no destructive local path
- explicit operator-visible path before action
- bounded sequence only
- workspace-scoped directory resolution for current implemented directory path

Current implemented safe local paths are:

- `path-open-directory`
  - resolve target from prompt
  - verify target exists under current workspace
  - print resolved path
  - list directory entries
- `path-list-current-directory`
  - resolve current workspace
  - print resolved path
  - list directory entries

This keeps the system deterministic while preparing
future direct local execution growth through a
controlled path library.

---

## Understand ray system inspect

`ray system inspect` exposes a safe
read-only inspection of canonical local paths.

It shows a stable operator surface for:

- root path
- bin directory
- library root
- cognition libs
- system libs
- state directory
- logs directory
- runtime state
- e2e scenarios
- agent registry

Current inspection states are:

- `OK`
- `MISSING`
- `TYPE-MISMATCH`
- `UNREADABLE`

Inspection doctrine:

- registry-driven
- read-only
- deterministic
- no secret exposure
- no mutation
- no auto-repair

Current behavior:

- paths declared in `lib/system/local_paths_registry.sh`
- states computed in `lib/system/system_inspector.sh`
- rendered through `ray system inspect`

This command is useful to:

- validate the local Kao structure quickly
- detect missing expected directories
- inspect local readiness without reading library code directly
- prepare future local doctor and capability scans

---

## Understand ray scout reading

`ray scout` shows the ranked
model landscape in a compact
operator format.

It exposes:

- provider
- model
- family
- maturity
- rank
- status

This view is:

- deterministic
- read-only
- comparative across ranked registry entries
- ordered by registry rank
- independent from routing mutation

Strategic status is currently mapped as:

- elite → dominant
- high → competitive
- medium → viable
- low → incubating
- unknown → experimental

This mapping is informational only.

It does not change routing yet.

---

## Understand ray registry reading

`ray registry` shows the internal canonical model registry.

This registry is:

- deterministic
- local to Kao runtime
- independent from real routing decision
- designed to prepare future ranking logic

Each entry exposes:

- provider
- model
- family (cloud / local)
- base score
- declared state
- runtime state
- runtime score
- operator rank
- maturity level

Declared state reflects
the canonical registry declaration.

Runtime state reflects
the actual runtime situation.

Runtime score is derived from:

- base score
- runtime readiness

Operator rank is derived from:

- runtime score
- declared registry posture

Maturity level gives a compact operator reading such as:

- low
- medium
- high
- elite

These values are **informational only** at this stage.

Routing still follows gateway policy.

---

## Understand ray decision reading

Ray exposes:

### Selected route

- cloud
- local
- none

### Decision state

This describes whether the router
can actually retain a routing decision.

It is distinct from:

- the raw forcing input
- the normalized provider reading
- the global runtime capability
- the registry reading

Possible values:

- route-selected
- no-route-selected
- blocked-unsupported-forcing

---

## Route reason

Explains *why* the route was selected
or why the routing decision is blocked.

Possible values:

- cloud-priority-ready
- local-only-available
- forced-provider-mistral
- forced-provider-ollama
- unsupported-forced-provider
- no-provider-ready

This is the first human-readable decision layer.

---

## Understand routing scores

Ray exposes three compact routing scores:

- cloud score
- local score
- route score

Ray also exposes:

- registry base score
- registry runtime score
- registry operator rank
- registry maturity
