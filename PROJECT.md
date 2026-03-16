# KAO — Project Map

## Intent

This file is the canonical high-level map of the Kao project.

Kao is designed as a terminal-first cognitive operator system.

It aims to make technical action:

- visible
- understandable
- inspectable
- deterministic

---

## Core doctrine

Kao must remain:

- terminal-first
- explicit
- deterministic
- readable by humans
- aligned with its documentation

The canonical documentation base is:

- `docs/KAO_MAIN_SOURCE.md`
- `docs/KAO_RUNTIME_MODEL.md`
- `docs/OPERATOR_ONBOARDING.md`
- `docs/USER_MANUAL.md`

---

## Primary entrypoints

- README.md
- PROJECT.md
- docs/README.md
- docs/MANIFESTE.md
- docs/VISION.md
- docs/ARCHITECTURE.md
- docs/KAO_MAIN_SOURCE.md
- docs/KAO_RUNTIME_MODEL.md
- docs/OPERATOR_ONBOARDING.md
- docs/USER_MANUAL.md

Operational command entrypoints currently include:

- `kao`
- `brain`
- `ray`

Gateway-backed and router-backed operator surfaces include:

- `brain infer "<query>"`
- `kao gateway`
- `kao gateway health`
- `kao gateway logs`
- `ray`
- `ray status`
- `ray run "<prompt>"`
- `ray "<prompt>"`

These provide:

- one inference execution path through `brain`
- one full gateway inspection surface through `kao gateway`
- one short readiness cockpit surface through `kao gateway health`
- one short runtime log-tail surface through `kao gateway logs`
- one compact hybrid router surface through `ray`
- one unified routing layer

---

## Governance

Contribution and evolution are structured through:

- CONTRIBUTING.md
- ROADMAP.md
- ISSUES.md
- PULL_REQUESTS.md
- state/sprints/

Documentation convergence must keep code, docs, and runtime vocabulary aligned.

---

## System orientation

Kao is an operator system organized around:

- machine scene
- runtime governance
- authority hierarchy
- explicit transitions
- inspection before action
- repair and stabilization

Its long-term direction is aligned with KaoBox / Brain / Kao-Ray.

---

## Runtime reliability orientation

Kao now includes an explicit runtime reliability kernel.

This layer is responsible for protecting local runtime mutation.

Current runtime reliability surfaces include:

- `lib/runtime/runtime_lock.sh`
- `lib/runtime/snapshot_manager.sh`
- `lib/runtime/runtime_transaction.sh`
- `lib/runtime/runtime_recovery.sh`
- `tests/e2e/scenarios/runtime_surface.sh`

Current runtime reliability model includes:

- orphan-safe runtime lock
- pre-mutation snapshot capture
- multi-resource staging
- WAL-backed transaction intent
- resource manifest tracking
- consistency checking before commit
- state-aware rollback and recovery

This kernel exists to support:

- safer runtime transitions
- future agent-safe mutation
- deterministic boot stabilization
- future reliability UX and replay surfaces
- stronger foundations for cognitive runtime orchestration

The runtime reliability trajectory now points toward:

- stronger commit barriers
- differential snapshots
- concurrency-safe mutation discipline
- deep consistency inspection
- distributed runtime reliability later

---

## Gateway orientation

The gateway layer provides:

- provider routing
- cloud/local execution policy
- secret isolation outside the repository tree
- readable fallback behavior
- operator-visible runtime logs
- cockpit inspection without runtime log pollution
- progressive local provider readiness exposure
- explicit local target-model exposure
- explicit local runtime-state exposure
- explicit local real-call policy exposure
- explicit local callable-state exposure

The current real state includes:

- Mistral cloud provider operational when external secrets are present
- Ollama local provider now exposes readiness states:
  - `unavailable`
  - `local-stub-ready`
  - `local-real-backend-ready`
  - `local-real-ready`
- Ollama local provider now exposes target model states:
  - `unknown`
  - `missing`
  - `ready`
- Ollama local provider now exposes runtime states:
  - `stub-runtime`
  - `real-backend-ready`
  - `real-model-ready`
  - `unavailable`
- Ollama local provider now exposes real-call policy states:
  - `enabled`
  - `disabled`
- Ollama local provider now exposes real-call runtime states:
  - `callable`
  - `blocked-policy`
  - `blocked-no-model`
  - `stub-only`
  - `unavailable`
- controlled real local inference brick present behind explicit policy
- fallback from mistral to ollama implemented
- external secrets expected outside `/home/kao`
- canonical gateway cockpit surfaces active
- runtime inference events written to `state/logs/gateway.log`
- local runtime logs now distinguish attempts, target model, stub paths and real paths

The gateway is evolving toward:

- real local inference execution capability
- adaptive routing between cloud and local execution
- richer runtime observability without increasing operator noise
- a stable foundation for agent orchestration and offline cognition

---

## Ray orientation

Ray is the high-readability operator surface of the hybrid router foundation.

Ray does not replace the gateway.

Ray stands above it and exposes a more compact operator reading.

Ray currently provides:

- selected route visibility
- selected provider visibility
- selected label visibility
- selected kind visibility
- selected health visibility
- operator mode visibility
- hybrid state visibility
- cloud readiness visibility
- local readiness visibility
- preserved access to local ollama model/runtime/policy state
- execution compatibility with `brain infer`

Ray currently distinguishes:

- selected route:
  - `cloud`
  - `local`
  - `none`
- operator mode:
  - `online`
  - `offline`
  - `degraded`
  - `hybrid-ready`
- hybrid state:
  - `hybrid-ready`
  - `cloud-only`
  - `local-only`
  - `unavailable`

Ray prepares Kao for:

- a canonical hybrid router surface
- future multi-provider orchestration
- future model ranking and route ranking
- future agent-oriented operator selection
- a more living cloud/local cognition layer
