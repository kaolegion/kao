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

## Runtime hygiene doctrine

Kao distinguishes clearly between:

- versioned source
- ephemeral runtime state

Versioned source includes:

- code
- libraries
- documentation
- E2E scenarios
- sprint logs

Ephemeral runtime state includes:

- execution logs
- runtime snapshots
- temporary validation state
- local diagnostic traces

Operator rule:

- runtime may mutate during validation and normal usage
- runtime mutation is not a source change
- a runtime artifact should not pollute git status
- the repository must end clean after sprint validation

Current governance lock:

- state/runtime/runtime.snapshot is treated as ephemeral runtime state and ignored by Git

---

## Hybrid router operator surface (ray)

Main inspection commands:

- ray status
- ray registry
- ray scout
- ray ask "<prompt>"
- ray bridge "<prompt>"
- ray run "<prompt>"
- ray system inspect

Ray exposes routing cognition and safe local inspection.

---

## Understand ray system inspect

ray system inspect exposes a deterministic local system diagnostic surface.

It is:

- registry-driven
- read-only
- safe for operator use
- designed for drift detection
- designed for future controlled repair tooling

The inspection is based on:

- lib/system/local_paths_registry.sh
- lib/system/system_inspector.sh

Each canonical path exposes:

- state
- real owner
- real group
- real mode
- expected owner
- expected group
- expected mode
- drift signal
- real resolved path

Possible state values:

- OK
- MISSING
- TYPE-MISMATCH
- UNREADABLE

Possible drift values:

- OK
- DRIFT:owner
- DRIFT:group
- DRIFT:mode
- combined compact forms such as DRIFT:owner,group,mode

If the path is missing:

- owner = n/a
- mode = n/a
- drift = n/a

Operator usage goals:

- detect installation ownership inconsistencies
- detect permission drift after root operations
- validate filesystem governance baseline
- prepare a future runtime repair action
- understand system integrity without reading shell libraries

Output shape example:

<label> : <state> | owner <real_user>:<real_group> | mode <real_mode> | expected <expected_user>:<expected_group> <expected_mode> | drift <drift_signal> | path <real_path>

