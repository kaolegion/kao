# KAO

Kao is a terminal-first operator system rooted at `/home/kao`.

It is built to structure runtime cognition between:

- machine
- system
- owner
- operator channel

## Foundational principle

Kao exists to make technical action:

visible, understandable and controllable.

## Project orientation

Start reading:

- PROJECT.md
- docs/MANIFESTE.md
- docs/VISION.md

## Fast entrypoints

Primary operator entrypoints include:

- `kao`
- `brain`
- `ray`

The current canonical gateway and router entrypoints are:

- `brain infer "<query>"`
- `kao gateway`
- `kao gateway status`
- `kao gateway health`
- `kao gateway logs`
- `ray`
- `ray status`
- `ray registry`
- `ray run "<prompt>"`
- `ray "<prompt>"`

`brain infer` routes an inference request through the gateway layer.

`kao gateway` gives the operator a direct readable gateway status surface
without requiring inspection of shell libraries.

`kao gateway health` gives a shorter provider-readiness view.

`kao gateway logs` gives a short readable tail of the current gateway trace.

`ray` is the high-readability operator surface of the hybrid router foundation.

`ray status` gives a compact human-readable reading of the selected route,
decision state, route reason, operator mode, hybrid capability state,
route scoring and selected registry reading.

`ray registry` gives a first stable readable surface of the live internal
model registry.

`ray run "<prompt>"` executes a request through the same gateway-backed path
as `brain infer`.

`ray "<prompt>"` is a direct shortcut for `ray run "<prompt>"`.

The current gateway and ray model supports:

- cloud routing through Mistral when external secrets are available
- local routing through Ollama with progressive readiness states
- controlled real local execution behind explicit policy
- explicit runtime log trace in `state/logs/gateway.log`
- canonical human-readable inspection through `kao gateway`
- direct health reading through `kao gateway health`
- direct short log preview through `kao gateway logs`
- compact hybrid-readable operator reading through `ray status`
- first deterministic hybrid scoring layer for route selection readability
- first internal live model registry layer
- explicit separation between runtime capacity and effective routing decision
- explicit separation between provider routing and model registry reading

## Gateway quick view

The current gateway behavior is:

- load external secrets from outside `/home/kao`
- detect or honor the selected provider
- route to `mistral` or `ollama`
- preserve cloud priority by default
- expose visible route information in terminal
- preserve a readable fallback model
- expose a direct operator diagnostic surface
- expose provider kind, provider health, target model, runtime state, real-call policy and real-call state
- expose selected registry provider, model, family, declared state, runtime state and registry score
- expose a short readable log preview
- keep cockpit inspection out of runtime log pollution

## Ray quick view

The current ray behavior is:

- expose the selected route as `cloud`, `local` or `none`
- expose the decision state
- expose the route reason
- expose the selected route score
- expose per-family cloud and local scores
- expose a high-level operator mode:
  - `online`
  - `offline`
  - `degraded`
  - `hybrid-ready`
- expose a compact hybrid state:
  - `hybrid-ready`
  - `cloud-only`
  - `local-only`
  - `unavailable`
- expose cloud readiness
- expose local readiness
- expose a first readable model registry surface through `ray registry`
- preserve the selected provider visibility
- preserve the same execution path as `brain infer`

Typical operator reading now includes:

- selected route
- selected provider
- selected provider label
- selected provider kind
- selected provider health
- selected provider note
- decision state
- route reason
- route score
- cloud score
- local score
- mode
- hybrid state
- cloud readiness
- local readiness
- forced raw value, forced provider and forced state
- detected provider
- registry count
- registry provider
- registry model
- registry family
- registry base score
- registry declared state
- registry runtime state
- registry score
- provider availability and health for mistral
- provider availability, kind and health for ollama
- ollama model
- ollama model state
- ollama runtime state
- ollama real calls policy
- ollama real state
- secrets file path and state
- log file path and state
- log line count
- last log event
- fallback policy
- fallback status
- diagnostic hint
- log preview tail

Current provider state:

- `mistral` is operational when external secrets are present
- `ollama` now exposes progressive local readiness
- a first internal model registry exists with canonical provider/model entries
- local readiness can be:
  - `unavailable`
  - `local-stub-ready`
  - `local-real-backend-ready`
  - `local-real-ready`
- registry declared state can currently be:
  - `unknown`
- registry runtime state can be:
  - `unknown`
  - `ready`
  - `degraded`
- ray decision states can be:
  - `route-selected`
  - `no-route-selected`
  - `blocked-unsupported-forcing`
- ray route reasons can be:
  - `cloud-priority-ready`
  - `local-only-available`
  - `forced-provider-mistral`
  - `forced-provider-ollama`
  - `unsupported-forced-provider`
  - `no-provider-ready`
- ray operator mode can be:
  - `online`
  - `offline`
  - `degraded`
  - `hybrid-ready`
- ray hybrid state can be:
  - `hybrid-ready`
  - `cloud-only`
  - `local-only`
  - `unavailable`
- ollama model state can be:
  - `unknown`
  - `missing`
  - `ready`
- ollama runtime state can be:
  - `stub-runtime`
  - `real-backend-ready`
  - `real-model-ready`
  - `unavailable`
- local real-call policy can be:
  - `enabled`
  - `disabled`
- local real-call state can be:
  - `callable`
  - `blocked-policy`
  - `blocked-no-model`
  - `stub-only`
  - `unavailable`
- fallback remains readable and operator-visible

Decision reading doctrine:

- `forced raw value` exposes the operator input exactly as expressed
- `forced provider` exposes the normalized supported provider retained by the router
- `forced state` exposes whether the forcing expression is unset, supported or unsupported
- `decision state` describes whether the router can actually retain a decision
- `hybrid state` describes runtime capability across cloud and local families
- `mode` gives the operator-facing effective reading of the current decision situation
- `registry declared state` preserves the canonical registry declaration
- `registry runtime state` reflects the current runtime reading of the registered entry
- `registry score` preserves a first readable ranking-ready value without changing routing

Important decision case:

- an unsupported forced provider can block the decision
- in that case:
  - forced raw value can remain the invalid operator input
  - forced provider can remain `none`
  - forced state can become `unsupported`
  - selected route can become `none`
  - decision state can become `blocked-unsupported-forcing`
  - mode can become `degraded`
  - hybrid state can still remain `hybrid-ready`
  - registry provider can remain `none`
- this means runtime capacity is still present
  but the effective routing decision is blocked by invalid forcing

Current observability state:

- runtime inference events are written to `state/logs/gateway.log`
- cockpit commands do not append diagnostic noise to the runtime log
- fallback and inference traces remain visible in the runtime log
- local runtime traces now distinguish:
  - `ollama real inference attempt`
  - `ollama target model: <model> (<state>)`
  - `ollama real inference ok`
  - `ollama stub inference ok`
  - `ollama real fallback attempt`
  - `ollama fallback target model: <model> (<state>)`
  - `ollama real fallback response ok`
  - `ollama stub fallback response ok`

## Governance

- CONTRIBUTING.md
- ISSUES.md
- PULL_REQUESTS.md
- ROADMAP.md
