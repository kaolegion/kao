# KAO — Development Workflow

This document defines the canonical development workflow
for Kao surgical terminal-driven development.

It is not a coding guide.

It is an execution discipline.

---

## Core philosophy

Kao development follows:

- terminal-first execution
- explicit reasoning
- deterministic file injection
- immediate verification
- runtime readability
- documentation convergence

Development is treated as:

an operator action,
not an abstract IDE activity.

---

## Sprint execution model

Each sprint must follow strict sequencing.

### Phase 1 — Sprint framing

- announce sprint title
- describe mission and technical intent
- list candidate files
- never inject code before inspection

### Phase 2 — Pre-inspection

- clear terminal
- show working directory
- list target files
- read current file contents
- inspect logs and runtime state if relevant

No modification happens at this stage.

### Phase 3 — Injection

Rules:

- inject one file at a time
- never assume file contents
- re-inspect file immediately before injection
- use deterministic heredoc injection
- chmod executable scripts after injection
- do not clear terminal during a continuous injection phase

### Phase 4 — Verification

- clear terminal at start of verification phase
- inspect modified file
- run syntax checks
- run targeted runtime tests
- run E2E if surface changed

Verification must confirm:

- no regression
- expected behavior visible
- logs remain readable

### Phase 5 — Convergence

- update documentation
- update sprint log file
- confirm runtime vocabulary alignment
- run full validation

---

## Terminal discipline

- clear only at phase transitions
- keep continuous logs inside a phase
- avoid operator fatigue through predictable flow
- preserve visual continuity of reasoning

---

## Deterministic development principles

- never edit blindly
- never inject multiple files in one step
- always verify before continuing
- keep code / docs / runtime aligned
- prefer readable architecture over hidden automation

---

## Long-term goal

This workflow prepares Kao for:

- multi-agent collaboration
- reproducible development sessions
- cognitive traceability of system evolution
- safe integration of real inference capabilities
