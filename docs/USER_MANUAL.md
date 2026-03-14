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
- ray system repair --dry-run
- ray system repair

Ray exposes routing cognition, safe local inspection, and controlled local repair.

---

## Understand ray system inspect

ray system inspect exposes a deterministic local system diagnostic surface.

It is:

- registry-driven
- read-only
- safe for operator use
- designed for drift detection
- directly aligned with controlled repair actions

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
- prepare and confirm a controlled metadata repair
- understand system integrity without reading shell libraries

---

## Understand ray system repair --dry-run

ray system repair --dry-run previews a controlled metadata repair without mutating the filesystem.

This command:

- reads the same canonical registry baseline
- previews metadata repair only on paths already in `OK` state
- never creates missing paths
- never attempts repair on `MISSING`, `TYPE-MISMATCH` or `UNREADABLE` paths
- exposes these operator outcomes:
  - `NOOP`
  - `DRY-RUN`
  - `SKIP`

Dry-run output shape:

<label> : DRY-RUN | state <state> | drift <drift_signal> | APPLY|owner=<action>|group=<action>|mode=<action> | expected <expected_user>:<expected_group> <expected_mode> | current <real_user>:<real_group> <real_mode> | post-drift <post_drift_signal> | path <real_path>

Reading rule:

- `NOOP` means the path is already aligned
- `DRY-RUN` means a repair would be applied if the real command is executed
- `SKIP` means the path is intentionally excluded in its current state

---

## Understand ray system repair

ray system repair applies the controlled metadata repair for eligible paths.

This command:

- uses the same canonical registry
- acts only on paths already in `OK` state
- repairs only `owner`, `group`, and `mode`
- leaves missing or unreadable targets untouched
- keeps excluded paths visible with `SKIP`

Real repair output shape:

<label> : REPAIRED | state <state> | drift <drift_signal> | APPLY|owner=<action>|group=<action>|mode=<action> | expected <expected_user>:<expected_group> <expected_mode> | current <real_user>:<real_group> <real_mode> | post-drift <post_drift_signal> | path <real_path>

Reading rule:

- `REPAIRED` means a real correction has been applied
- `current` shows the state after the repair action
- `post-drift OK` confirms that the path is now aligned with the registry baseline

Inspection output shape example:

<label> : <state> | owner <real_user>:<real_group> | mode <real_mode> | expected <expected_user>:<expected_group> <expected_mode> | drift <drift_signal> | path <real_path>
