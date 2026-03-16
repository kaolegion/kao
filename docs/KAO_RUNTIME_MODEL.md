# KAO — Runtime Model

## Purpose

This document describes the runtime model used by Kao.

It defines:

- the system scene
- the relation between source and runtime
- snapshots
- activation and deactivation
- authority hierarchy
- drift handling
- stable recovery
- future extension toward multi-user and agents

---

## The Kao system scene

Kao exposes a readable system scene.

This scene describes the relation between:

- the host machine
- the Kao system
- the owner authority
- runtime user actors

Each layer has:

- a role
- a responsibility
- an action scope

The machine provides technical environment.

Kao organizes operator action.

The owner governs the system.

Users can be activated in runtime.

Reading the scene correctly makes it possible to:

- understand who acts
- understand what the action affects
- avoid authority conflicts
- maintain system stability

---

## Source and runtime

Kao clearly separates source and runtime.

A source defines a possible configuration.

Runtime represents the currently active state.

A source can:

- exist without being activated
- be inspected without changing the system
- be modified without immediate transition

Runtime corresponds to:

- the active actor
- the current relations
- the already applied decisions

Activating a source causes a runtime transition.

Deactivating an actor changes the system scene.

This distinction helps:

- prepare action safely
- avoid involuntary changes
- stabilize a production system

---

## Snapshot and living state

Runtime is a living state.

It evolves at each operator transition.

Kao can capture that state as a snapshot.

A snapshot represents:

- a system situation at a given instant
- an active actor configuration
- a readable reference for diagnosis or recovery

A snapshot does not act.

It describes.

Runtime acts.

It transforms the system scene.

Comparing a snapshot with runtime helps:

- detect drift
- understand a past transition
- restore operator coherence

---

## Snapshot, transaction and living runtime mutation

Runtime is a living state.

It evolves at each operator transition.

Kao can capture that state as a snapshot.

A snapshot represents:

- a system situation at a given instant
- an active actor configuration
- a readable reference for diagnosis or recovery

A snapshot does not act.

It describes.

Runtime acts.

It transforms the system scene.

Comparing a snapshot with runtime helps:

- detect drift
- understand a past transition
- restore operator coherence

Kao now extends this model with an explicit runtime transaction layer.

This layer is used when a runtime mutation must be:

- staged before apply
- recoverable after crash
- validated before commit
- serialized under lock

The current transaction doctrine introduces:

- a runtime lock
- a pre-mutation snapshot
- a stage directory
- a write-ahead log
- a resource manifest
- a consistency check before commit
- a state-aware recovery path at boot

A transaction currently carries visible fields such as:

- `STATE`
- `BARRIER_STATE`
- `RESOURCE_COUNT`
- `SNAPSHOT_ID`

This makes it possible to distinguish:

- the logical operator transition
- the concrete runtime mutation process
- the recovery position of an interrupted transaction

---

## Runtime transaction states

The current runtime transaction model uses compact explicit states.

Transaction states currently include:

- `open`
- `committing`
- `committed`
- `rolled_back`
- `aborted`

Barrier states currently include:

- `none`
- `staged`
- `apply-running`
- `applied`
- `reverted`

Reading these states correctly makes it possible to know:

- whether a mutation is only prepared
- whether apply has started
- whether commit fully completed
- whether rollback was required
- whether recovery has already stabilized the runtime

The current recovery rule is:

- `open:*` is incomplete
- `committing:*` is incomplete
- `committed:apply-running` is incomplete
- `committed:applied` is stable
- `rolled_back:*` is terminal
- `aborted:*` is terminal

---

## WAL and consistency logic

Kao now uses a local write-ahead transaction record for staged runtime resources.

The WAL records the mutation intent before runtime apply.

For each staged resource, the WAL currently preserves:

- runtime-relative target
- staged file path
- `sha256` checksum
- staging timestamp

The commit path now relies on:

- staged files
- WAL replay order
- checksum verification
- a minimal consistency checker

The consistency checker currently verifies:

- transaction metadata presence
- manifest presence
- WAL presence
- existence of staged files referenced by WAL
- checksum validity for each staged file

This reduces the risk of:

- silent partial apply
- corrupted staged content
- commit on incomplete transaction metadata

---

## Recovery and stable return

A runtime interruption may leave a transaction unfinished.

Kao therefore favors state-aware recovery rather than blind restart.

At boot, recovery currently inspects:

- orphan runtime lock presence
- the last incomplete transaction
- transaction `STATE`
- transaction `BARRIER_STATE`

If an incomplete transaction is found, Kao currently:

- rolls back to the pre-transaction snapshot
- marks the transaction as `aborted`
- sets barrier state to `reverted`
- journals the recovery action

If a transaction is already `committed:applied`, recovery may confirm it as stable.

This keeps the runtime model aligned with operator expectations:

- explicit transitions
- visible recovery
- deterministic stabilization
- no hidden background repair logic

---

## Activation and deactivation

A runtime transition is always explicit.

Activating an actor changes the system scene.

This action:

- changes the active authority
- influences operable decisions
- can create a new system relation

Deactivating an actor reduces active runtime surface.

This makes it possible to:

- return to a stable configuration
- avoid authority conflicts
- prepare a new controlled activation

Kao does not perform implicit activation.

Every important transition should be:

- decided
- visible
- verifiable

---

## Authority hierarchy

Kao relies on a readable authority hierarchy.

This hierarchy makes it possible to know:

- who can act
- on which perimeter
- with which runtime consequences

The host machine provides the technical base.

The Kao system structures operation rules.

The owner is the primary authority.

Users can be activated as runtime actors.

A clear hierarchy helps:

- avoid contradictory actions
- maintain stable governance
- understand a system situation quickly

Each transition must respect that structure.

---

## Runtime drift

Runtime drift is an incoherent or unstable state.

It can appear when:

- an activation is misunderstood
- a source is invalid
- several actors conflict
- a transition is interrupted

Kao treats drift as an operator signal.

It must be:

- visible
- analyzable
- correctable

Reading drift correctly makes it possible to:

- identify problem origin
- restore a clear hierarchy
- return to a stable configuration

The system is designed to be taken back in hand.

---

## Return to stable state

After drift, the operator objective is stabilization.

Stabilizing means:

- identify the real active actor
- verify runtime sources
- deactivate incoherent states
- restore a clear hierarchy

Kao favors progressive recovery.

The operator can:

- reduce runtime to a safe core
- reactivate actors in a controlled way
- verify each transition

A stable system is:

- readable
- predictable
- governable

---

## Extension toward multi-user and agents

The Kao runtime model is designed to evolve.

Today, it allows controlled activation of user actors.

Tomorrow, it may integrate:

- several simultaneous users
- specialized operator agents
- more complex runtime relations

This evolution relies on the same principles:

- readable hierarchy
- explicit transitions
- inspection before action
- operator governance

The current model is a stable base.

It prepares a broader cognitive architecture
without compromising system operability.

## Metrics baseline

Kao now exposes a first baseline metrics surface through `kao metrics`.
This surface tracks hardware/runtime context and documentation growth,
preparing future cockpit, monitoring and cognitive perception layers.
