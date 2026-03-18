# KAO — Live Capture Minimal Design

This document defines the first minimal live capture design for Kao.

Its goal is not full cognitive capture.
Its goal is to prove a safe first pulse of living perception.

---

## Purpose

The minimal live capture design exists to establish a first runtime path for:

- lightweight event sensing
- append-only event recording
- safe operator coexistence
- future perception expansion

This is a bootstrap design.

---

## Minimal doctrine

The first implementation must remain:

- safe
- optional
- low-overhead
- append-friendly
- terminal-first
- easy to disable

Kao must feel alive without becoming invasive.

---

## Minimal architecture image

    TERMINAL ACTIVITY
            ↓
      CAPTURE HOOK
            ↓
      RAW EVENT LINE
            ↓
       APPEND LOG
            ↓
    FUTURE NORMALIZATION

---

## Minimal capture scope

The first minimal layer should capture only a narrow event subset.

Recommended initial event set:

- session_open
- session_close
- command_start
- command_end
- command_fail
- command_interrupt
- tick

This is enough to prove living runtime continuity.

---

## Minimal implementation idea

Possible first implementation surfaces:

- `lib/runtime/live_capture.sh`
- `state/runtime/events.raw.log`

The first layer should append raw lines only.

No heavy interpretation is required at this stage.

---

## Raw line idea

A first raw line may remain simple, for example:

- timestamp
- session id
- event type
- minimal detail

Example shape:

    at=...|session=...|type=command_start|detail=...

Exact syntax may evolve later.

## Trigger surfaces

The minimal design may be connected to a few safe surfaces only:

- session open
- session close
- command dispatch wrapper
- command completion path

Avoid deep key-by-key capture in the first live implementation.

Start with command-level pulse first.

---

## Safety doctrine

The capture layer must never:

- block operator commands
- break shell flow
- require network access
- create heavy disk churn
- introduce noisy output

If capture fails, execution continues.

Capture failure must degrade silently or emit only lightweight trace.

---

## Runtime hygiene

Captured lines belong to runtime state, not source state.

Suggested location:

- `state/runtime/events.raw.log`

This file should be considered:

- append-only
- ephemeral runtime data
- git-ignored
- local diagnostic material

---

## Expansion ladder

Minimal live capture should evolve in this order:

1. command-level pulse
2. session pulse
3. timing anomalies
4. failure clusters
5. paste bursts
6. keystroke rhythm sampling
7. richer perception thresholds

Do not start with maximal granularity.

Grow by stable layers.

---

## Success criteria

The minimal design is considered successful if Kao can:

- append live runtime event lines
- preserve operator flow
- survive capture failure
- expose a readable raw event trail

This proves the first heartbeat of living perception.

---

## Long-term perspective

This minimal design is only the first pulse.

Later layers may add:

- normalized events
- signal bus
- perception scoring
- router awareness hooks
- memory markers

But the canonical first step remains:

Make Kao feel alive with the smallest safe pulse possible.
