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

Current governance locks:

- state/runtime/runtime.snapshot is treated as ephemeral runtime state and ignored by Git
- state/runtime/session.current is treated as ephemeral runtime state and ignored by Git
- state/runtime/session.history is treated as ephemeral runtime state and ignored by Git
- state/runtime/session.timeline is treated as ephemeral runtime state and ignored by Git
- board/runtime/ is treated as ephemeral KSL runtime output and ignored by Git
- board/health/ and board/id/ are treated as ephemeral local runtime output and ignored by Git
- state/e2e/ is treated as local validation log output and ignored by Git

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

### Understand ray status governance fields

`ray status` now exposes a readable runtime governance layer.

New visible fields include:

- `network state`
- `local llm state`
- `cloud llm state`
- `execution mode`
- `selection policy`

Reading rules:

- `network state` tells whether Kao currently sees the machine as `online` or `offline`
- `local llm state` tells whether a local LLM path is currently present in the runtime state
- `cloud llm state` tells whether a cloud LLM path is currently available
- `execution mode` summarizes the current operating situation
- `selection policy` shows the current governance policy used for provider selection

Current execution modes may include:

- `os-core`
- `local-cognitive`
- `local-first-network-enabled`
- `cloud-cognitive`
- `hybrid-competitive`
- `state-mixed`

Current selection policy:

- `best-available-by-state`

Important reading note:

- a provider such as `mistral` may appear as selected because it is the best currently available candidate
- this does not mean that Kao defines a permanent cloud-first doctrine
- the target model is state-aware selection based on current availability and, later, on task value

Runtime expression currently used in design:

- `(Device + kaoOS = on) + (LLM + @ = off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ off) + moi`
- `(Device + kaoOS = on) + (LLM local on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local off & cloud on + @ on) + moi`
- `(Device + kaoOS = on) + (LLM local & cloud + @ on) + moi`

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

---

## Understand kao status and kao hud

Kao now exposes direct KSL operator surfaces from the main `kao` entrypoint.

Main commands:

- `kao status`
- `kao hud`
- `kao session recall`
- `kao session recall --summary`
- `kao session summary`

Reading rules:

- `kao status` renders the compact KSL bar for the current runtime state
- `kao hud` renders the live KSL stream derived from runtime events
- these commands read derived KSL state, they do not replace the canonical session timeline
- these commands are intended for immediate operator perception

Visible KSL domains include:

- session lifecycle

## Understand session recall and session summary

Kao now exposes two complementary memory reading surfaces:

- `kao session recall`
- `kao session summary`

Reading rules:

- `kao session recall` reads the last raw persisted session memory
- `kao session recall --summary` reads the same memory through the cognitive summary layer
- `kao session summary` is the direct operator shortcut for the summary view

Current summary fields include:

- session duration
- final heat
- final memory class
- final intensity
- short end-state interpretation

Operational meaning:

- recall preserves the raw artifact
- summary exposes the first readable meaning layer for the operator
- network state
- router selection
- agent execution
- memory heat

Important governance note:

- `board/runtime/ksl-timeline.log`
- `board/runtime/ksl-hud.stream`
- `board/runtime/ksl-cognitive.state`

are derived local runtime artifacts and are not treated as canonical versioned source.

---
## Understand ray session

Kao now exposes a readable runtime session surface.

Main commands:

- `ray session`
- `ray session open`
- `ray session close`
- `ray session history`
- `ray session timeline`

Reading rules:

- `ray session` shows the current active runtime session
- `ray session open` ensures that a session exists and starts duration tracking
- `ray session close` archives the current session into history and closes it
- `ray session history` shows recent closed sessions
- `ray session timeline` shows the canonical event stream for session activity

Visible fields include:

- `id`
- `start`
- `last`
- `duration`
- `machine`
- `user`
- `internet`
- `llm`
- `gateway`
- `agents`

Operational note:

- `id` identifies the active or closed session snapshot lineage
- `last` reflects the most recent visible event on the active session
- `internet` reflects the current online/offline reading
- `llm` summarizes the active cognition source as `cloud`, `local`, or `none`
- `gateway` reflects the current principal route/provider context
- `agents` accumulates the secondary surfaces used during the session

Session closure behavior:

- `ray session close` appends a readable compact entry to `state/runtime/session.history`
- `ray session close` also writes a dedicated closed snapshot into `state/sessions/`
- the runtime history remains readable in one place while each closed session keeps its own preserved state file

Timeline behavior:

- `ray session timeline` reads `state/runtime/session.timeline`
- timeline lines use the canonical prefix `SESSION_EVENT`
- each event keeps a stable nomenclature: `at`, `session_id`, `type`, `machine`, `user`, `internet`, `llm`, `gateway`, `agents`, `detail`
- this format is optimized for shell inspection, grep, tail, and future UX timeline mapping

Types currently emitted:

- `session-open`
- `session-touch`
- `session-close`

During `ray run`, Kao now renders a small breathing block before execution so the operator can read the current runtime cognitive state directly in the terminal.

Runtime hygiene extension:

- `state/runtime/session.current` is treated as ephemeral local runtime state and ignored by Git
- `state/runtime/session.history` is treated as ephemeral local runtime state and ignored by Git
- `state/runtime/session.timeline` is treated as ephemeral local runtime state and ignored by Git
- `state/sessions/` is treated as ephemeral local runtime state and ignored by Git

## Understand ray timeline query

Kao now exposes a cognitive timeline query surface.

Main commands:

- ray timeline last  
- ray timeline grep <text>  
- ray timeline sessions  
- ray timeline agents  
- ray timeline events  
- ray timeline cognitive  
- ray timeline providers  
- ray timeline filter <field> <value>  

Reading rule:

- this surface does not mutate runtime  
- it acts as an exploration tool over canonical timeline events  
- it helps the operator reconstruct cognitive flow  

Typical operator usage:

- identify which agents were active in a work cycle  
- detect heavy reasoning phases  
- inspect provider usage patterns  
- isolate a specific session narrative  


## kao pulse

Commande de diagnostic cognitif rapide.

Affiche :
- l'acteur runtime actif
- l'état réseau
- la gateway sélectionnée
- la disponibilité cloud
- la présence ou l'absence d'un LLM local
- la dernière autorité décisionnelle connue

Usage :

```bash
kao pulse
clear

echo "========================================"
echo "DIVERGENCE FINALE — UX MICRO-SURFACE"
echo "DOC-1 — INJECTION"
echo "========================================"

cd /home/kao || exit 1
mkdir -p state/sprints

cat <<'EOF' >> docs/USER_MANUAL.md


Le prompt terminal Kao expose en continu une lecture compacte du runtime :

- acteur actif
- gateway actuelle
- état réseau

Exemple :

    [KAO:owner|cloud|online]

Cette surface sert de repère permanent pour l'opérateur.

---

## Understand runtime signals

Kao exposes a runtime perception surface:

- `kao runtime signals`

This command renders a synthetic readable stream of runtime stability events.

Reading intent:

- understand recent system mutations
- detect safety-relevant transitions
- observe runtime awareness signals

Runtime signals are:

- derived runtime perception artifacts
- ephemeral and not part of versioned source
- complementary to session timeline and runtime journal

