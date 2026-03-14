# SPRINT KSL 1.6 — Kao Signal Language + Session-Derived HUD Surface

## Mission

Introduce a canonical Kao Signal Language layer derived from runtime session events.

## Goal

Allow an operator to:

- read a compact signal representation of runtime state
- observe session lifecycle transitions through KSL
- observe router selection through KSL
- observe agent completion through KSL
- expose a local HUD-oriented stream without turning runtime artifacts into versioned source

## Scope

Versioned implementation now includes:

- `lib/ksl/ksl_engine.sh`
- `lib/ksl/ksl_render.sh`
- `lib/ksl/ksl_timeline.sh`
- `lib/ksl/ksl_mapping.env`
- `lib/ksl/ksl_priority.sh`
- `lib/ksl/ksl_hierarchy.sh`
- `lib/ksl/ksl_bar.sh`
- `lib/runtime/ksl_hook.sh`
- `lib/runtime/session_manager.sh`
- `bin/kao`
- `bin/kao-hud`
- `bin/kao-status`
- `tests/e2e/lib_e2e.sh`
- `tests/e2e/scenarios/ray_session_timeline_v2.sh`
- `docs/lab/ksl/KSL-LAB-MANIFESTE.md`

## Validation target

Validation must confirm:

- session timeline remains canonical and grep-friendly
- KSL signals are mapped deterministically from runtime events
- no active `UNKNOWN` signal remains in rebuilt runtime artifacts
- `kao status` exposes a compact KSL bar
- `kao hud` exposes a readable KSL stream
- session-derived KSL state closes cleanly after session close
- runtime artifacts remain outside canonical versioned source

## Delivered operator surface

The sprint now exposes:

- `ray session`
- `ray session open`
- `ray session close`
- `ray session history`
- `ray session timeline`
- `kao status`
- `kao hud`

## Runtime doctrine locked by this sprint

The following areas are runtime-local and not canonical source:

- `board/runtime/`
- `board/health/`
- `board/id/`
- `state/e2e/`
- `state/runtime/session.current`
- `state/runtime/session.history`
- `state/runtime/session.timeline`
- `state/sessions/`

The following areas remain canonical source:

- shell libraries under `lib/`
- CLI entrypoints under `bin/`
- documentation under `docs/`
- E2E scenarios under `tests/e2e/`
- sprint history under `state/sprints/`

## KSL semantic model

KSL acts as:

- a signal language
- a local HUD protocol
- a session-derived runtime state encoder
- a bridge between narrative timeline and perceptual operator surface

Current signal families include:

- session lifecycle
- network state
- routing selection
- agent activity
- memory heat

Typical signals now visible include:

- `•/SYS/active/i2/blink-triple/session`
- `⌁/NET/active/i2/pulse-slow/network`
- `◆/NET/success/i2/hold/router:cloud`
- `◆/SYS/fallback/i3/blink-triple/router`
- `▮/ACT/success/i1/fade/agent`
- `•/SYS/success/i1/fade/session`

## E2E convergence result

Validation now confirms:

- timeline prefix `SESSION_EVENT|` remains preserved
- semantic detail enrichment remains visible
- derived KSL HUD stream is written
- derived KSL cognitive state is written
- repeated steady operator surfaces do not duplicate cloud route infinitely
- repeated steady operator surfaces do not duplicate online network infinitely
- session close derives `agent.done`
- session close derives `session.end`
- final KSL state returns to inactive / session-closed

## Operator result

A human operator can now understand quickly:

- whether a session is opening, steady, or closing
- whether the network is online or degraded
- whether the router selected cloud, local, or fallback-local
- whether an agent is running or has completed
- whether the system is exposing a hot or warm memory state
- which layer is narrative source and which layer is HUD-derived runtime output

## Residual historical note

During lab evolution, one historical `UNKNOWN/router.fallback_local` trace existed before mapping coverage was complete.

This was confirmed as a historical residue only.

After runtime purge and verified rebuild:

- active runtime artifacts no longer expose unknown KSL signals
- `router.fallback_local` resolves canonically to `◆/SYS/fallback/i3/blink-triple/router`

## Sprint lock result

Kao now has:

- a native signal language
- a readable KSL runtime bar
- a live KSL HUD stream
- a deterministic bridge from session events to signal state
- a cleaner distinction between canonical source and ephemeral runtime perception

This sprint locks the first real KSL operator surface for future UX evolution.

# SPRINT UX/KSL 1.7 — Signal Surface Expansion + Dashboard Semantics

## Mission

Expand KSL from a compact signal layer into a richer dashboard-readable semantic surface.

## Goal

Allow an operator to:

- read not only the signal itself but also its dashboard meaning
- understand role, scope, visible state, pattern and target at a glance
- keep the canonical runtime timeline intact while enriching the derived HUD layer
- prepare future radar, agent field and temporal navigation surfaces without breaking shell simplicity

## Scope

Versioned implementation now extends:

- `lib/ksl/ksl_engine.sh`
- `lib/ksl/ksl_mapping.env`
- `lib/ksl/ksl_render.sh`
- `lib/ksl/ksl_timeline.sh`
- `bin/kao-hud`
- `bin/kao-status`
- `docs/UX_EVENT_MODEL.md`
- `docs/ARCHITECTURE.md`
- `state/sprints/sprint-4.md`

## Semantic extension delivered

KSL derived surfaces now expose:

- `role`
- `scope`
- `state`
- `pattern`
- `object`

Current dashboard roles include:

- `presence`
- `context`
- `decision`
- `execution`
- `memory`
- `state`

Current dashboard scopes include:

- `local`
- `session`
- `global`

## Operator surface result

The sprint now improves:

- `kao hud` with semantic stream columns
- `kao status` with last semantic dashboard context
- KSL timeline readability for future dashboard grouping

## Doctrine locked by this sprint

This sprint keeps the rule:

- session timeline remains the narrative canonical source
- KSL board surfaces remain derived runtime-local perception
- dashboard semantics enrich reading without replacing shell stability

## Expected validation

Validation should confirm:

- shell syntax remains valid
- emitted KSL timeline lines now include role and scope
- HUD stream rows expose state, pattern and role coherently
- `kao status` exposes last semantic context without breaking bar rendering
- runtime-local board artifacts stay derived and non-versioned

## Product result

Kao now moves one step closer to a true cognitive dashboard language:

- compact enough for terminal use
- semantic enough for future HUD/TUI
- structured enough for replay, grouping and visual navigation
- still grounded in the canonical session runtime doctrine

## UX/KSL 1.8 — Dashboard temporal navigation + agent field surface

Sprint result:

- canonical temporal navigation engine with cursor and focus window
- canonical agent field engine with role/state/slot/signal grammar
- terminal dashboard surface merging temporal window, agent field, and projection
- interactive keyboard loop for temporal navigation
- dynamic synchronization between temporal cursor and agent field phase (`past`, `present`, `future`)

Validation result:

- shell syntax valid for temporal navigation, agent field, and dashboard surfaces
- dashboard demo renders temporal focus window with status line
- dashboard agent field reflects temporal phase
- projection signal remains visible in the cockpit surface

## STRUCTURE 1.1 — Demo extraction from canonical KSL surfaces

Result:

- canonical KSL files now keep runtime-facing logic only
- demo helpers were extracted into `lib/ksl/lab/`
- canonical dashboard and agent field files remain executable
- lab area now hosts isolated demo scripts without polluting the canonical layer

## STRUCTURE 1.2 — Docs convergence for canonical vs lab separation

Result:

- architecture documentation now distinguishes canonical KSL surfaces from lab surfaces
- UX event documentation now reflects the separation between stable cockpit logic and demo experimentation
- sprint log records the structural cleanup as part of Kao maturation

# SPRINT RELIABILITY 1.2 — Runtime WAL + Multi-Resource Transaction Engine

## Mission

Transform the runtime mutation layer into a crash-safe transactional engine.

## Goal

Allow Kao to:

- stage multiple runtime resources safely
- journal mutation intent before apply
- validate consistency before commit
- recover deterministically after crash or power loss
- expose reliability semantics for future UX surfaces

## Scope

Versioned implementation includes:

- `lib/runtime/runtime_lock.sh`
- `lib/runtime/snapshot_manager.sh`
- `lib/runtime/runtime_transaction.sh`
- `lib/runtime/runtime_recovery.sh`
- `tests/e2e/scenarios/runtime_surface.sh`
- runtime extensions in `bin/kao`

## Reliability mechanisms introduced

The runtime engine now provides:

- single mutation lock with orphan detection
- pre-transaction snapshot capture
- multi-resource staging directory
- per-transaction WAL file
- compact resource manifest
- consistency checker before commit barrier
- state-aware boot recovery logic
- recovery timeline journaling

## Transaction state model

Transactions now expose:

- lifecycle state (`open`, `committing`, `committed`, `rolled_back`, `aborted`)
- barrier state (`none`, `staged`, `apply-running`, `applied`, `reverted`)
- resource counter for staged mutation scope

## Recovery doctrine

Boot recovery now:

- inspects orphan locks
- detects incomplete transactions
- rolls back to snapshot baseline when required
- marks reverted transactions explicitly
- journals recovery timeline actions

## Operator result

The operator can now rely on:

- deterministic runtime stabilization after interruption
- visible mutation intent through WAL traces
- safer multi-file runtime transitions
- future UX reliability visualization potential

## Product impact

This sprint establishes:

- the first kernel-grade reliability layer of Kao runtime
- a foundation for differential snapshot strategies
- a base for recovery timeline navigation
- a prerequisite for concurrent agent mutation control

