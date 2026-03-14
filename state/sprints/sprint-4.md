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
